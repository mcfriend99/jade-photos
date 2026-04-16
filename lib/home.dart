import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:jade_gallery/constants.dart';
import 'package:jade_gallery/enums.dart';
import 'package:jade_gallery/library.dart';
import 'package:jade_gallery/models/images.dart';
import 'package:jade_gallery/models/j_cache.dart';
import 'package:jade_gallery/viewer.dart';
import 'package:jade_gallery/widgets/access_bar.dart';
import 'package:jade_gallery/widgets/collection_thumbnail.dart';
import 'package:jade_gallery/widgets/image_thumbnail.dart';
import 'package:jade_gallery/widgets/sidebar.dart';
import 'package:jade_gallery/widgets/sidebar_button.dart';
import 'package:jade_gallery/widgets/window_box.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'color.dart';
import 'models/collection.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Collection> _collections = [];
  List<JImage> _images = [];

  bool _isLoading = false;
  String _accessBarTitle = 'Library';
  double _gridMaxExtent = 220;
  AppPage _currentPage = AppPage.library;

  @override
  void initState() {
    super.initState();
    _loadPersistedCollections();
  }

  Future<File> get _localFile async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/gallery_cache.json');
  }

  Future<void> _loadPersistedCollections() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final dynamic json = jsonDecode(content);
        final JCache cache = JCache.fromMap(json);

        setState(() {
          _collections = cache.collections;
          _images = cache.images;
        });
      }
    } catch (e) {
      debugPrint('Error loading cache: $e');
    }

    JadeLibrary.init().then((_) async {
      // Trigger the initial reload of images to update library.
      _reloadImages();
    });
  }

  Future<void> _saveCache() async {
    try {
      final file = await _localFile;
      await file.writeAsString(
        jsonEncode(JCache(collections: _collections, images: _images)),
      );
    } catch (e) {
      debugPrint('Error saving cache: $e');
    }
  }

  Future<void> _reloadImages() async {
    await JadeLibrary.scan();

    setState(() {
      _collections = JadeLibrary.getCollections();
      _images = JadeLibrary.getImages();
    });

    _saveCache();
  }

  Future<void> _pickImage() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: supportedFileExtensions.map((s) => s.substring(1)).toList(),
    );
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );
    if (file != null) {
      await JadeLibrary.addImageToDefaultCollection(file.path);
      await _reloadImages();

      _saveCache();
    }
  }

  Future<void> _pickDirectory() async {
    final String? directoryPath = await getDirectoryPath();
    if (directoryPath != null) {
      setState(() => _isLoading = true);

      try {
        await JadeLibrary.importCollection(directoryPath);
        await _reloadImages();

        _saveCache();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading directory: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearGallery() {
    _images.clear();
    _collections.clear();

    setState(() {
      _images = [];
      _collections = [];
    });

    _saveCache();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsRegular.imagesSquare,
            size: 120,
            color: normalColor.withAlpha(110),
          ),
          const SizedBox(height: 24),
          Text(
            'Your gallery is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: normalColor),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: _pickImage,
                icon: const Icon(PhosphorIconsRegular.image),
                label: const Text('Add Image'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _pickDirectory,
                icon: const Icon(PhosphorIconsRegular.folderPlus),
                label: const Text('Import Collection'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: _gridMaxExtent,
      childAspectRatio: 1,
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
    );

    final gridPhysics = const BouncingScrollPhysics();

    if (_currentPage == AppPage.collections) {
      return GridView.builder(
        gridDelegate: gridDelegate,
        physics: gridPhysics,
        itemCount: _collections.length,
        itemBuilder: (context, index) {
          final collection = _collections[index];

          return CollectionThumbnail(
            key: Key(collection.path),
            collection: collection,
            images: _images,
            onTap: () {
              // TODO: Filter the images to only show those in the collection...
            },
          );
        },
      );
    }

    return GridView.builder(
      gridDelegate: gridDelegate,
      physics: gridPhysics,
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];

        return ImageThumbnail(
          key: Key(image.path),
          image: image,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    FullscreenViewer(images: _images, initialIndex: index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSideMenu() {
    return SidebarNav(
      startId: 0,
      selectedId: _currentPage.index,
      onChange: (id, label) {
        setState(() {
          _currentPage = AppPage.values[id];
          _accessBarTitle = label;
        });
      },
      children: [
        Text('Photos', style: TextStyle(color: kTextGrey)),
        SidebarButton(
          label: 'Library',
          icon: PhosphorIconsRegular.images,
          id: AppPage.library.index,
        ),
        SidebarButton(
          label: 'Collections',
          icon: PhosphorIconsRegular.cardsThree,
          id: AppPage.collections.index,
        ),
        const SizedBox(height: 4),
        Text('Pinned', style: TextStyle(color: kTextGrey)),
        SidebarButton(
          label: 'Favorites',
          icon: PhosphorIconsRegular.heart,
          id: AppPage.favorites.index,
        ),
        SidebarButton(
          label: 'Recently Saved',
          icon: PhosphorIconsRegular.trayArrowDown,
          id: AppPage.recentlySaved.index,
        ),
        SidebarButton(
          label: 'Screenshots',
          icon: PhosphorIconsRegular.scan,
          id: AppPage.screenshots.index,
        ),
        SidebarButton(
          label: 'People & Pets',
          icon: PhosphorIconsRegular.userCircle,
          id: AppPage.peopleAndPets.index,
        ),
        SidebarButton(
          label: 'Recently Deleted',
          icon: PhosphorIconsRegular.trash,
          id: AppPage.recentlyDeleted.index,
        ),
      ],
    );
  }

  Widget _titleBar() {
    return AccessBar(
      title: _accessBarTitle,
      actions: [
        Row(
          spacing: 4,
          children: [
            IconButton(
              onPressed: _gridMaxExtent > 100
                  ? () {
                      setState(() {
                        _gridMaxExtent = (_gridMaxExtent * 0.75).clamp(
                          100,
                          _gridMaxExtent,
                        );
                      });
                    }
                  : null,
              tooltip: 'Zoom Out',
              icon: Icon(PhosphorIconsRegular.minus),
            ),
            IconButton(
              onPressed: _gridMaxExtent < 440
                  ? () {
                      setState(() {
                        _gridMaxExtent = (_gridMaxExtent * 1.25).clamp(
                          _gridMaxExtent,
                          440,
                        );
                      });
                    }
                  : null,
              tooltip: 'Zoom In',
              icon: Icon(PhosphorIconsRegular.plus),
            ),
          ],
        ),
        const VerticalDivider(),
        Row(
          spacing: 4,
          children: [
            IconButton(
              onPressed: () {},
              tooltip: 'Quick Info',
              icon: Icon(PhosphorIconsRegular.info),
            ),
            IconButton(
              onPressed: null,
              tooltip: 'Share/Send',
              icon: Icon(PhosphorIconsRegular.export),
            ),
            IconButton(
              onPressed: null,
              tooltip: 'Add to Favorites',
              icon: Icon(PhosphorIconsRegular.heart),
            ),
          ],
        ),
        const VerticalDivider(),
        Row(
          spacing: 4,
          children: [
            IconButton(
              onPressed: () {},
              tooltip: 'Filter',
              icon: Icon(PhosphorIconsRegular.funnelSimple),
            ),
            IconButton(
              onPressed: () {},
              tooltip: 'Search',
              icon: Icon(PhosphorIconsRegular.magnifyingGlass),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WindowBox(
      title: widget.title,
      actions: [
        IconButton(
          icon: const Icon(PhosphorIconsRegular.trashSimple),
          onPressed: _images.isNotEmpty ? _clearGallery : null,
          tooltip: 'Clear Gallery',
        ),
        const VerticalDivider(width: 20),
        IconButton(
          icon: const Icon(PhosphorIconsRegular.image),
          onPressed: _pickImage,
          tooltip: 'Add Image',
        ),
        IconButton(
          icon: const Icon(PhosphorIconsRegular.folderPlus),
          onPressed: _pickDirectory,
          tooltip: 'Import Collection',
        ),
        const SizedBox(width: 8),
      ],
      child: Row(
        children: [
          _buildSideMenu(),
          Expanded(
            child: Container(
              color: backgroundEndColor,
              child: Column(
                children: [
                  _titleBar(),
                  Expanded(
                    child: Stack(
                      children: [
                        _images.isEmpty && !_isLoading
                            ? _buildEmptyState(context)
                            : _buildGrid(context),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: accentBlue,
                              strokeWidth: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
