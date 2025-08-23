import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'package:dio/dio.dart';
import 'core/env/env.dart';
import 'core/network/dio_client.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/chat/data/agent_client.dart';
import 'features/trips/data/trip.dart';
import 'features/trips/data/trip_repo.dart';


late Isar isar;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  Env.initFromDotenv();


  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([TripSchema], directory: dir.path);


  final dio = buildDio();
  final agent = AgentClient(dio, Env.GeminiApiKey);
  final tripRepo = TripRepo(agent,isar);


  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: tripRepo),
        RepositoryProvider<Isar>.value(value: isar),
      ],
      child: BlocProvider(
        create: (_) => ChatBloc(agent),
        child: const SmartTripApp(),
      ),
    ),
  );
}




