class SSHListData {
  final int? id;
  final String hostName;
  final String userName;
  final String password;
  final int port;

  SSHListData({
    this.id,
    required this.hostName,
    required this.userName,
    required this.password,
    required this.port,
  });

  factory SSHListData.fromMap(Map<String, dynamic> map) {
    return SSHListData(
      id: map['id'] as int?,
      hostName: map['hostName'] as String,
      userName: map['userName'] as String,
      password: map['password'] as String,
      port: map['port'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hostName': hostName,
      'userName': userName,
      'password': password,
      'port': port,
    };
  }
}
