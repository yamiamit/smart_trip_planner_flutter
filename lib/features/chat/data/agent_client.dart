import 'dart:convert';
import 'package:dio/dio.dart';
import '../../trips/data/trip.dart';

/// Represents a chat message in the conversation history
class ChatMessage {
  final String role; // 'user' or 'model'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'parts': [{'text': content}]
  };
}

/// Represents available functions/tools for the LLM
class FunctionDefinition {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  FunctionDefinition({
    required this.name,
    required this.description,
    required this.parameters,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'parameters': parameters,
  };
}

/// Represents a function call from the LLM
class FunctionCall {
  final String name;
  final Map<String, dynamic> arguments;

  FunctionCall({required this.name, required this.arguments});

  factory FunctionCall.fromJson(Map<String, dynamic> json) {
    return FunctionCall(
      name: json['name'] ?? '',
      arguments: json['args'] ?? {},
    );
  }
}

class AgentClient {
  final Dio dio;
  final String apiKey;

  AgentClient(this.dio, this.apiKey);

  final systemPrompt = '''
You are an intelligent travel planning assistant with access to various tools and functions.

Your primary goal is to help users create, modify, and optimize travel itineraries based on their requests.

CRITICAL RESPONSE REQUIREMENTS:
1. ALWAYS respond with ONLY a valid JSON object - NO other text, explanations, or formatting
2. DO NOT use markdown code blocks (```json or ```) 
3. DO NOT add any text before or after the JSON
4. DO NOT include explanatory text or comments
5. Return ONLY the raw JSON object starting with { and ending with }

ITINERARY MODIFICATION RULES:
1. When updating an existing itinerary, preserve all unchanged elements
2. Only modify the specific parts requested by the user
3. Always maintain the correct JSON schema for trip data
4. Use available functions/tools when appropriate for getting current information
5. Consider chat history context when making modifications

REQUIRED JSON SCHEMA:
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

REMEMBER: Return ONLY the JSON object. No explanations, no markdown, no additional text.
''';

  /// Available functions/tools for the LLM
  List<FunctionDefinition> get availableFunctions => [
    FunctionDefinition(
        name: 'get_weather_info',
        description: 'Get current weather information for a specific location and date',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {
              'type': 'string',
              'description': 'City name or location'
            },
            'date': {
              'type': 'string',
              'description': 'Date in YYYY-MM-DD format'
            }
          },
          'required': ['location', 'date']
        }
    ),
    FunctionDefinition(
        name: 'search_attractions',
        description: 'Search for tourist attractions and points of interest',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {
              'type': 'string',
              'description': 'City or area to search in'
            },
            'category': {
              'type': 'string',
              'description': 'Type of attraction (museums, restaurants, parks, etc.)'
            },
            'preferences': {
              'type': 'string',
              'description': 'User preferences or requirements'
            }
          },
          'required': ['location']
        }
    ),
    FunctionDefinition(
        name: 'get_transportation_options',
        description: 'Get transportation options between locations',
        parameters: {
          'type': 'object',
          'properties': {
            'from': {
              'type': 'string',
              'description': 'Starting location'
            },
            'to': {
              'type': 'string',
              'description': 'Destination location'
            },
            'date': {
              'type': 'string',
              'description': 'Travel date in YYYY-MM-DD format'
            },
            'transport_type': {
              'type': 'string',
              'description': 'Preferred transport type (flight, train, car, etc.)'
            }
          },
          'required': ['from', 'to', 'date']
        }
    ),
    FunctionDefinition(
        name: 'validate_itinerary',
        description: 'Validate the feasibility of an itinerary (timing, distances, etc.)',
        parameters: {
          'type': 'object',
          'properties': {
            'itinerary': {
              'type': 'object',
              'description': 'The complete itinerary object to validate'
            }
          },
          'required': ['itinerary']
        }
    )
  ];

  /// Execute a function call (mock implementations)
  Future<Map<String, dynamic>> executeFunction(FunctionCall functionCall) async {
    switch (functionCall.name) {
      case 'get_weather_info':
        return await _getWeatherInfo(functionCall.arguments);
      case 'search_attractions':
        return await _searchAttractions(functionCall.arguments);
      case 'get_transportation_options':
        return await _getTransportationOptions(functionCall.arguments);
      case 'validate_itinerary':
        return await _validateItinerary(functionCall.arguments);
      default:
        return {'error': 'Unknown function: ${functionCall.name}'};
    }
  }

  /// Mock function implementations (replace with real implementations)
  Future<Map<String, dynamic>> _getWeatherInfo(Map<String, dynamic> args) async {
    return {
      'location': args['location'],
      'date': args['date'],
      'temperature': '22°C',
      'condition': 'Partly cloudy',
      'humidity': '65%',
      'recommendation': 'Good weather for outdoor activities'
    };
  }

  Future<Map<String, dynamic>> _searchAttractions(Map<String, dynamic> args) async {
    return {
      'location': args['location'],
      'attractions': [
        {
          'name': 'Popular Museum',
          'category': 'Museum',
          'rating': 4.5,
          'location': '35.6762,139.6503',
          'description': 'Famous local museum with great exhibits'
        },
        {
          'name': 'Central Park',
          'category': 'Park',
          'rating': 4.7,
          'location': '35.6762,139.6503',
          'description': 'Beautiful park perfect for walking'
        }
      ]
    };
  }

  Future<Map<String, dynamic>> _getTransportationOptions(Map<String, dynamic> args) async {
    return {
      'from': args['from'],
      'to': args['to'],
      'options': [
        {
          'type': 'Train',
          'duration': '2h 30m',
          'cost': '\$45',
          'recommendation': 'Most convenient option'
        },
        {
          'type': 'Flight',
          'duration': '1h 15m',
          'cost': '\$120',
          'recommendation': 'Fastest option'
        }
      ]
    };
  }

  Future<Map<String, dynamic>> _validateItinerary(Map<String, dynamic> args) async {
    return {
      'valid': true,
      'issues': [],
      'suggestions': ['Consider adding buffer time between activities']
    };
  }

  /// Main method for iterative trip planning with function calling
  Future<Trip> generateTrip({
    required String userPrompt,
    String? previousItineraryJson,
    List<ChatMessage>? chatHistory,
    int maxRetries = 3,
  }) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print("Attempt $attempt of $maxRetries");

        // Build the conversation context
        List<Map<String, dynamic>> contents = [];

        // Add chat history if provided
        if (chatHistory != null && chatHistory.isNotEmpty) {
          contents.addAll(chatHistory.map((msg) => msg.toJson()));
        }

        // Build the current user message with context
        String contextualPrompt = systemPrompt;

        if (previousItineraryJson != null && previousItineraryJson.isNotEmpty) {
          contextualPrompt += "\n\nPREVIOUS ITINERARY:\n$previousItineraryJson";
        }

        contextualPrompt += "\n\nUSER REQUEST:\n$userPrompt";

        contents.add({
          'role': 'user',
          'parts': [{'text': contextualPrompt}]
        });

        // Get response with function calling
        final rawResponse = await _fetchWithFunctionCalling(contents);
        print("Raw Gemini Response: $rawResponse");

        // Clean and parse JSON
        final cleanedJson = _cleanJson(rawResponse);
        print("Cleaned JSON: $cleanedJson");

        // Validate and parse
        if (cleanedJson.isEmpty || !cleanedJson.contains('{')) {
          throw FormatException("No JSON content found in response: $cleanedJson");
        }

        if (!_isValidJsonStructure(cleanedJson)) {
          throw FormatException("Invalid JSON structure received from Gemini API");
        }

        //return Trip(cleanedJson);
        final parsed = jsonDecode(cleanedJson);
        return Trip.fromJson(parsed);

      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        print("Attempt $attempt failed: $e");

        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    throw lastException ?? Exception("All retry attempts failed");
  }

  /// Fetch response with function calling support
  Future<String> _fetchWithFunctionCalling(List<Map<String, dynamic>> contents) async {
    try {
      // Prepare the request with function calling enabled
      Map<String, dynamic> requestData = {
        "contents": contents,
        "tools": [
          {
            "function_declarations": availableFunctions.map((f) => f.toJson()).toList()
          }
        ],
        "tool_config": {
          "function_calling_config": {
            "mode": "AUTO"
          }
        }
      };

      final response = await dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
        data: jsonEncode(requestData),
      );

      final decoded = response.data;

      if (decoded == null ||
          decoded['candidates'] == null ||
          decoded['candidates'].isEmpty) {
        throw Exception("Invalid Gemini API response structure");
      }

      final candidate = decoded['candidates'][0];
      final content = candidate['content'];

      if (content == null) {
        throw Exception("No content in API response");
      }

      // Check if the model wants to call functions
      if (content['parts'] != null) {
        for (var part in content['parts']) {
          if (part['functionCall'] != null) {
            // Handle function call
            final functionCall = FunctionCall.fromJson(part['functionCall']);
            final functionResult = await executeFunction(functionCall);

            // Add function call and result to conversation
            contents.add({
              'role': 'model',
              'parts': [{'functionCall': part['functionCall']}]
            });

            contents.add({
              'role': 'function',
              'parts': [{'functionResponse': {
                'name': functionCall.name,
                'response': functionResult
              }}]
            });

            // Make another request with the function result
            return await _getContinuedResponse(contents);
          }
        }
      }

      // Extract the text response
      if (content['parts'] != null && content['parts'].isNotEmpty) {
        final rawText = content['parts'][0]['text'];
        if (rawText != null) {
          return rawText.toString();
        }
      }

      throw Exception("No text response from Gemini API");

    } on DioException catch (e) {
      throw Exception("Gemini API network error: ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("Gemini API error: $e");
    }
  }

  /// Continue the conversation after function calls
  Future<String> _getContinuedResponse(List<Map<String, dynamic>> contents) async {
    final response = await dio.post(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
      options: Options(
        headers: {"Content-Type": "application/json"},
      ),
      data: jsonEncode({
        "contents": contents,
        "tools": [
          {
            "function_declarations": availableFunctions.map((f) => f.toJson()).toList()
          }
        ],
      }),
    );

    final decoded = response.data;
    final candidate = decoded['candidates'][0];
    final content = candidate['content'];

    if (content['parts'] != null && content['parts'].isNotEmpty) {
      final rawText = content['parts'][0]['text'];
      if (rawText != null) {
        return rawText.toString();
      }
    }

    throw Exception("No final response from Gemini API");
  }

  /// Enhanced JSON cleaning method
  String _cleanJson(String raw) {
    if (raw.isEmpty) return raw;

    print("Original raw response: '$raw'");

    raw = raw.trim();

    // Remove markdown code blocks
    raw = raw.replaceFirst(RegExp(r'^```(?:json|JSON)?\s*\n?', multiLine: true), '');
    raw = raw.replaceFirst(RegExp(r'\n?\s*```\s*$', multiLine: true), '');
    raw = raw.replaceAll(RegExp(r'^```.*?\n', multiLine: true), '');
    raw = raw.replaceAll(RegExp(r'\n```.*?$', multiLine: true), '');

    raw = raw.trim();

    print("After markdown removal: '$raw'");

    // Extract JSON content between first { and last }
    int firstBrace = raw.indexOf('{');
    int lastBrace = raw.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      raw = raw.substring(firstBrace, lastBrace + 1);
    }

    // Remove common AI response patterns
    raw = raw.replaceAll(RegExp(r"^Here's.*?:\s*", multiLine: true), '');
    raw = raw.replaceAll(RegExp(r'^Here is.*?:\s*', multiLine: true), '');
    raw = raw.replaceAll(RegExp(r'^\*\*.*?\*\*\s*', multiLine: true), '');

    raw = raw.trim();

    print("Final cleaned JSON: '$raw'");

    return raw;
  }

  /// Validate JSON structure before parsing
  bool _isValidJsonStructure(String jsonStr) {
    try {
      final parsed = jsonDecode(jsonStr);

      if (parsed is! Map<String, dynamic>) return false;

      final requiredFields = ['title', 'startDate', 'endDate', 'days'];
      for (String field in requiredFields) {
        if (!parsed.containsKey(field)) return false;
      }

      if (parsed['days'] is! List) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      await generateTrip(userPrompt: "Generate a simple 1-day trip to Tokyo");
      return true;
    } catch (e) {
      print("Connection test failed: $e");
      return false;
    }
  }
}