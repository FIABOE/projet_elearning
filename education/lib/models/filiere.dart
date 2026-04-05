class Filiere {
  final int id;
  final String libelle; 

  
  Filiere({
    required this.id,
    required this.libelle,
  });

  factory Filiere.fromJson(Map<String, dynamic> json) {
    return Filiere(
      id: json['id'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
    };
  }
}