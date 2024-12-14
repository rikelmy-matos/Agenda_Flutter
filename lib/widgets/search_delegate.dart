import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactSearchDelegate extends SearchDelegate {
  final List<Contact> contacts;

  ContactSearchDelegate({required this.contacts});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = contacts
        .where((contact) =>
    contact.name.toLowerCase().contains(query.toLowerCase()) ||
        contact.phone.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final contact = results[index];
        return ListTile(
          title: Text(contact.name),
          subtitle: Text(contact.phone),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = contacts
        .where((contact) =>
    contact.name.toLowerCase().contains(query.toLowerCase()) ||
        contact.phone.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final contact = suggestions[index];
        return ListTile(
          title: Text(contact.name),
          subtitle: Text(contact.phone),
        );
      },
    );
  }
}
