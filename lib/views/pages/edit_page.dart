import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:termscope/providers/ssh_list_provider.dart';

class EditListPage extends StatefulWidget {
  const EditListPage({super.key});

  @override
  State<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SSHListProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.red,
    );
  }
}
