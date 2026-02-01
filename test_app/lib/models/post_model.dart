import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorArea;
  final String? authorProfileUrl;
  final String content;
  final String? imageUrl;
  final List<String> likes;
  final int commentsCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorArea,
    this.authorProfileUrl,
    required this.content,
    this.imageUrl,
    this.likes = const [],
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      authorArea: map['authorArea'] ?? 'Unknown',
      authorProfileUrl: map['authorProfileUrl'],
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      likes: List<String>.from(map['likes'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorArea': authorArea,
      'authorProfileUrl': authorProfileUrl,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'commentsCount': commentsCount,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
