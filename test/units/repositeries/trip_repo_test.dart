import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:smart_trip_planner/features/chat/data/agent_client.dart';
import 'package:smart_trip_planner/features/trips/data/trip.dart';
import 'package:smart_trip_planner/features/trips/data/trip_repo.dart';

//need to study these what exactly is happening here... act,assert,arrange
class MockDio extends Mock implements Dio {}
class MockIsar extends Mock implements Isar {}
class MockAgent extends Mock implements AgentClient {}
class MockIsarCollection extends Mock implements IsarCollection<Trip> {}

void main() {
  group('TripRepository Tests with Schema', () {
    late TripRepo repository;
    late Dio dio;
    late DioAdapter dioAdapter;
    late MockAgent mockAgent;
    late MockIsar mockIsar;
    late MockIsarCollection mockTripCollection;

    setUpAll(() {
      registerFallbackValue(RequestOptions(path: ''));
      registerFallbackValue(Trip());
    });

    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter(dio: dio);
      mockAgent = MockAgent();
      mockIsar = MockIsar();
      mockTripCollection = MockIsarCollection();

      when(() => mockIsar.trips).thenReturn(mockTripCollection);
      repository = TripRepo(mockAgent, mockIsar);
    });

    tearDown(() {
      dioAdapter.close();
    });

    test('should parse trip from JSON schema correctly', () async {
      // Arrange
      final jsonResponse = {
        "title": "Paris Adventure",
        "startDate": "2024-06-01",
        "endDate": "2024-06-07",
        "days": [
          {
            "date": "2024-06-01",
            "summary": "Arrival and city exploration",
            "items": [
              {
                "time": "09:00",
                "activity": "Arrive at Charles de Gaulle Airport",
                "location": "49.0097,2.5479"
              },
              {
                "time": "14:00",
                "activity": "Visit Eiffel Tower",
                "location": "48.8584,2.2945"
              }
            ]
          },
          {
            "date": "2024-06-02",
            "summary": "Museums and culture",
            "items": [
              {
                "time": "10:00",
                "activity": "Louvre Museum",
                "location": "48.8606,2.3376"
              },
              {
                "time": "15:30",
                "activity": "Walk along Seine",
                "location": "48.8566,2.3522"
              }
            ]
          }
        ]
      };

      // Mock API response
      dioAdapter.onPost(
        '/generate-itinerary',
            (server) => server.reply(200, jsonResponse),
      );

      when(() => mockAgent.generateItinerary(any()))
          .thenAnswer((_) async => jsonResponse);

      when(() => mockIsar.writeTxn(any())).thenAnswer((_) async {});

      // Act
      final trip = await repository.generateTrip('user-request');

      // Assert
      expect(trip, isA<Trip>());
      expect(trip.title, equals('Paris Adventure'));
      expect(trip.startDate, equals(DateTime(2024, 6, 1)));
      expect(trip.endDate, equals(DateTime(2024, 6, 7)));
      expect(trip.days.length, equals(2));

      // Test first day
      final firstDay = trip.days[0];
      expect(firstDay.date, equals(DateTime(2024, 6, 1)));
      expect(firstDay.summary, equals('Arrival and city exploration'));
      expect(firstDay.items.length, equals(2));

      // Test first activity
      final firstActivity = firstDay.items[0];
      expect(firstActivity.time, equals('09:00'));
      expect(firstActivity.activity, equals('Arrive at Charles de Gaulle Airport'));
      expect(firstActivity.location, equals('49.0097,2.5479'));
      expect(firstActivity.latitude, closeTo(49.0097, 0.0001));
      expect(firstActivity.longitude, closeTo(2.5479, 0.0001));
    });

    test('should handle invalid JSON schema gracefully', () async {
      // Arrange
      final invalidJson = {
        "title": "Invalid Trip",
        // Missing required fields
        "days": [
          {
            "date": "invalid-date",
            "items": []
          }
        ]
      };

      when(() => mockAgent.generateItinerary(any()))
          .thenAnswer((_) async => invalidJson);

      // Act & Assert
      expect(
            () => repository.generateTripItinerary('user-request'),
        throwsA(isA<FormatException>()),
      );
    });

    test('should save generated trip to local database', () async {
      // Arrange
      final validJson = {
        "title": "Test Trip",
        "startDate": "2024-07-01",
        "endDate": "2024-07-03",
        "days": [
          {
            "date": "2024-07-01",
            "summary": "Day 1",
            "items": [
              {
                "time": "10:00",
                "activity": "Activity 1",
                "location": "40.7128,-74.0060"
              }
            ]
          }
        ]
      };

      when(() => mockAgent.generateItinerary(any()))
          .thenAnswer((_) async => validJson);

      when(() => mockIsar.writeTxn(any())).thenAnswer((_) async {});

      // Act
      final trip = await repository.generateTripItinerary('user-request');

      // Assert
      expect(trip.title, equals('Test Trip'));
      verify(() => mockIsar.writeTxn(any())).called(1);
    });

    test('should export trip to JSON schema format', () async {
      // Arrange
      final trip = Trip()
        ..title = 'Export Test'
        ..startDate = DateTime(2024, 8, 1)
        ..endDate = DateTime(2024, 8, 3)
        ..days = [
          TripDay()
            ..date = DateTime(2024, 8, 1)
            ..summary = 'First day'
            ..items = [
              TripItem()
                ..time = '09:00'
                ..activity = 'Morning activity'
                ..location = '37.7749,-122.4194'
            ]
        ];

      // Act
      final jsonMap = trip.toJson();

      // Assert
      expect(jsonMap['title'], equals('Export Test'));
      expect(jsonMap['startDate'], equals('2024-08-01T00:00:00.000Z'));
      expect(jsonMap['endDate'], equals('2024-08-03T00:00:00.000Z'));
      expect(jsonMap['days'], isA<List>());

      final firstDay = jsonMap['days'][0];
      expect(firstDay['summary'], equals('First day'));
      expect(firstDay['items'], isA<List>());

      final firstItem = firstDay['items'][0];
      expect(firstItem['time'], equals('09:00'));
      expect(firstItem['activity'], equals('Morning activity'));
      expect(firstItem['location'], equals('37.7749,-122.4194'));
    });

    test('should validate location format', () {
      // Test valid location format
      final validItem = TripItem()
        ..time = '10:00'
        ..activity = 'Test'
        ..location = '40.7128,-74.0060';

      expect(validItem.latitude, closeTo(40.7128, 0.0001));
      expect(validItem.longitude, closeTo(-74.0060, 0.0001));

      // Test invalid location format
      final invalidItem = TripItem()
        ..time = '10:00'
        ..activity = 'Test'
        ..location = 'invalid-coordinates';

      expect(() => invalidItem.latitude, throwsA(isA<FormatException>()));
      expect(() => invalidItem.longitude, throwsA(isA<FormatException>()));
    });
  });
}