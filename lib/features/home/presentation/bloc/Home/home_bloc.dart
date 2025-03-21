import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/features/home/domain/entities/entity.dart';
import 'package:near_me/features/home/domain/usecases/seach_user_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SearchUserUsecase searchUserUsecase;
  HomeBloc({required this.searchUserUsecase}) : super(HomeInitial()) {
    on<SearchUserEvent>(
      (event, emit) async {
        emit(SearchLoadState());
        var value = await searchUserUsecase(event.name);
        print("99999999999999999999999999999");
        print(value);
        print("99999999999999999999999999999");

        value.fold((l) => emit(SearchUserFailureState(l.message)),
            (r) => emit(SearchUserSuccessState(r)));
      },
    );
  }
}
