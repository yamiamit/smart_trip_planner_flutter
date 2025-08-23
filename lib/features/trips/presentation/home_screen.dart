import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import '../../trips/data/trip_repo.dart';
import '../../trips/data/trip.dart';
import '../../chat/presentation/chat_screen.dart';
import 'itinery_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Trip> savedTrips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTrips();
    _debugDatabase(); // Add this for troubleshooting
  }

  // Debug method to check database state
  Future<void> _debugDatabase() async {
    final repo = RepositoryProvider.of<TripRepo>(context);
    final count = await repo.getTripCount();
    print('Database contains $count trips');
  }

  Future<void> _loadSavedTrips() async {
    final repo = RepositoryProvider.of<TripRepo>(context);
    try {
      final trips = await repo.getAllTrips();
      setState(() {
        savedTrips = trips;
        isLoading = false;
      });
      print('Loaded ${trips.length} trips in UI');
    } catch (e) {
      print('Error loading trips in UI: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteTrip(Trip trip) async {
    final repo = RepositoryProvider.of<TripRepo>(context);
    try {
      final success = await repo.deleteTrip(trip.id);
      if (success) {
        await _loadSavedTrips(); // Refresh the list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${trip.title} deleted'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        throw Exception('Delete operation returned false');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedTrips,
          ),
          // Add debug button (remove in production)
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugDatabase,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        ).then((_) => _loadSavedTrips()), // Refresh when returning
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedTrips.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.luggage, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No saved trips yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to create your first trip',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadSavedTrips,
        child: ListView.builder(
          itemCount: savedTrips.length,
          itemBuilder: (context, index) {
            final trip = savedTrips[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(trip.title[0].toUpperCase()),
                ),
                title: Text(
                  trip.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip.startDate.toLocal().toString().split(" ")[0]} → ${trip.endDate.toLocal().toString().split(" ")[0]}',
                    ),
                    Text(
                      '${trip.days.length} days • ID: ${trip.id}', // Show ID for debugging
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(trip),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ItineraryView(trip: trip),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(Trip trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: Text('Are you sure you want to delete "${trip.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTrip(trip);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}