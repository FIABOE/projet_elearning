class Apprenant {
  final int id;
  final String surname;
  final String name;
  final String email;
  final String dateNais;
  final String created_at;
  final String filiere;
  final String objectif;
  final dynamic noteApp; 
  bool isActive;

  Apprenant({
    required this.id,
    required this.surname,
    required this.name,
    required this.email,
    required this.dateNais,
    required this.created_at,
    required this.filiere,
    required this.objectif,
    required this.noteApp, // Changer le nom de la variable ici aussi
    this.isActive = true,
  });

  factory Apprenant.fromJson(Map<String, dynamic> json) {
    return Apprenant(
      id: json['id'] ?? 0,
      surname: json['Nom'] ?? '',
      name: json['Prenom'] ?? '',
      email: json['Email'] ?? '',
      dateNais: json['Date de Naissance'] ?? '',
      created_at: json['Date de création'],
      filiere: json['Filiere'] ?? '', 
      objectif: json['Objectif hebdomadaire'] ?? '', 
      noteApp: json['Note de l\'app'], 
    );
  }
}