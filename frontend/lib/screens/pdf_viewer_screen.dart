import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../controllers/subject_controller.dart';
import '../services/user_session.dart';

// =========================================================================================
// [TÊN FILE: pdf_viewer_screen.dart]
// [VỊ TRÍ]: lib/screens/pdf_viewer_screen.dart
// [MỤC ĐÍCH]: Màn hình đọc tài liệu PDF nhúng trực tiếp trong ứng dụng (In-App PDF Viewer).
//
// [CƠ CHẾ TỰ ĐỘNG ZERO-CLICK - KHÔNG CẦN BẤM NÚT]:
// 1. Tự động đếm giờ (Stopwatch) khi tài liệu tải xong.
// 2. Tự động tạm dừng đồng hồ khi học viên thu nhỏ/ẩn ứng dụng (tránh gian lận thời gian).
// 3. Tự động nhận diện trang đang đọc qua 'onPageChanged'.
// 4. Tự động đánh dấu "ĐÃ ĐỌC" (COMPLETED) khi:
//    - Học viên đọc đủ ngưỡng 30 giây (seconds >= 30), HOẶC
//    - Học viên lướt tới trang cuối cùng của tài liệu (pageNumber >= totalPages).
// 5. Tự động gửi kết quả tiến độ ngầm về Backend mà không làm gián đoạn việc đọc.
// 6. Tự động chốt phiên và đồng bộ khi học viên bấm nút 'X' hoặc vuốt thoát.
// =========================================================================================

class PdfViewerScreen extends StatefulWidget {
  /// [NGƯỠNG THỜI GIAN TỰ ĐỘNG HOÀN THÀNH]:
  /// Số giây đọc tối thiểu (mặc định 60s) để tự động chuyển bài học sang ĐÃ HOÀN THÀNH.
  static const int completionThresholdSeconds = 60;

  final String title;          // Tiêu đề tài liệu / Tên bài học hiển thị trên AppBar
  final String pdfUrl;         // Đường link URL tải file PDF từ Backend
  final String? lessonId;      // ID bài học để tự động ghi nhận tiến độ vào Database
  final String? userId;        // ID người dùng (nếu null sẽ lấy từ UserSession)
  final bool initialIsRead;    // Trạng thái đã hoàn thành trước đó
  final int initialReadingSeconds; // Thời gian thực tế đã đọc tích lũy các lần trước
  final int initialLastPosition;   // Trang đọc xa nhất từng đạt được ở các lần trước

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.lessonId,
    this.userId,
    this.initialIsRead = false,
    this.initialReadingSeconds = 0,
    this.initialLastPosition = 1,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> with WidgetsBindingObserver {
  late PdfViewerController _pdfViewerController;
  final SubjectController _subjectController = SubjectController();

  // Trạng thái trình xem PDF
  bool _isLoading = true;         // Đang tải tài liệu
  bool _hasError = false;         // Gặp lỗi tải file
  String _errorDescription = '';   // Nội dung chi tiết lỗi
  Key _viewerKey = UniqueKey();   // Key reload widget

  // Trạng thái theo dõi tự động (Automatic Progress Tracking)
  final Stopwatch _readingStopwatch = Stopwatch();
  Timer? _tickerTimer;
  int _totalPages = 1;
  late bool _isCompleted;
  bool _hasTriggeredToast = false;
  bool _hasFinalSynced = false;
  int _accumulatedSeconds = 0;    // Thời gian đọc các lần trước cộng dồn
  int _maxPageReached = 1;        // Trang đọc lớn nhất từng đạt được

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pdfViewerController = PdfViewerController();
    _isCompleted = widget.initialIsRead;
    _accumulatedSeconds = widget.initialReadingSeconds;
    _maxPageReached = widget.initialLastPosition > 0 ? widget.initialLastPosition : 1;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Tự động dừng đếm giờ khi app bị ẩn hoặc chuyển sang app khác
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_readingStopwatch.isRunning) {
        _readingStopwatch.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_readingStopwatch.isRunning && !_isLoading && !_hasError) {
        _readingStopwatch.start();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _finishAndSyncProgress();
    _tickerTimer?.cancel();
    _pdfViewerController.dispose();
    super.dispose();
  }

  // Khởi động bộ đếm thời gian khi PDF đã tải xong
  void _startTracking() {
    if (!_readingStopwatch.isRunning) {
      _readingStopwatch.start();
    }

    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      // TỔNG THỜI GIAN ĐÃ ĐỌC (CỘNG DỒN) = Thời gian các lần trước + Thời gian phiên đọc này
      final totalElapsedSeconds = _accumulatedSeconds + _readingStopwatch.elapsed.inSeconds;

      // TIÊU CHÍ TỰ ĐỘNG ĐÁNH DẤU HOÀN THÀNH CHẠY NGẦM (THRESHOLD = 60 GIÂY)
      final reachedThreshold = totalElapsedSeconds >= PdfViewerScreen.completionThresholdSeconds;
      final reachedEnd = _totalPages > 0 && _maxPageReached >= _totalPages;

      if (!_isCompleted && (reachedThreshold || reachedEnd)) {
        _isCompleted = true;
        _autoSync(isCompletedThreshold: true);

        // Hiển thị thông báo Toast nhỏ thân thiện khi hoàn thành mốc 60s
        if (!_hasTriggeredToast) {
          _hasTriggeredToast = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reachedEnd
                          ? 'Đã đọc tới trang cuối! Đã tự động đánh dấu hoàn thành.'
                          : 'Đã hoàn thành bài học! (Đạt ngưỡng 60 giây)',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF15193B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (totalElapsedSeconds > 0 && _readingStopwatch.elapsed.inSeconds > 0 && _readingStopwatch.elapsed.inSeconds % 30 == 0) {
        // Đồng bộ ngầm định kỳ (Heartbeat) mỗi 30s
        _autoSync();
      }
    });
  }

  // Gửi ngầm tiến độ về Backend
  void _autoSync({bool isCompletedThreshold = false}) {
    if (widget.lessonId == null) return;

    final totalSeconds = _accumulatedSeconds + _readingStopwatch.elapsed.inSeconds;
    final effectiveUserId = widget.userId ?? UserSession.currentUserId;

    _subjectController.syncLessonProgress(
      lessonId: widget.lessonId!,
      userId: effectiveUserId,
      pageNumber: _maxPageReached,
      totalPages: _totalPages,
      secondsSpent: totalSeconds,
    );
  }

  // Chốt phiên đọc và gửi gói tin cuối cùng khi người dùng thoát
  void _finishAndSyncProgress() {
    if (_hasFinalSynced) return;
    _hasFinalSynced = true;

    _tickerTimer?.cancel();
    if (_readingStopwatch.isRunning) {
      _readingStopwatch.stop();
    }
    _autoSync();
  }

  // Hàm tải lại tài liệu khi nhấn nút "Thử lại"
  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorDescription = '';
      _viewerKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _finishAndSyncProgress();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        // 1. THANH TIÊU ĐỀ APPBAR: Hiển thị tên bài học sạch sẽ (toàn bộ đếm giờ chạy ngầm)
        appBar: AppBar(
          backgroundColor: const Color(0xFF15193B),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Nút Đóng 'X' ở góc trái theo chuẩn giao diện
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 26),
            tooltip: 'Đóng tài liệu',
            onPressed: () {
              _finishAndSyncProgress();
              Navigator.pop(context, _isCompleted);
            },
          ),
          // Các công cụ Zoom In / Zoom Out
          actions: [
            IconButton(
              icon: const Icon(Icons.zoom_in_rounded),
              tooltip: 'Phóng to',
              onPressed: () {
                _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.25;
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out_rounded),
              tooltip: 'Thu nhỏ',
              onPressed: () {
                if (_pdfViewerController.zoomLevel > 1.0) {
                  _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.25;
                }
              },
            ),
          ],
        ),

        // 2. PHẦN THÂN: Trình đọc PDF Syncfusion với cơ chế theo dõi tự động
        body: Stack(
          children: [
            if (!_hasError)
              SfPdfViewer.network(
                widget.pdfUrl,
                key: _viewerKey,
                controller: _pdfViewerController,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableDoubleTapZooming: true,
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  setState(() {
                    _isLoading = false;
                    _hasError = false;
                    _totalPages = details.document.pages.count;
                  });
                  // Bắt đầu đếm thời gian tự động ngay khi tài liệu tải xong
                  _startTracking();

                  // Tự động nhảy tới trang đọc lớn nhất từng đạt được ở các lần trước (nếu > 1)
                  if (widget.initialLastPosition > 1 &&
                      widget.initialLastPosition <= details.document.pages.count) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _pdfViewerController.jumpToPage(widget.initialLastPosition);
                      }
                    });
                  }
                },
                onPageChanged: (PdfPageChangedDetails details) {
                  _totalPages = _pdfViewerController.pageCount;
                  if (details.newPageNumber > _maxPageReached) {
                    _maxPageReached = details.newPageNumber;
                  }

                  // Tự động hoàn thành nếu lướt tới trang cuối cùng
                  if (!_isCompleted && _totalPages > 0 && _maxPageReached >= _totalPages) {
                    _isCompleted = true;
                    _autoSync(isCompletedThreshold: true);
                  }
                },
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _errorDescription = details.description;
                  });
                },
              ),

            // Vòng quay đang tải tài liệu
            if (_isLoading && !_hasError)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF15193B),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải tài liệu PDF...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF15193B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Giao diện báo lỗi trực quan và nút thử lại
            if (_hasError)
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 56,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Không thể mở tài liệu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15193B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorDescription.isNotEmpty
                            ? _errorDescription
                            : 'Không nhận được dữ liệu từ máy chủ hoặc mất kết nối mạng.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SelectableText(
                          widget.pdfUrl,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: widget.pdfUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã sao chép link tài liệu!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('Chép link'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _retryLoading,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15193B),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
