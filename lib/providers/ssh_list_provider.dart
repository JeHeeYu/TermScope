import 'package:flutter/foundation.dart';
import 'package:termscope/database/database_manager.dart';
import 'package:termscope/datas/ssh_list_data.dart';

class SSHListProvider extends ChangeNotifier {
  List<SSHListData> _sshList = [];
  List<SSHListData> get sshList => _sshList;

  SSHListProvider() {
    loadSSHList();
  }

  Future<void> loadSSHList() async {
    print("loadSSHLIst");
    final dbData = await DatabaseManager().getSSHList();
    print('Database raw data: $dbData');
    _sshList = dbData.map((item) => SSHListData.fromMap(item)).toList();

    print('Converted SSH list: $_sshList');

    notifyListeners();
  }

  Future<void> addSSH(SSHListData sshData) async {
    await DatabaseManager().insertSSH(sshData.toMap());
    _sshList.add(sshData);

    notifyListeners();
  }
}
