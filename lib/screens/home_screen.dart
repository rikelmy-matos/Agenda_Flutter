import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/local_database.dart';
import '../widgets/contact_tile.dart';
import '../widgets/search_delegate.dart';
import 'contact_profile_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalDatabase _database = LocalDatabase();

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  Future<void> _loadContacts() async {
    List<Map<String, dynamic>> contactMaps = await _database.getUsers();
    setState(() {
      _contacts = contactMaps
          .map((map) => Contact.fromMap(map))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      _filteredContacts = List.from(_contacts);
    });
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts
          .where((contact) =>
      contact.name.toLowerCase().contains(query) ||
          contact.phone.toLowerCase().contains(query))
          .toList();
    });
  }

  void _addContact(Contact contact) async {
    await _database.insertUser(contact.toMap());
    _loadContacts();
  }

  void _editContact(BuildContext context, Contact contact) async {
    final TextEditingController nameController = TextEditingController(text: contact.name);
    final TextEditingController phoneController = TextEditingController(text: contact.phone);
    final TextEditingController emailController = TextEditingController(text: contact.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email (opcional)'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  final updatedContact = Contact(
                    id: contact.id,
                    name: nameController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                  );
                  _database.updateUser(updatedContact);
                  _loadContacts();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteContact(int id) async {
    await _database.deleteUser(id);
    _loadContacts();
  }

  void _showContactProfile(BuildContext context, Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactProfileScreen(
          contact: contact,
          onEdit: _editContact,  // Passa a função para editar
          onDelete: _deleteContact,  // Passa a função para excluir
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ContactSearchDelegate(contacts: _contacts),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar Contato',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredContacts.isEmpty
                ? const Center(child: Text('Nenhum contato encontrado.'))
                : ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                return ContactTile(
                  contact: contact,
                  onEdit: _editContact,
                  onDelete: _deleteContact,
                  onViewProfile: _showContactProfile, // Passando a função para abrir o perfil
                );
              },
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        tooltip: 'Adicionar Contato',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email (opcional)'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  final newContact = Contact(
                    id: 0,
                    name: nameController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                  );
                  _addContact(newContact);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
}
