import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(File file, String productId) async {
    final ext = file.path.split('.').last;
    final fileName = '${const Uuid().v4()}.$ext';
    final ref = _storage.ref('products/$productId/$fileName');
    final task = await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    return await task.ref.getDownloadURL();
  }

  Future<List<String>> uploadProductImages(List<File> files, String productId) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await uploadProductImage(file, productId);
      urls.add(url);
    }
    return urls;
  }

  Future<String> uploadUserAvatar(File file, String userId) async {
    final ext = file.path.split('.').last;
    final ref = _storage.ref('users/$userId/avatar.$ext');
    final task = await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    return await task.ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
