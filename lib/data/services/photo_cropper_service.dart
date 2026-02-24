import 'package:image_cropper/image_cropper.dart';

class PhotoCropperService {
  static Future<String?> cropToSquare({
    required String sourcePath,
  }) async {
    final trimmed = sourcePath.trim();
    if (trimmed.isEmpty) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: trimmed,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Use o zoom para enquadrar o objeto',
          aspectRatioPresets: const [CropAspectRatioPreset.square],
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Use o zoom para enquadrar o objeto',
          aspectRatioPresets: const [CropAspectRatioPreset.square],
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          rotateButtonsHidden: false,
        ),
      ],
    );

    return cropped?.path;
  }
}
