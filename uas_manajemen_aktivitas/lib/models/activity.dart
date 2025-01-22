class Activity {
  String name;
  String description;
  String? categoryId;
  String date;
  bool isCompleted;

  Activity({
    required this.name,
    required this.description,
    this.categoryId,
    required this.date,
    required this.isCompleted,
  });

  // Mengonversi Activity menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category_id': categoryId,
      'date': date,
      'isCompleted': isCompleted,
    };
  }

  // Membuat Activity dari Map
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['category_id'],
      date: map['date'] ?? '',
      isCompleted: map['isCompleted'] ?? false, // Pastikan default value jika null
    );
  }
}
