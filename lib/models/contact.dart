import 'package:hive/hive.dart';

class Contact extends HiveObject {
  final String id;
  final String username;
  final String? phone;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  Contact({
    required this.id,
    required this.username,
    this.phone,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
  });

  Contact copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
  }) {
    return Contact(
      id: id,
      username: username,
      phone: phone,
      avatarUrl: avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }
}

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 1;

  @override
  Contact read(BinaryReader reader) {
    return Contact(
      id: reader.read(),
      username: reader.read(),
      phone: reader.read(),
      avatarUrl: reader.read(),
      lastMessage: reader.read(),
      lastMessageTime: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer.write(obj.id);
    writer.write(obj.username);
    writer.write(obj.phone);
    writer.write(obj.avatarUrl);
    writer.write(obj.lastMessage);
    writer.write(obj.lastMessageTime);
  }
}
