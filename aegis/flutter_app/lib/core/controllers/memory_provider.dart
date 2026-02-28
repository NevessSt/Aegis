import 'package:flutter/material.dart';
import '../models/memory_model.dart';
import '../database_helper.dart';

class MemoryProvider with ChangeNotifier {
  List<MemoryModel> _memories = [];
  bool _isLoading = false;

  List<MemoryModel> get memories => _memories;
  bool get isLoading => _isLoading;

  MemoryProvider() {
    loadMemories();
  }

  Future<void> loadMemories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await DatabaseHelper.instance.getDecryptedMemories();
      _memories = data.map((item) => MemoryModel.fromMap(item)).toList();
    } catch (e) {
      debugPrint("Error loading memories: \$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMemory(String content) async {
    try {
      await DatabaseHelper.instance.insertMemory(content);
      await loadMemories(); // Refresh the list
    } catch (e) {
      debugPrint("Error adding memory: \$e");
    }
  }
  
  // Future sync integration will go here
}
