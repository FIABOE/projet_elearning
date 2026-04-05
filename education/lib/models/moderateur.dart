class Moderateur {
  final int id;
  final String surname; 
  final String name;
  final String email;
  final DateTime? created_at;
  bool isActive;

  
  Moderateur({
    required this.id,
    required this.surname,
    required this.name,
    required this.email,
    required this.created_at,
    this.isActive = true,
  });

  factory Moderateur.fromJson(Map<String, dynamic> json) {
    return Moderateur(
      id: json['id'],
      surname: json['surname'],
      name: json['name'],
      email: json['email'],
      created_at: json['Date de création'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surname': surname,
      'name': name,
      'email': email,
      'Date de création': created_at,
    };
  }

  factory Moderateur.fromMap(Map<String, dynamic> map) {
    return Moderateur(
      id: map['id'],
      name: map['name'],
      surname:  map['surname'],
      email:  map['email'],
      created_at: map['Date de création'],
    );
  }

}