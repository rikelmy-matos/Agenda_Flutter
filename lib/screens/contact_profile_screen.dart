import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactProfileScreen extends StatelessWidget {
  final Contact contact;
  final Function(BuildContext, Contact) onEdit;
  final Function(int) onDelete;

  const ContactProfileScreen({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    contact.name[0],  // Mostra a inicial do nome
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nome: ${contact.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Telefone: ${contact.phone}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Email: ${contact.email.isNotEmpty ? contact.email : 'Não informado'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => onEdit(context, contact),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),  // Função para editar
                      child: const Text('Editar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        onDelete(contact.id);  // Função para excluir
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
