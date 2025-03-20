class ServerConfig {
  String server;

  ServerConfig({required this.server});

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      server: json['server'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server': server,
    };
  }
}
