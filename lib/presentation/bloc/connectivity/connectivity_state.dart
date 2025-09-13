import 'package:equatable/equatable.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {
  final DateTime lastConnected;

  const ConnectivityOnline({required this.lastConnected});

  @override
  List<Object> get props => [lastConnected];
}

class ConnectivityOffline extends ConnectivityState {
  final DateTime lastDisconnected;

  const ConnectivityOffline({required this.lastDisconnected});

  @override
  List<Object> get props => [lastDisconnected];
}
