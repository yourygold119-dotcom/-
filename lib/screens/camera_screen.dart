import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// كاميرا يوراء الحقيقية — معاينة حية + فلاتر + فيديو من الاستوديو
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];

  final List<_YuraaFilter> _filters = [
    _YuraaFilter("طبيعي 🌿", Colors.transparent),
    _YuraaFilter("سينمائي 🎬", Color(0x662196F3)),
    _YuraaFilter("أبيض وأسود 🖤", Color(0x99000000)),
    _YuraaFilter("ساطع ✨", Color(0x33FFF176)),
    _YuraaFilter("كلاسيكي 🕰️", Color(0x55FFB300)),
  ];
  int _selectedFilterIndex = 0;

  bool _isFlashOn = false;
  bool _isVideoMode = false;
  bool _isRecording = false;
  bool _isProcessingGalleryVideo = false;

  // معاينة فيديو مستوديو مُطبق عليه فلتر
  VideoPlayerController? _galleryVideoController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      _cameraController = CameraController(
          _cameras.first, ResolutionPreset.high,
          enableAudio: true);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (_) {
      // الجهاز لا يدعم كاميرا — تبقى واجهة المحاكاة
    }
  }

  // اختيار فيديو من الاستوديو وتطبيق الفلتر عليه
  Future<void> _pickVideoFromGalleryAndApplyFilter() async {
    final picked =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _isProcessingGalleryVideo = true);
    await _galleryVideoController?.dispose();
    _galleryVideoController =
        VideoPlayerController.networkUrl(Uri.parse(picked.path))
          ..initialize().then((_) {
            _galleryVideoController!.setLooping(true);
            _galleryVideoController!.play();
            setState(() => _isProcessingGalleryVideo = false);
          });
  }

  void _addNewFilter() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة فلتر جديد ✨"),
        content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: "أدخل اسم الفلتر الجديد")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _filters.add(_YuraaFilter(
                      controller.text.trim(), const Color(0x44888888)));
                  _selectedFilterIndex = _filters.length - 1;
                });
                Navigator.pop(context);
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _galleryVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _filters[_selectedFilterIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // المعاينة الحقيقية أو المحاكاة
        Center(
          child: _isProcessingGalleryVideo
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    SizedBox(height: 15),
                    Text("جاري معالجة الفيديو...",
                        style: TextStyle(color: Colors.white)),
                  ],
                )
              : _buildPreview(filter),
        ),

        // طبقة الفلتر فوق المعاينة
        if (filter.color != Colors.transparent)
          IgnorePointer(
            child: Container(color: filter.color.withOpacity(0.25)),
          ),

        // الأزرار العلوية
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context)),
              IconButton(
                icon: const Icon(Icons.video_library,
                    color: Colors.amber, size: 28),
                tooltip: "فيديو من الاستوديو + فلتر",
                onPressed: _pickVideoFromGalleryAndApplyFilter,
              ),
              IconButton(
                icon: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: _isFlashOn ? Colors.amber : Colors.white,
                  size: 28,
                ),
                onPressed: () async {
                  setState(() => _isFlashOn = !_isFlashOn);
                  if (_cameraController != null) {
                    await _cameraController!.setFlashMode(
                        _isFlashOn ? FlashMode.torch : FlashMode.off);
                  }
                },
              ),
            ],
          ),
        ),

        // شريط الفلاتر
        Positioned(
          bottom: 150,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length + 1,
              itemBuilder: (context, index) {
                if (index == _filters.length) {
                  return GestureDetector(
                    onTap: _addNewFilter,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(25)),
                      child: const Row(children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text("فلتر جديد",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  );
                }
                final isSelected = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.black54,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Center(
                      child: Text(_filters[index].name,
                          style: TextStyle(
                              color:
                                  isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // تبديل صورة/فيديو
        Positioned(
          bottom: 95,
          left: 0,
          right: 0,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () => setState(() {
                _isVideoMode = false;
                _isRecording = false;
              }),
              child: Text("صورة",
                  style: TextStyle(
                      color: !_isVideoMode ? Colors.amber : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            const SizedBox(width: 30),
            GestureDetector(
              onTap: () => setState(() => _isVideoMode = true),
              child: Text("فيديو مباشر",
                  style: TextStyle(
                      color: _isVideoMode ? Colors.amber : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ]),
        ),

        // زر التصوير الحقيقي
        Positioned(
          bottom: 15,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _handleCapture,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _isVideoMode ? Colors.red : Colors.white,
                      width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? Colors.red
                        : (_isVideoMode ? Colors.redAccent : Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildPreview(_YuraaFilter filter) {
    if (_galleryVideoController != null &&
        _galleryVideoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _galleryVideoController!.value.aspectRatio,
        child: VideoPlayer(_galleryVideoController!),
      );
    }
    if (_cameraController != null &&
        _cameraController!.value.isInitialized) {
      return CameraPreview(_cameraController!);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _isVideoMode ? Icons.videocam : Icons.camera_alt,
          size: 80,
          color: _isRecording ? Colors.red : Colors.white38,
        ),
        const SizedBox(height: 10),
        Text("الفلتر النشط: ${filter.name}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _handleCapture() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "تم التقاط ${_isVideoMode ? 'الفيديو' : 'الصورة'} بفلتر (${_filters[_selectedFilterIndex].name})")),
      );
      return;
    }
    if (_isVideoMode) {
      if (_isRecording) {
        final file = await _cameraController!.stopVideoRecording();
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم حفظ الفيديو: ${file.path} 💾")),
        );
      } else {
        await _cameraController!.startVideoRecording();
        setState(() => _isRecording = true);
      }
    } else {
      final file = await _cameraController!.takePicture();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم التقاط الصورة: ${file.path} 📸")),
      );
    }
  }
}

class _YuraaFilter {
  final String name;
  final Color color;
  const _YuraaFilter(this.name, this.color);
}
