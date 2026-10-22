import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin Debounce Real-time Search Tests', () {
    test('DB01: Timer debounce trì hoãn tìm kiếm 350ms khi người dùng đang gõ', () async {
      int searchCallCount = 0;
      String? lastKeyword;
      Timer? debounceTimer;

      void onSearchChanged(String val) {
        debounceTimer?.cancel();
        if (val.trim().isEmpty) {
          searchCallCount++;
          lastKeyword = '';
        } else {
          debounceTimer = Timer(const Duration(milliseconds: 350), () {
            searchCallCount++;
            lastKeyword = val.trim();
          });
        }
      }

      // Người dùng gõ "nguyen"
      onSearchChanged('n');
      expect(searchCallCount, 0, reason: 'Chưa đủ 350ms nên chưa được gọi API');

      await Future.delayed(const Duration(milliseconds: 100));
      onSearchChanged('ng');
      expect(searchCallCount, 0, reason: 'Vẫn đang gõ liên tục nên debounce bị reset');

      await Future.delayed(const Duration(milliseconds: 100));
      onSearchChanged('nguyen');
      expect(searchCallCount, 0, reason: 'Vừa gõ xong, đang đợi debounce 350ms');

      // Đợi hết 350ms
      await Future.delayed(const Duration(milliseconds: 380));
      expect(searchCallCount, 1, reason: 'Sau 350ms dừng gõ, API tự động được gọi 1 lần duy nhất');
      expect(lastKeyword, 'nguyen');

      debounceTimer?.cancel();
    });

    test('DB02: Khi xóa hết chữ trong ô tìm kiếm, lập tức hoàn nguyên ban đầu (0ms delay)', () async {
      int searchCallCount = 0;
      String? lastKeyword = 'khoa_cu';
      Timer? debounceTimer;

      void onSearchChanged(String val) {
        debounceTimer?.cancel();
        if (val.trim().isEmpty) {
          searchCallCount++;
          lastKeyword = '';
        } else {
          debounceTimer = Timer(const Duration(milliseconds: 350), () {
            searchCallCount++;
            lastKeyword = val.trim();
          });
        }
      }

      // Mô phỏng xóa sạch ô tìm kiếm (chuỗi rỗng "")
      onSearchChanged('');

      // Ngay lập tức (không cần đợi 350ms) phải gọi lại dữ liệu ban đầu
      expect(searchCallCount, 1, reason: 'Phải gọi lại dữ liệu ngay lập tức với 0 delay');
      expect(lastKeyword, '', reason: 'Từ khóa phải là rỗng để tải toàn bộ danh sách ban đầu');

      // Tương tự khi người dùng chỉ bấm phím cách (khoảng trắng)
      onSearchChanged('    ');
      expect(searchCallCount, 2);
      expect(lastKeyword, '');

      debounceTimer?.cancel();
    });

    test('DB03: Bấm phím Enter hoặc icon kính lúp kích hoạt tìm kiếm ngay lập tức (bỏ qua debounce)', () async {
      int searchCallCount = 0;
      String? lastKeyword;
      Timer? debounceTimer;

      void onSearchChanged(String val) {
        debounceTimer?.cancel();
        if (val.trim().isEmpty) {
          searchCallCount++;
          lastKeyword = '';
        } else {
          debounceTimer = Timer(const Duration(milliseconds: 350), () {
            searchCallCount++;
            lastKeyword = val.trim();
          });
        }
      }

      void onSearchImmediate(String val) {
        debounceTimer?.cancel();
        searchCallCount++;
        lastKeyword = val.trim();
      }

      // Người dùng gõ "triet hoc"
      onSearchChanged('triet hoc');
      expect(searchCallCount, 0);

      // Người dùng nhấn phím Enter ngay lúc 50ms
      await Future.delayed(const Duration(milliseconds: 50));
      onSearchImmediate('triet hoc');

      expect(searchCallCount, 1, reason: 'Nhấn Enter kích hoạt tìm kiếm ngay tức thì');
      expect(lastKeyword, 'triet hoc');

      // Đợi thêm 400ms để chắc chắn timer cũ không bị bắn thêm lần nữa
      await Future.delayed(const Duration(milliseconds: 400));
      expect(searchCallCount, 1, reason: 'Timer debounce đã bị hủy, không kích hoạt lần 2');

      debounceTimer?.cancel();
    });

    testWidgets('DB04: Widget Test kiểm tra ẩn/hiện nút X và kích hoạt reset khi xóa chữ', (tester) async {
      final searchController = TextEditingController();
      Timer? debounceTimer;
      String currentSearch = 'initial';
      int loadCount = 0;

      void onSearchChanged(String val, StateSetter setState) {
        setState(() {});
        debounceTimer?.cancel();
        if (val.trim().isEmpty) {
          loadCount++;
          currentSearch = '';
        } else {
          debounceTimer = Timer(const Duration(milliseconds: 350), () {
            loadCount++;
            currentSearch = val.trim();
          });
        }
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TextField(
                  controller: searchController,
                  onChanged: (val) => onSearchChanged(val, setState),
                  decoration: InputDecoration(
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              debounceTimer?.cancel();
                              loadCount++;
                              currentSearch = '';
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Ban đầu ô tìm kiếm rỗng -> không có nút Clear (icon clear)
      expect(find.byIcon(Icons.clear), findsNothing);

      // Nhập từ khóa "test"
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Nút X phải xuất hiện
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(loadCount, 0, reason: 'Chưa trôi qua 350ms nên chưa load');

      // Đợi 350ms
      await tester.pump(const Duration(milliseconds: 360));
      expect(loadCount, 1, reason: 'Sau 350ms đã load với từ khóa');
      expect(currentSearch, 'test');

      // Người dùng nhấn nút X để xóa tìm kiếm
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Nút X biến mất và danh sách được reset về ban đầu
      expect(find.byIcon(Icons.clear), findsNothing);
      expect(searchController.text, '');
      expect(loadCount, 2, reason: 'Bấm nút X gọi load ngay lập tức');
      expect(currentSearch, '');

      // Người dùng nhập lại từ khóa "abc"
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Người dùng dùng backspace xóa hết chữ về chuỗi rỗng ""
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Khi xóa hết chữ: danh sách tự động reset về rỗng ngay lập tức (0ms delay)
      expect(find.byIcon(Icons.clear), findsNothing);
      expect(loadCount, 3, reason: 'Xóa hết chữ tự động gọi load ban đầu ngay lập tức');
      expect(currentSearch, '');

      debounceTimer?.cancel();
      searchController.dispose();
    });
  });
}
