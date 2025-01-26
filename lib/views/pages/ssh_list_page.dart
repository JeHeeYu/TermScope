import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:termscope/providers/ssh_list_provider.dart';
import 'package:termscope/static/app_color.dart';
import 'package:termscope/views/widgets/button_icon.dart';

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
    provider.loadSSHList().then((_) {
      provider.checkSSHConnections();
    });
    provider.startConnectionTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: AppColor.mainBackground,
              child: Consumer<SSHListProvider>(
                builder: (context, provider, child) {
                  final sshList = provider.sshList;

                  if (sshList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No SSH connections available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: sshList.length,
                    itemBuilder: (context, index) {
                      final sshData = sshList[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: MouseRegion(
                          onEnter: (_) => provider.updateHoveredIndex(index),
                          onExit: (_) => provider.updateHoveredIndex(null),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${sshData.hostName}:${sshData.port}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: provider.hoveredIndex == index
                                      ? ButtonIcon(
                                          icon: Icons.delete,
                                          iconColor: Colors.white,
                                          iconSize: 20.0,
                                          callback: () {
                                            provider.removeSSH(sshData.id);
                                          },
                                        )
                                      : Icon(
                                          Icons.circle,
                                          size: 16,
                                          color: sshData.isConnected
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              color: Colors.red,
              child: const Center(
                child: Text(
                  'Right Panel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
