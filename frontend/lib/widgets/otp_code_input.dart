import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpCodeInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpCodeInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  static const int _otpLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<String> _values;
  bool _isInternalUpdate = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _otpLength,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      _otpLength,
      (index) => _createFocusNode(index),
    );
    _values = List.filled(_otpLength, '');

    _syncFromParent();

    widget.controller.addListener(_onParentControllerChanged);

    if (widget.focusNode != null) {
      widget.focusNode!.addListener(_onExternalFocusChanged);
    }
  }

  FocusNode _createFocusNode(int index) {
    final node = FocusNode(
      debugLabel: 'OtpBox_$index',
      onKeyEvent: (focusNode, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.backspace ||
                event.logicalKey == LogicalKeyboardKey.delete)) {
          // Khi nhấn phím xóa trên ô hiện tại có ký tự -> Xóa số ô này
          if (_controllers[index].text.isNotEmpty) {
            _controllers[index].clear();
            _values[index] = '';
            _syncToParent();
            setState(() {});
            return KeyEventResult.handled;
          }
          // Khi ô hiện tại đã trống và nhấn phím xóa -> Lùi về ô trước và xóa số ô trước
          if (index > 0) {
            _focusNodes[index - 1].requestFocus();
            _controllers[index - 1].clear();
            _values[index - 1] = '';
            _syncToParent();
            setState(() {});
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );

    node.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    return node;
  }

  void _onExternalFocusChanged() {
    if (widget.focusNode?.hasFocus ?? false) {
      int targetIndex = _controllers.indexWhere((c) => c.text.isEmpty);
      if (targetIndex == -1) targetIndex = 0;
      _focusNodes[targetIndex].requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant OtpCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onParentControllerChanged);
      widget.controller.addListener(_onParentControllerChanged);
      _syncFromParent();
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onExternalFocusChanged);
      widget.focusNode?.addListener(_onExternalFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onParentControllerChanged);
    widget.focusNode?.removeListener(_onExternalFocusChanged);
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _syncFromParent() {
    final text = widget.controller.text;
    for (int i = 0; i < _otpLength; i++) {
      final char = i < text.length ? text[i] : '';
      _values[i] = char;
      if (_controllers[i].text != char) {
        _controllers[i].text = char;
      }
    }
  }

  void _onParentControllerChanged() {
    if (_isInternalUpdate) return;
    final currentOtp = _controllers.map((c) => c.text).join();
    if (widget.controller.text != currentOtp) {
      _syncFromParent();
      if (mounted) setState(() {});
    }
  }

  void _syncToParent() {
    _isInternalUpdate = true;
    final combined = _controllers.map((c) => c.text).join();
    if (widget.controller.text != combined) {
      widget.controller.text = combined;
    }
    _isInternalUpdate = false;

    widget.onChanged?.call(combined);
    if (combined.length == _otpLength) {
      widget.onCompleted?.call(combined);
    }
  }

  void _onBoxChanged(String value, int index) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      // 1. Trường hợp dán toàn bộ mã OTP (ví dụ dán 6 số)
      if (digits.length >= _otpLength) {
        for (int i = 0; i < _otpLength; i++) {
          _values[i] = digits[i];
          _controllers[i].text = digits[i];
        }
        _syncToParent();
        _focusNodes[_otpLength - 1].requestFocus();
        _controllers[_otpLength - 1].selection =
            const TextSelection.collapsed(offset: 1);
        setState(() {});
        return;
      }

      // 2. Trường hợp ô đã có số và người dùng gõ số mới để ghi đè
      final oldChar = _values[index];
      String newChar = digits[digits.length - 1];
      if (oldChar.isNotEmpty) {
        if (digits.startsWith(oldChar)) {
          newChar = digits.substring(oldChar.length);
        } else if (digits.endsWith(oldChar)) {
          newChar = digits.substring(0, digits.length - oldChar.length);
        }
        if (newChar.length > 1) {
          newChar = newChar[newChar.length - 1];
        }
      }

      _values[index] = newChar;
      _controllers[index].value = TextEditingValue(
        text: newChar,
        selection: const TextSelection.collapsed(offset: 1),
      );
      _syncToParent();

      // Nhảy sang ô bên cạnh sau khi ghi đè số
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controllers[index + 1].text.isNotEmpty) {
            _controllers[index + 1].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[index + 1].text.length,
            );
          }
        });
      } else {
        _focusNodes[index].unfocus();
      }
      setState(() {});
      return;
    }

    // 3. Trường hợp nhập 1 chữ số vào ô
    if (digits.isNotEmpty) {
      _values[index] = digits;
      _controllers[index].value = TextEditingValue(
        text: digits,
        selection: const TextSelection.collapsed(offset: 1),
      );
      _syncToParent();

      // Tự động chuyển con trỏ sang ô bên cạnh
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controllers[index + 1].text.isNotEmpty) {
            _controllers[index + 1].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[index + 1].text.length,
            );
          }
        });
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      // 4. Trường hợp người dùng xóa số bằng phím xóa
      _values[index] = '';
      _controllers[index].clear();
      _syncToParent();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        final isFocused = _focusNodes[index].hasFocus;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4.0,
              right: index == _otpLength - 1 ? 0 : 4.0,
            ),
            child: AspectRatio(
              aspectRatio: 1.0, // Ép cho các ô vuông vắn đẹp mắt
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFocused
                        ? const Color(0xFF15193B)
                        : const Color(0xFF15193B).withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    cursorColor: const Color(0xFF15193B),
                    cursorWidth: 2,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15193B),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => _onBoxChanged(val, index),
                    onTap: () {
                      // Khi bấm vào bất kỳ ô nào, tự động bôi đen ký tự để có thể gõ đè hoặc xóa ngay
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_controllers[index].text.isNotEmpty) {
                          _controllers[index].selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _controllers[index].text.length,
                          );
                        }
                      });
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
