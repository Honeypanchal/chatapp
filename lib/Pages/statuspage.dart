import 'package:chatapp/services/status_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Status.dart';

class StatusPage extends StatefulWidget {
  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final StatusService _statusService = StatusService();
  final TextEditingController _statusController = TextEditingController();

  void _uploadTextStatus() {
    if (_statusController.text.trim().isNotEmpty) {
      _statusService.uploadStatus(_statusController.text.trim());
      _statusController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Status',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: width * 0.06),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _statusController,
                    decoration: InputDecoration(
                      hintText: 'Enter your status...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.black),
                  onPressed: _uploadTextStatus,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Status>>(
              stream: _statusService.getStatuses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No statuses available'),
                  );
                }

                List<Status> statuses = snapshot.data!;

                return ListView.builder(
                  itemCount: statuses.length,
                  itemBuilder: (context, index) {
                    Status status = statuses[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(status.username[0].toUpperCase()), // Display first letter of username
                      ),
                      title: Text(status.username),
                      subtitle: Text(status.text),
                      trailing: Text(
                        '${status.timestamp.toDate().hour}:${status.timestamp.toDate().minute}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewStatusScreen(status: status),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ViewStatusScreen extends StatelessWidget {
  final Status status;
  final StatusService _statusService = StatusService();

  ViewStatusScreen({required this.status});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _statusService.markStatusAsViewed(status.uid);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Status View')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            status.text,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
