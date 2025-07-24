import 'package:flutter/material.dart';

class EntryDetail extends StatelessWidget {
  final Map entry;
  const EntryDetail({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry['title'])),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${entry['created_at'].toString().substring(0, 10)}'),
            const SizedBox(height: 10),
            Text('Mood: ${entry['mood']}'),
            const SizedBox(height: 20),
            Text(entry['body']),
          ],
        ),
      ),
    );
  }
}
