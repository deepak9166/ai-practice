import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum MediaType { image, video }

mixin ImagePickerUtils {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(BuildContext context) async {
    return pickMedia(context, mediaType: MediaType.image);
  }

  Future<XFile?> pickVideo(
    BuildContext context, {
    Duration? maxDuration,
  }) async {
    return pickMedia(
      context,
      mediaType: MediaType.video,
      maxDuration: maxDuration,
    );
  }

  Future<XFile?> pickMedia(
    BuildContext context, {
    required MediaType mediaType,
    Duration? maxDuration,
  }) async {
    final ImageSource? source = await _showMediaSourceDialog(
      context,
      mediaType,
    );
    if (source == null) return null;

    // ignore: use_build_context_synchronously
    return await _pickFromSource(context, source, mediaType, maxDuration);
  }

  Future<ImageSource?> _showMediaSourceDialog(
    BuildContext context,
    MediaType mediaType,
  ) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(
                  mediaType == MediaType.image ? 'Gallery' : 'Video Gallery',
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(
                  mediaType == MediaType.image
                      ? Icons.camera_alt
                      : Icons.videocam,
                ),
                title: Text(
                  mediaType == MediaType.image ? 'Camera' : 'Record Video',
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<XFile?> _pickFromSource(
    BuildContext context,
    ImageSource source,
    MediaType mediaType,
    Duration? maxDuration,
  ) async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _pickMediaInternal(source, mediaType, maxDuration);
    }

    Permission permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final status = await permission.request();

    if (!status.isGranted) {
      // ignore: use_build_context_synchronously
      _showPermissionDialog(context);
      return null;
    }

    return _pickMediaInternal(source, mediaType, maxDuration);
  }

  Future<XFile?> _pickMediaInternal(
    ImageSource source,
    MediaType mediaType,
    Duration? maxDuration,
  ) async {
    try {
      if (mediaType == MediaType.image) {
        return await _picker.pickImage(source: source);
      } else {
        return await _picker.pickVideo(
          source: source,
          maxDuration: maxDuration ?? Duration(minutes: 5),
        );
      }
    } catch (_) {
      return null;
    }
  }

  /// Permission dialog
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Permission is required to access media. Please enable it in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
