import 'package:near_me/features/home/domain/repository/home_repository.dart';

class CheckInternetConnectionUsecase {
  final HomeRepository homeRepository;
  CheckInternetConnectionUsecase({required this.homeRepository});
  Stream<bool> call() {
    return homeRepository.checkInternet();
  }
}
