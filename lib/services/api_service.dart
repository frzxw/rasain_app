import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/supabase_config.dart';

class ApiService {
  // Base URL from Supabase
  final String baseUrl;
  
  // Headers to be included with each request
  Map<String, String> get headers {
    final supabase = SupabaseConfig.client;
    final session = supabase.auth.currentSession;
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'apikey': SupabaseConfig.supabaseAnonKey,
    };
    
    // Add authorization header if user is authenticated
    if (session?.accessToken != null) {
      headers['Authorization'] = 'Bearer ${session!.accessToken}';
    }
    
    return headers;
  }
  
  ApiService() : baseUrl = '${SupabaseConfig.supabaseUrl}/rest/v1';
  
  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(uri, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET request error: $e');
      throw Exception('Failed to make GET request: $e');
    }
  }
  
  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST request error: $e');
      throw Exception('Failed to make POST request: $e');
    }
  }
  
  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT request error: $e');
      throw Exception('Failed to make PUT request: $e');
    }
  }
  
  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.delete(uri, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE request error: $e');
      throw Exception('Failed to make DELETE request: $e');
    }
  }
  
  // Handle response and error cases
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      final message = error['message'] ?? 'Unknown error occurred';
      throw Exception('API Error (${response.statusCode}): $message');
    }
  }
  
  // Upload file (image)
  Future<Map<String, dynamic>> uploadFile(
    String endpoint, 
    List<int> fileBytes, 
    String fileName, 
    String fieldName,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      
      final request = http.MultipartRequest('POST', uri);
        request.headers.addAll({
        'Authorization': headers['Authorization'] ?? '',
        'apikey': headers['apikey'] ?? '',
      });
      
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: fileName,
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('File upload error: $e');
      throw Exception('Failed to upload file: $e');
    }
  }
}
