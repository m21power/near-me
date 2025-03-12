import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/core/core.dart';

part 'internet_event.dart';
part 'internet_state.dart';

class InternetBloc extends Bloc<InternetEvent, InternetState> {
  final NetworkInfo networkInfo;
  late Timer? timer;
  InternetBloc({required this.networkInfo}) : super(InternetInitial()) {
    startChecking();
    on<CheckInternetConnectionEvent>(
      (event, emit) async {
        if (await networkInfo.isConnected) {
          emit(InternetConnectedSuccessfully());
        } else {
          emit(NoInternetConnection("No internet connection"));
        }
      },
    );
  }
  void startChecking() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      add(CheckInternetConnectionEvent());
    });
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}
