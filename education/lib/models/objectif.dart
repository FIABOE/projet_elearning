class Objectif {
  final int id;
  final String libelle; 

  
  Objectif({
    required this.id,
    required this.libelle,
  });

  factory Objectif.fromJson(Map<String, dynamic> json) {
    return Objectif(
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