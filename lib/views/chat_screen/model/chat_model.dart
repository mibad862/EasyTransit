class Message {
  final String id;
  final String msg;
  final String type;
  final String send_by;
  final String send_to;
  final String? reply_id;
  final String? reply_type;
  final int timestamp;
  final Map<String, bool> readBy;

  Message({
    required this.id,
    required this.msg,
    required this.type,
    required this.send_by,
    required this.send_to,
    this.reply_id,
    this.reply_type,
    required this.timestamp,
    required this.readBy,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      msg: json['msg'],
      type: json['type'],
      send_by: json['send_by'],
      send_to: json['send_to'],
      reply_id: json['reply_id'],
      reply_type: json['reply_type'],
      timestamp: json['timestamp'],
      readBy: Map<String, bool>.from(json['readBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'msg': msg,
      'type': type,
      'send_by': send_by,
      'send_to': send_to,
      'reply_id': reply_id,
      'reply_type': reply_type,
      'timestamp': timestamp,
      'readBy': readBy,
    };
  }
}
