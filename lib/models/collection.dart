class Collection {
  final String id;
  final String name;
  final String path;

  const Collection({
    this.name = 'Collection',
    required this.path,
    required this.id,
  });

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'path': path};

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] as String,
      name: map['name'] as String,
      path: map['path'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Collection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
