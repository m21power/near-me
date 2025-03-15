import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/features/home/domain/usecases/check_internet_connection.dart';

part 'internet_event.dart';
part 'internet_state.dart';

class InternetBloc extends Bloc<InternetEvent, InternetState> {
  StreamSubscription<bool>? networkSubscription;
  final CheckInternetConnectionUsecase checkInternetConnectionUsecase;
  InternetBloc({required this.checkInternetConnectionUsecase})
      : super(InternetInitial()) {
    networkSubscription = checkInternetConnectionUsecase().listen((ondata) {
      if (ondata == false) {
        add(NoInternetConnection());
      } else {
        add(ConnectedToInternet());
      }
    });
    on<NoInternetConnection>(
      (event, emit) {
        emit(NoInternetConnectionState("No Internet Connection"));
      },
    );
    on<ConnectedToInternet>(
      (event, emit) {
        emit(InternetConnectedSuccessfully());
      },
    );
  }
  @override
  Future<void> close() {
    networkSubscription?.cancel();
    return super.close();
  }
}
