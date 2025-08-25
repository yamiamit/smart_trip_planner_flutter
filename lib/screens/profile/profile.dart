import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_trip_planner/screens/welcome/welcome.dart';


class ProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  const ProfileScreen({super.key,required this.name,required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            const SizedBox(height: 32),

            // Token Usage Card
            _buildTokenUsageCard(),

            const Spacer(),

            // Log Out Button
            _buildLogOutButton(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        // Profile Avatar
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D5A),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'A', //hardcoded tesxt as of now
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Profile Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.name}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.email}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTokenUsageCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Request Tokens
          _buildTokenRow(
            label: 'Request Tokens',
            current: 100,
            total: 1000,
            color: const Color(0xFF2E7D5A),
            isRequest: true,
          ),

          const SizedBox(height: 24),

          // Response Tokens
          _buildTokenRow(
            label: 'Response Tokens',
            current: 75,
            total: 1000,
            color: const Color(0xFFE57373),
            isRequest: false,
          ),

          const SizedBox(height: 32),

          // Divider
          Container(
            height: 1,
            color: Colors.grey[200],
          ),

          const SizedBox(height: 24),

          // Total cost hardcoded as of now :(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Cost',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Text(
                '\$0.07 USD',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenRow({
    required String label,
    required int current,
    required int total,
    required Color color,
    required bool isRequest,
  }) {
    final double progress = current / total;

    return Column(
      children: [
        // Label and Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              '$current/$total',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress Bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          _showLogOutDialog(context);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.red[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle log out logic here
                _handleLogOut(context);
              },
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  void _handleLogOut(BuildContext context) async {
    try {
      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      // Clear any other Firebase data if needed
      // For example, if you're using Firestore offline persistence:
      // await FirebaseFirestore.instance.clearPersistence();

      // Navigate to welcome screen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      // Handle logout errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Usage Tracking Model (optional - for state management)
class TokenUsage {
  final int requestTokens;
  final int requestLimit;
  final int responseTokens;
  final int responseLimit;
  final double totalCost;

  TokenUsage({
    required this.requestTokens,
    required this.requestLimit,
    required this.responseTokens,
    required this.responseLimit,
    required this.totalCost,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      requestTokens: json['requestTokens'] ?? 0,
      requestLimit: json['requestLimit'] ?? 1000,
      responseTokens: json['responseTokens'] ?? 0,
      responseLimit: json['responseLimit'] ?? 1000,
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestTokens': requestTokens,
      'requestLimit': requestLimit,
      'responseTokens': responseTokens,
      'responseLimit': responseLimit,
      'totalCost': totalCost,
    };
  }
}


