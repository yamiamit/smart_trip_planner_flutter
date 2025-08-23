import '../../trips/data/trip.dart';


abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final Trip trip;
  ChatLoaded(this.trip);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
