class SSHListData {
  final int id;
  final String sshName;
  final String hostName;
  final String userName;
  final String password;
  final int port;
  bool isConnected;
  final DateTime createdAt;
  final DateTime updatedAt;

  SSHListData({
    required this.id,
    required this.sshName,
    required this.hostName,
    required this.userName,
    required this.password,
    required this.port,
    this.isConnected = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SSHListData.fromMap(Map<String, dynamic> map) {
    return SSHListData(
      id: map['id'] as int,
      sshName: map['sshName'] as String,
      hostName: map['hostName'] as String,
      userName: map['userName'] as String,
      password: map['password'] as String,
      port: map['port'] as int,
      isConnected: map['isConnected'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sshName': sshName,
      'hostName': hostName,
      'userName': userName,
      'password': password,
      'port': port,
      'isConnected': isConnected,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
