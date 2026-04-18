import 'dart:io';

import 'package:jade_gallery/models/collection.dart';
import 'package:jade_gallery/models/j_image.dart';

class JCache {
  final List<Collection> collections;
  final List<JImage> images;

  JCache({
    this.collections = const <Collection>[],
    this.images = const <JImage>[],
  });

  Map<String, Object?> toJson() => {
    'collections': collections.toList(),
    'images': images.toList(),
  };

  factory JCache.fromMap(Map<String, dynamic> map) {
    // Filter out files that might have been deleted from disk since last run

    return JCache(
      collections: (map['collections'] as List<dynamic>)
          .map((s) => Collection.fromMap(s))
          .where((s) => Directory(s.path).existsSync())
          .toList(),
      images: (map['images'] as List<dynamic>)
          .map((s) => JImage.fromMap(s))
          .where((s) => s.file.existsSync())
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JCache &&
          runtimeType == other.runtimeType &&
          collections.length == other.collections.length &&
          collections.first == other.collections.first &&
          collections.last == other.collections.last &&
          images.length == other.images.length &&
          images.first == other.images.first &&
          images.last == other.images.last;

  @override
  int get hashCode =>
      images.first.hashCode ^
      collections.first.hashCode ^
      images.last.hashCode ^
      collections.last.hashCode;
}
