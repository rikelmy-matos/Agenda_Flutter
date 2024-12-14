import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contatos',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 4,
          backgroundColor: Colors.deepPurple,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      home: const MyHomePage(title: 'Agenda de Contatos'),
    );
  }
}

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
        builder: (context) => ContactProfileScreen(contact: contact, onEdit: _editContact, onDelete: _deleteContact),
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
                return Dismissible(
                  key: Key(contact.id.toString()),
                  onDismissed: (direction) {
                    _deleteContact(contact.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${contact.name} foi excluído')));
                  },
                  child: ListTile(
                    onTap: () => _showContactProfile(context, contact),
                    title: Text(contact.name),
                    subtitle: Text(contact.phone),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _editContact(context, contact);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteContact(contact.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${contact.name} foi excluído')));
                          },
                        ),
                      ],
                    ),
                  ),
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

// Tela de Perfil do Contato com opções de Editar e Excluir
class ContactProfileScreen extends StatelessWidget {
  final Contact contact;
  final Function(BuildContext, Contact) onEdit;
  final Function(int) onDelete;

  const ContactProfileScreen({super.key, required this.contact, required this.onEdit, required this.onDelete});

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
                    contact.name[0],
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
                      child: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        onDelete(contact.id);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Excluir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
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

// Modelo de contato e manipulação do banco de dados
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

class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDB('local.db');
    return _database!;
  }

  Future<Database> _initializeDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE user(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    telefone TEXT NOT NULL,
    email TEXT
    )''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('user', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('user');
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUser(Contact contact) async {
    final db = await database;
    return await db.update(
      'user',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }
}

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
