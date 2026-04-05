class User {
  final int id;
  final String name;
  final String surname;
  final String dateNais;
  final String created_at;
  final String email;
  final String password;
  final String rememberToken;
  final String consent;
  final int filiereId;
  final int objectifId;
  final String role;
  final bool is_active;
  final int note_app; // Nouvel attribut note_app

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.dateNais,
    required this.created_at,
    required this.email,
    required this.password,
    required this.rememberToken,
    required this.consent,
    required this.filiereId,
    required this.objectifId,
    required this.role,
    required this.is_active,
    required this.note_app, // Initialisation de note_app
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      dateNais: json['dateNais'] ?? '',
      created_at: json['Date de création'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      rememberToken: json['remember_token'] ?? '',
      consent: json['consent'] ?? '',
      filiereId: json['filiere_id'] ?? 0,
      objectifId: json['objectif_id'] ?? 0,
      role: json['role'] ?? '',
      is_active: json['is_active'] ?? true,
      note_app: json['note_app'] ?? 0, // Lecture de la valeur de note_app depuis JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'dateNais': dateNais,
      'created_at':created_at,
      'email': email,
      'password': password,
      'remember_token': rememberToken,
      'consent': consent,
      'filiere_id': filiereId,
      'objectif_id': objectifId,
      'role': role,
      'is_active': is_active,
      'note_app': note_app, // Ajout de note_app dans la sortie JSON
    };
  }
}
