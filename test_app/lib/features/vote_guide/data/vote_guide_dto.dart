class VoteGuideDTO {
  final String title;
  final String description;

  VoteGuideDTO({required this.title, required this.description});

  // Optional: factory from JSON in future
  factory VoteGuideDTO.fromJson(Map<String, dynamic> json) {
    return VoteGuideDTO(
      title: json['title'],
      description: json['description'],
    );
  }
}
