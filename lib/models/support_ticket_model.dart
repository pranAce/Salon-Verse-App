class TicketMessage {
  final String sender;
  final String message;
  final String sentAt;

  TicketMessage({
    required this.sender,
    required this.message,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() {
    return {'sender': sender, 'message': message, 'sentAt': sentAt};
  }

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      sender: json['sender']?.toString() ?? 'user',
      message: (json['message'] ?? json['body'])?.toString() ?? '',
      sentAt: (json['sentAt'] ?? json['createdAt'])?.toString() ?? '',
    );
  }
}

class SupportTicketModel {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String message;
  final String status;
  final List<TicketMessage> messages;
  final String createdAt;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.message,
    this.status = 'Open',
    this.messages = const [],
    required this.createdAt,
  });

  SupportTicketModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? subject,
    String? message,
    String? status,
    List<TicketMessage>? messages,
    String? createdAt,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'subject': subject,
      'message': message,
      'status': status,
      'messages': messages.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
    };
  }

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      userId: (json['userId'] ?? json['user'])?.toString() ?? '',
      userName: json['userName'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'Open',
      messages: (json['messages'] as List? ?? [])
          .map((e) => TicketMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['createdAt'] ?? '',
    );
  }
}
