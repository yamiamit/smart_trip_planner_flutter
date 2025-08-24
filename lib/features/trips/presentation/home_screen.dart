// Import for ChatBloc
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import '../../trips/data/trip_repo.dart';
import '../../trips/data/trip.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../../chat/bloc/chat_event.dart';
import 'itinery_view.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  const HomeScreen({super.key,required this.name});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Trip> savedTrips = [];
  bool isLoading = true;
  final TextEditingController _visionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedTrips();
  }

  @override
  void dispose() {
    _visionController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedTrips() async {
    final repo = RepositoryProvider.of<TripRepo>(context);
    try {
      final trips = await repo.getAllTrips();
      setState(() {
        savedTrips = trips;
        isLoading = false;
      });
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
        await _loadSavedTrips();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${trip.title} deleted'),
              backgroundColor: Colors.orange,
            ),
          );
        }
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

  void _createItinerary() {
    if (_visionController.text.trim().isNotEmpty) {
      final visionText = _visionController.text.trim();
      // Navigate to chat screen and automatically submit the vision text
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(),
        ),
      ).then((_) {
        _visionController.clear();
        _loadSavedTrips();
      });

      // Submit the vision text immediately after navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ChatBloc>().add(ChatPromptSubmitted(visionText));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting and avatar
              Row(
                children: [
                   Text(
                    'Hey ${widget.name} ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 32),
                  ),
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'S',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Question with dots
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'What\'s your vision for this trip?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  // Dots indicator
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Vision input field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _visionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your perfect trip...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 8, right: 8),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Create Itinerary Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _createItinerary,
                    child: const Center(
                      child: Text(
                        'Create My Itinerary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Offline Saved Itineraries Section
              const Text(
                'Offline Saved Itineraries',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              const SizedBox(height: 16),

              // Saved trips list
              savedTrips.isEmpty
                  ? Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.luggage_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No saved itineraries yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: savedTrips.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final trip = savedTrips[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        _truncateTitle(trip.title),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_horiz),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('Delete'),
                            onTap: () => Future.delayed(
                              const Duration(milliseconds: 100),
                                  () => _showDeleteDialog(trip),
                            ),
                          ),
                        ],
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

              const SizedBox(height: 40),

              // Home indicator
              Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _truncateTitle(String title) {
    if (title.length <= 45) return title;
    return '${title.substring(0, 42)}...';
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
