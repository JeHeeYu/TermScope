import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';

class SSHConnectionDialog extends StatefulWidget {
  const SSHConnectionDialog({super.key});

  @override
  State<SSHConnectionDialog> createState() => _SSHConnectionDialogState();
}

class _SSHConnectionDialogState extends State<SSHConnectionDialog> {
  final TextEditingController _hostNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  String _connectionStatus = "Not connected";

  @override
  void dispose() {
    _hostNameController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _connectSSH() async {
    final String hostName = _hostNameController.text;
    final String userName = _userNameController.text;
    final String password = _passwordController.text;
    final int port = int.tryParse(_portController.text) ?? 22;

    setState(() {
      _connectionStatus = "Connecting to $hostName:$port...";
    });

    try {
      final socket = await SSHSocket.connect(hostName, port);

      final client = SSHClient(
        socket,
        username: userName,
        onPasswordRequest: () => password,
      );

      setState(() {
        _connectionStatus = "Connected to $hostName:$port";
      });

      final result = await client.execute('echo "Hello, SSH!"');
      print("Command Output: $result");

      // client.close();
      // await client.done;

      // setState(() {
      //   _connectionStatus = "Connection closed";
      // });
    } catch (e) {
      setState(() {
        _connectionStatus = "Connection failed: $e";
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('SSH Connection'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _hostNameController,
              decoration: const InputDecoration(labelText: 'Host Name'),
            ),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: 'User Name'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Port (e.g., 20005)'),
            ),
            const SizedBox(height: 16),
            Text(
              _connectionStatus,
              style: TextStyle(
                color: _connectionStatus.startsWith("Connected") ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _connectSSH,
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
