import 'package:flutter/material.dart';

class StatusConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isLockAction;

  const StatusConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.isLockAction,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required bool isLockAction,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatusConfirmDialog(
        title: title,
        message: message,
        isLockAction: isLockAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
      ),
      backgroundColor: Colors.white,
      elevation: 16,
      child: Container(
        width: 500,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng tiêu đề có icon và nút đóng 'X' ở góc phải (đúng ảnh Web 1920 - 8 & 10)
            Row(
              children: [
                Icon(
                  isLockAction ? Icons.lock_outline : Icons.verified_user_outlined,
                  size: 26,
                  color: const Color(0xFF1E2238),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2238),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dòng câu hỏi
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // 2 Nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E2238),
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Hủy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLockAction
                        ? const Color(0xFFE11D48) // Nút đỏ nếu là Tạm khóa
                        : const Color(0xFF1E2238), // Nút xanh đen nếu là Kích hoạt
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Xác nhận', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
