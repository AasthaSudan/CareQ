import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;

  OpenAIService({required this.apiKey});

  Future<String> sendMessage(String message) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": message}
          ],
          "temperature": 0.7,
          "max_tokens": 500
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage = data['choices'][0]['message']['content'];
        return aiMessage;
      } else {
        print("OpenAI API Error: ${response.statusCode} ${response.body}");
        return "Sorry, I could not process that. Please try again.";
      }
    } catch (e) {
      print("OpenAI Exception: $e");
      return "Sorry, I could not process that. Please try again.";
    }
  }

  Future<String> getAIResponse(String message) async {
    return sendMessage(message);
  }

  Future<String> translateText(String text, String targetLanguage) async {
    final prompt = "Translate this to $targetLanguage: $text";
    return sendMessage(prompt);
  }
}
