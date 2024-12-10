// Abstract class for all Auth States
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOTP extends AuthState {
  final String message;

  AuthOTP(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSuccess extends AuthState {
  AuthSuccess();
  @override
  List<Object?> get props => [];
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
