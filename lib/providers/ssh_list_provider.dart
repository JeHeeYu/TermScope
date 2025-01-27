import 'package:dartssh2/dartssh2.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:termscope/database/database_manager.dart';
import 'package:termscope/datas/ssh_list_data.dart';
import 'package:xterm/xterm.dart';

class SSHListProvider extends ChangeNotifier {
  List<SSHListData> _sshList = [];
  List<SSHListData> get sshList => _sshList;

  final List<Terminal> terminals = [];
  final List<SSHClient?> clients = [];
  final List<String> tabTitles = [];

  int? hoveredIndex;

  SSHListProvider() {
    loadSSHList();
  }

  Future<void> loadSSHList() async {
    final dbData = await DatabaseManager().getSSHList();
    _sshList = dbData.map((item) => SSHListData.fromMap(item)).toList();
    notifyListeners();
  }

  Future<void> addSSH(SSHListData sshData) async {
    await DatabaseManager().insertSSH(sshData.toMap());
    _sshList.add(sshData);
    notifyListeners();
  }

  Future<void> removeSSH(int id) async {
    await DatabaseManager().deleteSSH(id);
    _sshList.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void addTerminal(Terminal terminal, String title, SSHClient? client) {
    terminals.add(terminal);
    tabTitles.add(title);
    clients.add(client);
    notifyListeners();
  }

  void removeTerminal(int index) {
    terminals.removeAt(index);
    tabTitles.removeAt(index);
    clients[index]?.close();
    clients.removeAt(index);
    notifyListeners();
  }

  void updateHoveredIndex(int? index) {
    hoveredIndex = index;
    notifyListeners();
  }

  Future<void> checkSSHConnections() async {
    for (var ssh in _sshList) {
      try {
        final isConnected = await _checkConnection(ssh);
        ssh.isConnected = isConnected;
      } catch (e) {
        ssh.isConnected = false; 
        print('Error checking connection for ${ssh.hostName}:${ssh.port}: $e');
      }
    }
    notifyListeners();
  }

  void startConnectionTimer() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      checkSSHConnections();
    });
  }

  Future<bool> _checkConnection(SSHListData ssh) async {
    try {
      final socket = await SSHSocket.connect(ssh.hostName, ssh.port);

      final client = SSHClient(
        socket,
        username: ssh.userName,
        onPasswordRequest: () => ssh.password,
      );

      print('Connected to ${ssh.hostName}:${ssh.port}');
      client.close();
      await client.done;
      return true;
    } catch (e) {
      print('Connection failed for ${ssh.hostName}:${ssh.port}: $e');
      return false;
    }
  }
}
