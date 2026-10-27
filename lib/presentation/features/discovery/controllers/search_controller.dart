import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/base_state_controller.dart';

class AppSearchController extends BaseStateController {
  final TextEditingController textController = TextEditingController();

  var searchQuery = ''.obs;
  var selectedCategoryIndex = 0.obs; // 0: الكل
  var recentSearches = <String>[].obs;

  var searchResults = <Map<String, dynamic>>[].obs;
  var isLoadingSearch = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
  }

  // مسح شريط البحث والنتائج بالكامل
  void clearSearch() {
    textController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  // البحث الفوري أثناء الكتابة
  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.trim().isNotEmpty) {
      performInstantSearch(query);
    } else {
      searchResults.clear();
    }
  }

  // حفظ الكلمة في السجل عند الضغط على Enter أو إتمام البحث
  void onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      saveSearchQuery(query.trim());
      performInstantSearch(query.trim());
    }
  }

  void changeCategoryFilter(int index) {
    selectedCategoryIndex.value = index;
    if (searchQuery.value.trim().isNotEmpty) {
      performInstantSearch(searchQuery.value);
    }
  }

  // جلب سجل البحث المخزن محلياً على الجهاز
  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('recent_searches') ?? [];
    recentSearches.assignAll(list);
  }

  // حفظ عملية البحث محلياً وتحديث القائمة التفاعلية فوراً
  Future<void> saveSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();

    // إزالة الكلمة إن وجدت مسبقاً لعدم تكرارها ووضعها في المقدمة
    recentSearches.remove(query);
    recentSearches.insert(0, query);

    // الاحتفاظ بآخر 5 عمليات بحث فقط
    if (recentSearches.length > 5) {
      recentSearches.removeLast();
    }

    // حفظ القائمة في الذاكرة المحلية للجهاز
    await prefs.setStringList('recent_searches', recentSearches.toList());
    recentSearches.refresh; // تحديث الواجهة فوراً
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    recentSearches.clear();
  }

  Future<void> removeSingleSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    recentSearches.remove(query);
    await prefs.setStringList('recent_searches', recentSearches.toList());
  }

  void performInstantSearch(String query) async {
    await safeExecute(() async {
      isLoadingSearch.value = true;
      List<Map<String, dynamic>> tempResults = [];

      List<String> collectionsToSearch = [];
      if (selectedCategoryIndex.value == 0) {
        collectionsToSearch = [
          'courses',
          'jobs',
          'print_centers',
          'instructors',
        ];
      } else if (selectedCategoryIndex.value == 1) {
        collectionsToSearch = ['courses'];
      } else if (selectedCategoryIndex.value == 2) {
        collectionsToSearch = ['instructors'];
      } else if (selectedCategoryIndex.value == 3) {
        collectionsToSearch = ['print_centers'];
      } else {
        collectionsToSearch = ['jobs'];
      }

      for (String col in collectionsToSearch) {
        var snapshot = await FirebaseFirestore.instance.collection(col).get();
        for (var doc in snapshot.docs) {
          var data = doc.data();
          String title = data['title'] ?? data['name'] ?? '';
          if (title.toLowerCase().contains(query.toLowerCase())) {
            tempResults.add({...data, 'collection': col, 'id': doc.id});
          }
        }
      }

      searchResults.assignAll(tempResults);
    });
    isLoadingSearch.value = false;
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
