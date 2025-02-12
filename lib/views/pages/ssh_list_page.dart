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

enum ViewType { listView, folderView }

class SSHListPage extends StatefulWidget {
  const SSHListPage({super.key});

  @override
  State<SSHListPage> createState() => _SSHListPageState();
}

class _SSHListPageState extends State<SSHListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ViewType _currentView = ViewType.listView;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SSHListProvider>(context, listen: false);
    provider.loadSSHList().then((_) => provider.checkSSHConnections());
    provider.startConnectionTimer();
    _updateTabController();
  }

  void _updateTabController() {
    final provider = Provider.of<SSHListProvider>(context, listen: false);
    _tabController =
        TabController(length: provider.terminals.length, vsync: this);
    setState(() {});
  }

  Future<void> _connectToSSH(SSHListData sshData) async {
    final terminal = Terminal(maxLines: 10000);
    final provider = Provider.of<SSHListProvider>(context, listen: false);

    provider.addTerminal(
      terminal,
      sshData.sshName,
      null,
    );

    _updateTabController();

    try {
      final client = SSHClient(
        await SSHSocket.connect(sshData.hostName, sshData.port),
        username: sshData.userName,
        onPasswordRequest: () => sshData.password,
      );

      provider.clients[provider.terminals.indexOf(terminal)] = client;

      final shell = await client.shell();

      final currentPath = await provider.getCurrentPath(client);
      provider.updateCurrentPath(currentPath);

      final folderList = await provider.getFolderList(client, currentPath);
      provider.updateFolderList(folderList);

      shell.stdout.listen((data) => terminal.write(utf8.decode(data)));
      shell.stderr.listen(
          (data) => terminal.write('\x1b[31m${utf8.decode(data)}\x1b[0m'));

      terminal.onOutput = (data) {
        shell.write(Uint8List.fromList(utf8.encode(data)));
      };

      await shell.done;
      terminal.write('\nConnection closed.\n');
    } catch (e) {
      terminal.write('Error: $e\n');
      provider.removeTerminal(provider.terminals.indexOf(terminal));
      _updateTabController();
    }
  }

  void _changeWidgetView(ViewType type) {
    setState(() {
      _currentView = type;
    });
  }

  Widget _buildViewTypeIcons() {
    return Row(
      children: [
        ButtonIcon(
          icon: Icons.format_list_bulleted_outlined,
          iconSize: 22,
          iconColor: _currentView == ViewType.listView
              ? Colors.white
              : AppColor.disable,
          callback: () => _changeWidgetView(ViewType.listView),
        ),
        ButtonIcon(
          icon: Icons.folder_open,
          iconSize: 22,
          iconColor: _currentView == ViewType.folderView
              ? Colors.white
              : AppColor.disable,
          callback: () => _changeWidgetView(ViewType.folderView),
        ),
      ],
    );
  }

  Widget _buildListView(SSHListProvider provider) {
    return Expanded(
      child: Container(
        color: AppColor.mainBackground,
        child: provider.sshList.isEmpty
            ? const Center(
                child: Text(
                  'No SSH connections available',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: provider.sshList.length,
                itemBuilder: (context, index) {
                  final sshData = provider.sshList[index];
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
                                sshData.sshName,
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
                                          callback: () =>
                                              _connectToSSH(sshData),
                                        ),
                                        ButtonIcon(
                                          icon: Icons.delete,
                                          iconColor: Colors.white,
                                          iconSize: 20.0,
                                          callback: () =>
                                              provider.removeSSH(sshData.id),
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
              ),
      ),
    );
  }

  Widget _buildFolderView(SSHListProvider provider) {
    return Expanded(
      child: Container(
        color: AppColor.mainBackground,
        child: provider.folderList.isEmpty
            ? const Center(
                child: Text(
                  'No folders available',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: provider.folderList.length,
                itemBuilder: (context, index) {
                  final folderName = provider.folderList[index];
                  return ListTile(
                    title: Text(
                      folderName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      final client = provider.clients.first;
                      final newPath =
                          '${provider.currentPath}/$folderName'.replaceAll('//', '/');
                      await provider.changeDirectory(client!, newPath);
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSShListArea(SSHListProvider provider) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          _buildViewTypeIcons(),
          (_currentView == ViewType.listView)
              ? _buildListView(provider)
              : _buildFolderView(provider),
        ],
      ),
    );
  }

  Widget _buildTerminalTabs(SSHListProvider provider) {
    return Expanded(
      flex: 8,
      child: Column(
        children: [
          if (provider.tabTitles.isNotEmpty)
            TabBar(
              controller: _tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.white,
              labelPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              tabs: List.generate(
                provider.tabTitles.length,
                (index) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.tabTitles[index]),
                    const SizedBox(width: 8),
                    ButtonIcon(
                      icon: Icons.close,
                      iconColor: _tabController.index == index
                          ? Colors.white
                          : Colors.grey,
                      iconSize: 18,
                      callback: () => provider.removeTerminal(index),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(height: 1, thickness: 1, color: AppColor.divider),
          Expanded(
            child: provider.tabTitles.isNotEmpty
                ? TabBarView(
                    controller: _tabController,
                    children: provider.terminals.map((terminal) {
                      return Container(
                        color: Colors.black,
                        child: TerminalView(
                          terminal,
                          autofocus: true,
                          backgroundOpacity: 0.8,
                        ),
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Text(
                      'No terminal opened',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SSHListProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.mainBackground,
      body: Row(
        children: [
          _buildSShListArea(provider),
          const VerticalDivider(
              thickness: 1, width: 1, color: AppColor.divider),
          _buildTerminalTabs(provider),
        ],
      ),
    );
  }
}
