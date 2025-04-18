class UserModel {
  bool _isLoggedIn = false;
  String? _name;
  String? _email;
  String? _profilePicture;
  double _walletBalance = 0.0;
  List<DocumentModel> _documents = [];

  bool get isLoggedIn => _isLoggedIn;
  String? get name => _name;
  String? get email => _email;
  String? get profilePicture => _profilePicture;
  double get walletBalance => _walletBalance;
  List<DocumentModel> get documents => _documents;

  void login(String email, String password) {
    // In a real app, this would make an API call
    _isLoggedIn = true;
    _name = "Master Chaitanya";
    _email = email;
    _profilePicture = "https://via.placeholder.com/150";
    _walletBalance = 213.0;

    // Add some sample documents
    _documents = [
      DocumentModel(
        id: "AC32",
        name: "Experiment_1A.pdf",
        size: "2.5 MB",
        date: "2023-04-15",
        status: "Pending",
        pages: 8,
        amount: "Rs. 16/-",
      ),
      DocumentModel(
        id: "AC33",
        name: "Experiment_1A.pdf",
        size: "1.8 MB",
        date: "2023-04-10",
        status: "Pending",
        pages: 6,
        amount: "Rs. 12/-",
      ),
    ];
  }

  void logout() {
    _isLoggedIn = false;
    _name = null;
    _email = null;
    _profilePicture = null;
    _walletBalance = 0.0;
    _documents = [];
  }

  void addMoney(double amount) {
    _walletBalance += amount;
  }

  void addDocument(DocumentModel document) {
    _documents.add(document);
  }
}

class DocumentModel {
  final String id;
  final String name;
  final String size;
  final String date;
  final String status;
  final int pages;
  final String amount;

  DocumentModel({
    required this.id,
    required this.name,
    required this.size,
    required this.date,
    required this.status,
    required this.pages,
    required this.amount,
  });
}
