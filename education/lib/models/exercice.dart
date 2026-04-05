class Exercices {
  int id;
  String pdf_file_name;
  String pdf_file;
  String filiere_id;
  String filiere;
  String reponse; // Ajoutez l'attribut reponse

  Exercices({
    required this.id,
    required this.pdf_file_name,
    required this.pdf_file,
    required this.filiere_id,
    required this.filiere,
    required this.reponse, // Ajoutez le champ de réponse
  });

  factory Exercices.fromJson(Map<String, dynamic> json) {
    return Exercices(
      id: json['id'],
      pdf_file_name: json['pdf_file_name'],
      filiere_id: json['filiere_id'],
      pdf_file: json['pdf_file'],
      filiere: json['filiere'],
      reponse: json['reponse'], // Mappez le champ de réponse
      //userId: json['user_id'],
      //roleUser: json['role_user'],
      // Mappez d'autres attributs depuis le JSON au besoin
    );
  }
}
