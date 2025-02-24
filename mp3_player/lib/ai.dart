import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class SongDetailsScreen extends StatefulWidget {
  
  const SongDetailsScreen({super.key});

  @override
  State<SongDetailsScreen> createState() => _SongDetailsScreenState();
}

class _SongDetailsScreenState extends State<SongDetailsScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<String> chatMessages = [];
  String apiKey = 'Your api key here :)';

  @override
  void initState() {
    super.initState();
    Gemini.init(apiKey: apiKey, enableDebugging: true);
  }

  Future<void> sendQuestion() async {
    String question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      chatMessages.add("Tú: $question");
      _questionController.clear();
    });

    Gemini.instance.prompt(parts: [Part.text(question)]).then((value) {
      String response = value?.output ?? "No se obtuvo respuesta.";
      setState(() {
        chatMessages.add("Gemini: $response");
      });
    }).catchError((error) {
      setState(() {
        chatMessages.add("Error: No se pudo obtener respuesta");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gemini AI")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(chatMessages[index]),
                  );
                },
              ),
            ),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: "Escribe tu pregunta...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendQuestion,
                ),
              ),
              onSubmitted: (_) => sendQuestion(),
            ),
          ],
        ),
      ),
    );
  }
}
