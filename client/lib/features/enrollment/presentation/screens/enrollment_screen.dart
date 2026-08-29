import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';

class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isCapturing = false;
  int _captureCount = 0;
  static const int _requiredCaptures = 5;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('No camera found');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final image = await _cameraController!.takePicture();
      
      // Upload to backend
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path),
        'capture_number': _captureCount + 1,
      });

      await ref.read(apiClientProvider).enrollFace(formData);

      setState(() {
        _captureCount++;
        _isCapturing = false;
      });

      if (_captureCount >= _requiredCaptures) {
        _showSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Captured $_captureCount/$_requiredCaptures'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
      setState(() => _isCapturing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 64,
        ),
        title: const Text('Enrollment Complete!'),
        content: const Text(
          'Your face has been successfully enrolled. You can now use facial recognition for attendance.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              context.go('/home');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Enrollment'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isInitialized && _cameraController != null
                ? Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _cameraController!.value.aspectRatio,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 250,
                          height: 320,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(150),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Position your face within the oval\n$_captureCount/$_requiredCaptures photos captured',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Instructions:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildInstruction('Position your face within the oval'),
                _buildInstruction('Ensure good lighting'),
                _buildInstruction('Look directly at the camera'),
                _buildInstruction('Keep a neutral expression'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCapturing ? null : _captureImage,
                    child: _isCapturing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _captureCount == 0
                                ? 'Start Capture'
                                : 'Capture Next ($_captureCount/$_requiredCaptures)',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
