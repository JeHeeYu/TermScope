import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:termscope/providers/ssh_list_provider.dart';
import 'package:termscope/static/app_color.dart';
import 'package:termscope/static/strings.dart';

class EditListPage extends StatefulWidget {
  const EditListPage({super.key});

  @override
  State<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  final Set<int> editingIndices = {}; // 수정 중인 항목의 인덱스를 저장하는 Set

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SSHListProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.mainBackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              Strings.editPageTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                SizedBox(
                    width: 50,
                    child: Center(child: Text('ID', style: _headerStyle))),
                Expanded(
                    child:
                        Center(child: Text('SSH Name', style: _headerStyle))),
                Expanded(
                    child:
                        Center(child: Text('User Name', style: _headerStyle))),
                Expanded(
                    child:
                        Center(child: Text('Host Name', style: _headerStyle))),
                Expanded(
                    child:
                        Center(child: Text('Password', style: _headerStyle))),
                Expanded(
                    child: Center(child: Text('Port', style: _headerStyle))),
                SizedBox(width: 80),
              ],
            ),
            const Divider(color: Colors.white, thickness: 1),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                itemCount: provider.sshList.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.grey, thickness: 0.5),
                itemBuilder: (context, index) {
                  final sshData = provider.sshList[index];
                  final isEditing = editingIndices.contains(index);

                  return Row(
                    children: [
                      // ID (수정 불가능)
                      SizedBox(
                        width: 50,
                        height: 40,
                        child: Center(
                          child: Text(
                            sshData.id.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      _buildField(sshData.sshName, isEditing),
                      _buildField(sshData.userName, isEditing),
                      _buildField(sshData.hostName, isEditing),
                      _buildField(sshData.password, isEditing),
                      _buildField(sshData.port.toString(), isEditing),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: isEditing
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () {
                                      setState(() {
                                        editingIndices.remove(index);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        editingIndices.remove(index);
                                      });
                                    },
                                  ),
                                ],
                              )
                            : IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    editingIndices.add(index);
                                  });
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String value, bool isEditing) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: isEditing
              ? Border.all(color: Colors.white, width: 1)
              : null,
        ),
        child: isEditing
            ? TextField(
                controller: TextEditingController(text: value),
                cursorColor: Colors.red,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);
