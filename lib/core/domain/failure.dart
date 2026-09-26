import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String? message;
  final String? code;

  const Failure({this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType($code): $message';
}

class CacheFailure extends Failure {
  const CacheFailure({super.message, super.code});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message, super.code});
}
