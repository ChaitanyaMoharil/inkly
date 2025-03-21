import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/document_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentModel> _documents = [
    DocumentModel(
      id: "1",
      name: "Assignment.pdf",
      size: "2.5 MB",
      date: "2023-04-15",
      status: "Printed",
    ),
    DocumentModel(
      id: "2",
      name: "Research Paper.docx",
      size: "1.8 MB",
      date: "2023-04-10",
      status: "Pending",
    ),
    DocumentModel(
      id: "3",
      name: "Lecture Notes.pdf",
      size: "4.2 MB",
      date: "2023-04-05",
      status: "Printed",
    ),
    DocumentModel(
      id: "4",
      name: "Project Presentation.pptx",
      size: "5.7 MB",
      date: "2023-04-01",
      status: "Pending",
    ),
  ];
  List<DocumentModel> _filteredDocuments = [];

  @override
  void initState() {
    super.initState();
    _filteredDocuments = _documents;
    _searchController.addListener(_filterDocuments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDocuments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDocuments = _documents;
      } else {
        _filteredDocuments = _documents
            .where((doc) => doc.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: _filteredDocuments.isEmpty
                ? const Center(
                    child: Text(
                      'No documents found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDocuments.length,
                    itemBuilder: (context, index) {
                      return DocumentCard(document: _filteredDocuments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
