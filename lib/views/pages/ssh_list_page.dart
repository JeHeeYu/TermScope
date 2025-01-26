import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';
import 'package:termscope/datas/ssh_list_data.dart';
import 'package:termscope/providers/ssh_list_provider.dart';
import 'package:termscope/static/app_color.dart';
import 'package:termscope/views/widgets/button_icon.dart';

class SSHListPage extends StatefulWidget {
  const SSHListPage({super.key});

  @override
  State<SSHListPage> createState() => _SSHListPageState();
}

class _SSHListPageState extends State<SSHListPage> {
  final terminal = Terminal(maxLines: 10000);
  SSHClient? activeClient;
  bool isTerminalVisible = false;

  @override
  void initState() {
    super.initState();

    // 기존 Provider 초기화 코드 유지
    final provider = Provider.of<SSHListProvider>(context, listen: false);
    provider.loadSSHList().then((_) {
      provider.checkSSHConnections();
    });
    provider.startConnectionTimer();
  }

  @override
  void dispose() {
    activeClient?.close();
    super.dispose();
  }

  Future<void> _connectToSSH(SSHListData sshData) async {
    String inputBuffer = '';

    try {
      setState(() {
        isTerminalVisible = true;
        terminal
            .write('Connecting to ${sshData.hostName}:${sshData.port}...\n');
      });

      final client = SSHClient(
        await SSHSocket.connect(sshData.hostName, sshData.port),
        username: sshData.userName,
        onPasswordRequest: () => sshData.password,
      );

      setState(() {
        activeClient = client;
        terminal.write('Connected to ${sshData.hostName}:${sshData.port}\n');
      });

      final shell = await client.shell();

      shell.stdout.listen((data) {
        terminal.write(utf8.decode(data));
      });

      shell.stderr.listen((data) {
        terminal.write('\x1b[31m${utf8.decode(data)}\x1b[0m');
      });

      terminal.onOutput = (data) {
        for (final char in data.split('')) {
          if (char == '\r' || char == '\n') {
            if (inputBuffer.trim().isNotEmpty) {
              shell.write(Uint8List.fromList(utf8.encode('$inputBuffer\n')));
              inputBuffer = '';
            }
          } else if (char == '\x7F' || char == '\177') {
            if (inputBuffer.isNotEmpty) {
              inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
              terminal.write('\b \b');
            }
          } else {
            inputBuffer += char;
            terminal.write(char);
          }
        }
      };

      await shell.done;
      terminal.write('\nConnection closed.\n');
    } catch (e) {
      terminal.write('Error: $e\n');
      setState(() {
        isTerminalVisible = false;
      });
    }
  }

  Widget _buildSShListArea() {
    return Expanded(
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
                                ? Row(
                                    children: [
                                      ButtonIcon(
                                        icon: Icons.add,
                                        iconColor: Colors.white,
                                        iconSize: 20.0,
                                        callback: () {
                                          _connectToSSH(sshData);
                                        },
                                      ),
                                      ButtonIcon(
                                        icon: Icons.delete,
                                        iconColor: Colors.white,
                                        iconSize: 20.0,
                                        callback: () {
                                          provider.removeSSH(sshData.id);
                                        },
                                      ),
                                    ],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Row(
        children: [
          _buildSShListArea(),
          Expanded(
            flex: 8,
            child: isTerminalVisible
                ? Container(
                    color: Colors.black,
                    child: TerminalView(
                      terminal,
                      autofocus: true,
                      backgroundOpacity: 0.8,
                    ),
                  )
                : const Center(
                    child: Text(
                      'Right Panel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
