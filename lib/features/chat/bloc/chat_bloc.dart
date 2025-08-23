import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../trips/data/trip.dart';
import '../data/agent_client.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AgentClient agent;

  ChatBloc(this.agent) : super(ChatInitial()) {
    on<ChatPromptSubmitted>(_onPromptSubmitted);
  }

  Future<void> _onPromptSubmitted(
      ChatPromptSubmitted event,
      Emitter<ChatState> emit,
      ) async {
    emit(ChatLoading());
    try {
      final rawResponse = await agent.fetchTripPlan(event.prompt);
      final jsonMap = jsonDecode(rawResponse);
      final trip = Trip.fromJson(jsonMap);
      //print(trip);
      emit(ChatLoaded(trip));
    } catch (e) {
      emit(ChatError("Failed to fetch or parse trip: $e"));
      print(e);
    }
  }
}
