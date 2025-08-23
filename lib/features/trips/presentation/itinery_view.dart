import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/trip.dart';
import '../data/trip_repo.dart';

class ItineraryView extends StatelessWidget {
  final Trip trip;
  const ItineraryView({super.key, required this.trip});

  Future<void> _launchMapsUrl(String location) async {
    final encodedLocation = Uri.encodeComponent(location);

    // Try different map URLs based on platform
    final urls = [
      'https://www.google.com/maps/search/?api=1&query=$encodedLocation', // Google Maps
      'https://maps.apple.com/?q=$encodedLocation', // Apple Maps
      'geo:0,0?q=$encodedLocation', // Android geo intent
    ];

    for (String urlString in urls) {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // Fallback: show error if no map app can handle the URL
    throw 'Could not launch map for $location';
  }

  void _showMapError(BuildContext context, String location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not open map for $location'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveTrip(BuildContext context) async {
    try {
      final tripRepo = RepositoryProvider.of<TripRepo>(context);

      // Save the trip
      await tripRepo.isar.writeTxn(() async {
        await tripRepo.isar.trips.put(trip);
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to home screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save trip: $e'),
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
        title: Text(trip.title),
        actions: [
          ElevatedButton(
            onPressed: () => _saveTrip(context),
            child: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            trip.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "${trip.startDate.toLocal().toString().split(" ")[0]} → "
                "${trip.endDate.toLocal().toString().split(" ")[0]}",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          ...trip.days.map((day) => Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.date.toLocal().toString().split(" ")[0],
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(day.summary,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  ...day.items.map(
                        (item) => ListTile(
                      leading: Text(item.time),
                      title: Text(item.activity),
                      subtitle: InkWell(
                        onTap: () async {
                          try {
                            await _launchMapsUrl(item.location);
                          } catch (e) {
                            if (context.mounted) {
                              _showMapError(context, item.location);
                            }
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.location,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}