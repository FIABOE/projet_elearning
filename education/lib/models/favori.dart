class Favori {
  final int id;
  final int userId;
  final int coursId;

  Favori({
    required this.id,
    required this.userId,
    required this.coursId,
  });

  factory Favori.fromJson(Map<String, dynamic> json) {
    return Favori(
      id: json['id'],
      userId: json['user_id'],
      coursId: json['cours_id'],
    );
  }
}
