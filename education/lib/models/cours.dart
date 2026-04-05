class Cours {
  int id;
  String pdf_file_name;
  String pdf_file;
  String filiere_id;
  final String filiere;
  bool isFavorite;

  Cours({
    required this.id,
    required this.pdf_file_name,
    required this.pdf_file,
    required this.filiere_id,
    required this.filiere,
    this.isFavorite = false,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['id'],
      pdf_file_name: json['pdf_file_name'],
      filiere_id: json['filiere_id'],
      pdf_file: json['pdf_file'],
      filiere: json['filiere'],
      isFavorite: json['isFavorite'],
      //userId: json['user_id'],
      //roleUser: json['role_user'],
      // Mappez d'autres attributs depuis le JSON au besoin
    );
  }
}
