import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:termscope/providers/ssh_list_provider.dart';

class SSHListPage extends StatefulWidget {
  const SSHListPage({super.key});

  @override
  State<SSHListPage> createState() => _SSHListPageState();
}

class _SSHListPageState extends State<SSHListPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SSHListProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
    );
  }
}
