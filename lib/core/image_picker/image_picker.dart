import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../error/failure.dart';

abstract class ImagePath {
  Future<Either<Failure, String>> getImagePath();
}

class ImagePathImpl implements ImagePath {
  ImagePicker imagePicker;

  ImagePathImpl({required this.imagePicker});
  @override
  Future<Either<Failure, String>> getImagePath() async {
    try {
      final file = await imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        return const Left(ServiceFailure(message: 'Image is null'));
      }
      return Right(file.path);
    } catch (e) {
      return const Left(ServiceFailure(
          message: 'ImagePathService Failure picker not working'));
    }
  }
}
