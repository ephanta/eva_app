class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String userId;
  final String householdId;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.userId,
    required this.householdId,
    required this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      userId: json['user_id'],
      householdId: json['household_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'user_id': userId,
      'household_id': householdId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? ingredients,
    List<String>? steps,
    String? userId,
    String? householdId,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      userId: userId ?? this.userId,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}