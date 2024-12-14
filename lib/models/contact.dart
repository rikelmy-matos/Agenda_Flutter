class Contact {
  final int id;
  final String name;
  final String phone;
  final String email;

  Contact({required this.id, required this.name, required this.phone, required this.email});

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['nome'],
      phone: map['telefone'],
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': name,
      'telefone': phone,
      'email': email,
    };
  }
}
