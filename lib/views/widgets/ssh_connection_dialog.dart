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

  @override
  void dispose() {
    _hostNameController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _portController.dispose();
    super.dispose();
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
              decoration: const InputDecoration(labelText: 'Port'),
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
          onPressed: () {
            final String hostName = _hostNameController.text;
            final String userName = _userNameController.text;
            final String password = _passwordController.text;
            final String port = _portController.text;

            print('Host Name: $hostName');
            print('User Name: $userName');
            print('Password: $password');
            print('Port: $port');

            Navigator.pop(context);
          },
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
