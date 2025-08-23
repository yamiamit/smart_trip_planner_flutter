import 'dart:convert';
import 'package:dio/dio.dart';
import '../../trips/data/trip.dart'; // adjust path if needed

class AgentClient {
  final Dio dio;
  final String apiKey;

  AgentClient(this.dio, this.apiKey);

  final systemPrompt = '''
You are a travel planning assistant. 
Always respond ONLY in the following JSON schema without any markdown formatting or code blocks:

{
  "title": "Trip title",
  "startDate": "YYYY-MM-DD",
  "endDate": "YYYY-MM-DD",
  "days": [
    {
      "date": "YYYY-MM-DD",
      "summary": "Short summary of the day",
      "items": [
        { "time": "HH:MM", "activity": "Activity name", "location": "lat,long" }
      ]
    }
  ]
}

IMPORTANT: Return only valid JSON without any ```json or ``` wrapper tags.
''';

  Future<String> fetchTripPlan(String userPrompt) async {
    try {
      final response = await dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": "$systemPrompt\n$userPrompt"}
              ]
            }
          ]
        }),
      );

      final decoded = response.data;
      print(decoded);

      // Check if the response structure is valid
      if (decoded == null ||
          decoded['candidates'] == null ||
          decoded['candidates'].isEmpty ||
          decoded['candidates'][0]['content'] == null ||
          decoded['candidates'][0]['content']['parts'] == null ||
          decoded['candidates'][0]['content']['parts'].isEmpty) {
        throw Exception("Invalid Gemini API response structure");
      }

      // Extract text from Gemini's response structure
      final rawText = decoded['candidates'][0]['content']['parts'][0]['text'];

      if (rawText == null || rawText.toString().trim().isEmpty) {
        throw Exception("Empty response from Gemini API");
      }

      return rawText.toString();

    } on DioException catch (e) {
      throw Exception("Gemini API network error: ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("Gemini API error: $e");
    }
  }

  /// Comprehensive JSON cleaning method
  String cleanJson(String raw) {
    if (raw.isEmpty) return raw;

    raw = raw.trim();

    // Remove markdown code blocks (```json, ```, etc.)
    if (raw.startsWith('```')) {
      // Find the first newline after the opening ```
      int firstNewline = raw.indexOf('\n');
      if (firstNewline != -1) {
        raw = raw.substring(firstNewline + 1);
      } else {
        // No newline found, remove ```json or ``` at start
        raw = raw.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      }
    }

    // Remove trailing ```
    if (raw.endsWith('```')) {
      raw = raw.replaceFirst(RegExp(r'```$'), '');
    }

    // Remove any remaining leading/trailing whitespace
    raw = raw.trim();

    // Remove any text before the first { and after the last }
    int firstBrace = raw.indexOf('{');
    int lastBrace = raw.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      raw = raw.substring(firstBrace, lastBrace + 1);
    }

    return raw;
  }

  /// Validate JSON structure before parsing
  bool isValidJsonStructure(String jsonStr) {
    try {
      final parsed = jsonDecode(jsonStr);

      // Check if it's a Map and has required fields
      if (parsed is! Map<String, dynamic>) return false;

      final requiredFields = ['title', 'startDate', 'endDate', 'days'];
      for (String field in requiredFields) {
        if (!parsed.containsKey(field)) return false;
      }

      // Check if days is a list
      if (parsed['days'] is! List) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// High-level method: fetch JSON, then map it to Trip model
  Future<Trip> generateTrip(String userPrompt) async {
    try {
      // Step 1: Fetch raw response from Gemini
      final rawResponse = await fetchTripPlan(userPrompt);
      print("Raw Gemini Response: $rawResponse");

      // Step 2: Clean the JSON
      final cleanedJson = cleanJson(rawResponse);
      print("Cleaned JSON: $cleanedJson");

      // Step 3: Validate JSON structure
      if (!isValidJsonStructure(cleanedJson)) {
        throw FormatException("Invalid JSON structure received from Gemini API");
      }

      // Step 4: Parse JSON
      final parsed = jsonDecode(cleanedJson);

      // Step 5: Convert to Trip model
      return Trip.fromJson(parsed);

    } on FormatException catch (e) {
      throw Exception("JSON parsing error: ${e.message}. Please try again.");
    } catch (e) {
      throw Exception("Trip generation failed: $e");
    }
  }

  /// Alternative method with retry logic
  Future<Trip> generateTripWithRetry(String userPrompt, {int maxRetries = 3}) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print("Attempt $attempt of $maxRetries");
        return await generateTrip(userPrompt);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        print("Attempt $attempt failed: $e");

        if (attempt < maxRetries) {
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    throw lastException ?? Exception("All retry attempts failed");
  }

  /// Method to test the API connection
  Future<bool> testConnection() async {
    try {
      await fetchTripPlan("Generate a simple 1-day trip to Tokyo");
      return true;
    } catch (e) {
      print("Connection test failed: $e");
      return false;
    }
  }
}