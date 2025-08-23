import 'package:isar/isar.dart';
import 'trip.dart';
import '../../chat/data/agent_client.dart';

class TripRepo {
  final AgentClient agent;
  final Isar isar;

  TripRepo(this.agent, this.isar);

  /// Generate a new trip using AI and store it locally
  Future<Trip> createTrip(String prompt) async {
    // 1. Call AI to generate trip
    final trip = await agent.generateTrip(prompt);

    // 2. Save to Isar
    await isar.writeTxn(() async {
      await isar.trips.put(trip);
    });

    return trip;
  }

  /// Fetch all previously saved trips
  Future<List<Trip>> getAllTrips() async {
    return await isar.trips.where().findAll();
  }

  Future<bool> deleteTrip(Id id) async {
    try {
      return await isar.writeTxn(() async {
        return await isar.trips.delete(id);
      });
    } catch (e) {
      print('Error deleting trip $id: $e');
      return false;
    }
  }


  Future<Trip?> getTripById(Id id) async {
    try {
      return await isar.trips.get(id);
    } catch (e) {
      print('Error fetching trip $id: $e');
      return null;
    }
  }

  /// Clear all trips (optional utility)
  Future<void> clearTrips() async {
    try {
      await isar.writeTxn(() async {
        await isar.trips.clear();
      });
      print('All trips cleared');
    } catch (e) {
      print('Error clearing trips: $e');
      rethrow;
    }
  }

  Future<int> getTripCount() async {
    try {
      return await isar.trips.count();
    } catch (e) {
      print('Error counting trips: $e');
      return 0;
    }
  }



  Future<List<Trip>> searchTrips(String query) async {
    try {
      return await isar.trips
          .filter()
          .titleContains(query, caseSensitive: false)
          .findAll();
    } catch (e) {
      print('Error searching trips: $e');
      return [];
    }
  }
}






