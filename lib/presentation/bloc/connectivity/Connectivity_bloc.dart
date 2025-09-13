import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<CheckConnectivity>(_onCheckConnectivity);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      final isConnected = result != ConnectivityResult.none;
      add(ConnectivityChanged(isConnected: isConnected));
    });

    add(const CheckConnectivity());
  }

  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    if (!isClosed) {
      if (event.isConnected) {
        emit(ConnectivityOnline(lastConnected: DateTime.now()));
      } else {
        emit(ConnectivityOffline(lastDisconnected: DateTime.now()));
      }
    }
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<ConnectivityState> emit,
  ) async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isConnected = result != ConnectivityResult.none;

      if (!isClosed) {
        if (isConnected) {
          emit(ConnectivityOnline(lastConnected: DateTime.now()));
        } else {
          emit(ConnectivityOffline(lastDisconnected: DateTime.now()));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(ConnectivityOffline(lastDisconnected: DateTime.now()));
      }
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
