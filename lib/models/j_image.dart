import 'dart:io';

class JImage {
  final String collection;
  final String path;
  final File file;
  bool favorite;

  JImage({
    required this.collection,
    required this.path,
    required this.file,
    this.favorite = false,
  });

  Map<String, Object?> toJson() => {
    'collection': collection,
    'path': path,
    'file': file.path,
  };

  factory JImage.fromMap(Map<String, dynamic> map) {
    return JImage(
      collection: map['collection'] as String,
      path: map['path'] as String,
      file: File(map['file'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JImage &&
          runtimeType == other.runtimeType &&
          collection == other.collection &&
          path == other.path;

  @override
  int get hashCode => collection.hashCode ^ path.hashCode;
}
