import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final Function(BuildContext, Contact) onEdit;
  final Function(int) onDelete;
  final Function(BuildContext, Contact) onViewProfile; // Função para abrir o perfil

  const ContactTile({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onViewProfile, // Passar a função de visualização de perfil
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(contact.id.toString()),
      onDismissed: (direction) {
        onDelete(contact.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${contact.name} foi excluído')));
      },
      child: ListTile(
        onTap: () => onViewProfile(context, contact), // Alterado para chamar o perfil
        title: Text(contact.name),
        subtitle: Text(contact.phone),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(context, contact), // Editar ainda funciona aqui
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onDelete(contact.id),
            ),
          ],
        ),
      ),
    );
  }
}
