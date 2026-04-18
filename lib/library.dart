import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:jade_gallery/constants.dart';
import 'package:jade_gallery/models/collection.dart';
import 'package:jade_gallery/models/j_cache.dart';
import 'package:jade_gallery/models/j_image.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class JadeLibrary {
  static final JadeLibrary _instance = JadeLibrary._internal();

  factory JadeLibrary() => _instance;

  JadeLibrary._internal();

  static Directory? _root;
  static File? _localFile;

  static final List<Collection> _collections = [];
  static final List<JImage> _images = [];

  static final String defaultCollectionName = 'Default';
  static final String photosDirectoryName = 'Pictures';

  static Future<void> init() async {
    try {
      _root ??= await getApplicationSupportDirectory();
      if (kDebugMode) {
        print('ROOT >>>> $_root');
      }

      // Create root directory if missing...
      if (!await _root!.exists()) {
        await _root!.create(recursive: true);

        // Create the "Default" collection.
        Directory(
          p.join(_root!.path, defaultCollectionName),
        ).create(recursive: true);

        makeLink(
          p.join(_root!.path, photosDirectoryName),
          getPhotosDirectory(),
        );
      }

      final defaultCollection = Directory(
        p.join(_root!.path, defaultCollectionName),
      );

      if (!await defaultCollection.exists()) {
        await defaultCollection.create(recursive: true);

        makeLink(
          p.join(_root!.path, photosDirectoryName),
          getPhotosDirectory(),
        );
      }

      // TODO: Start watching for new collections in the root directory...
      // _root!.watch().listen((event) async {});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static File get _cache {
    if (_root == null) {
      throw Exception('Cannot access cache before calling init().');
    }

    _localFile ??= File('${_root!.path}/gallery_cache.json');
    return _localFile!;
  }

  static Future<JCache> loadCache() async {
    if (await _cache.exists()) {
      final content = await _cache.readAsString();
      final dynamic json = jsonDecode(content);
      return JCache.fromMap(json);
    } else {
      await _cache.create(recursive: true);
    }

    return JCache.fromMap({});
  }

  static Future<void> saveCacheFromData({
    List<Collection>? collections,
    List<JImage>? images,
  }) async {
    try {
      await _cache.writeAsString(
        jsonEncode(
          JCache(
            collections: collections ?? _collections,
            images: images ?? _images,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error saving cache: $e');
    }
  }

  static Future<void> saveCache(JCache cache) async {
    try {
      await _cache.writeAsString(jsonEncode(cache));
    } catch (e) {
      debugPrint('Error saving cache: $e');
    }
  }

  static Future<void> scan() async {
    _collections.clear();
    _images.clear();

    final paths = await _root!.list().toList();

    for (var path in paths) {
      final stat = await path.stat();

      if (stat.type == FileSystemEntityType.directory) {
        // Always use the absolute path to avoid directory name conflicts.
        await addCollection(path.absolute.path);
      }
    }

    await saveCacheFromData();
  }

  static Future<void> addCollection(String path) async {
    try {
      final name = p.basename(path);

      if (_collections.where((s) => s.path == path).isEmpty) {
        _collections.add(Collection(name: name, id: path, path: path));
      }

      final dir = Directory(path);
      final images = await dir
          .list(recursive: true)
          .where(
            (ent) =>
                supportedFileExtensions.contains(
                  p.extension(ent.path).toLowerCase(),
                ) &&
                !_images.any((image) => image.path == ent.path),
          )
          .map(
            (ent) => JImage(
              collection: path,
              path: ent.absolute.path,
              file: File(ent.absolute.path),
            ),
          )
          .toList();

      final toRemove = <String>[];

      for (var image in images) {
        try {
          final bytes = await File(image.path).readAsBytes();
          await decodeImageFromList(bytes);
        } catch (e) {
          if (kDebugMode) {
            print('Found image to remove: ${image.path}');
          }

          toRemove.add(image.path);
        }
      }

      // Only add valid images...
      images.removeWhere((img) => toRemove.contains(img.path));

      _images.addAll(images);

      // TODO: Start watching for new images in the collection directory...
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<void> addImageToDefaultCollection(String path) async {
    try {
      final defaultDir = Directory(p.join(_root!.path, defaultCollectionName));

      if (!await defaultDir.exists()) {
        await defaultDir.create(recursive: true);
      }

      final newPath = p.join(defaultDir.path, p.basename(path));

      // Copy the file to the default collection
      await File(path).copy(newPath);

      if (!_images.any((image) => image.path == newPath)) {
        _images.add(
          JImage(
            collection: defaultDir.path,
            path: newPath,
            file: File(newPath),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<void> importCollection(String path) async {
    await makeLink(p.join(_root!.path, p.basename(path)), path);

    await scan();
  }

  static Future<void> makeLink(String link, String destination) async {
    var targetLink = Link(link);
    await targetLink.create(destination);
  }

  static String getPhotosDirectory() {
    Map<String, String> envVars = Platform.environment;

    String homeDir = '';
    if (Platform.isWindows) {
      homeDir = envVars['USERPROFILE'] ?? '';
    } else if (Platform.isMacOS || Platform.isLinux) {
      homeDir = envVars['HOME'] ?? '';
    } else {
      // Fallback or specific handling for other platforms (e.g., Android/iOS)
      return '';
    }

    return p.join(homeDir, photosDirectoryName);
  }

  static List<Collection> getCollections() {
    return _collections;
  }

  static List<JImage> getImages() {
    return _images;
  }
}
