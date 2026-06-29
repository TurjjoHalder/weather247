import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchCityController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  
  var isSearchFocused = false.obs;
  
  // Reactive list to hold data from Firestore
  var recentSearches = <Map<String, dynamic>>[].obs;
  var isLoadingHistory = true.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    searchFocusNode.addListener(() {
      isSearchFocused.value = searchFocusNode.hasFocus;
    });
    // Fetch search history as soon as the controller initializes
    fetchRecentSearches();
  }

  @override
  void onClose() {
    textController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  // --- FIRESTORE METHODS ---

  // 1. Read: Fetch recent searches from Firestore
  Future<void> fetchRecentSearches() async {
    try {
      isLoadingHistory(true);
      
      // We order by timestamp so the most recent searches appear at the top
      final snapshot = await _firestore
          .collection('recent_searches')
          .orderBy('timestamp', descending: true)
          .limit(5) // Keep the UI clean by limiting to 5 recent items
          .get();

      recentSearches.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Keep the document ID for deletion later
        return data;
      }).toList();
      
    } catch (e) {
      print("Error fetching history: $e");
    } finally {
      isLoadingHistory(false);
    }
  }

  // 2. Write: Save a new search to Firestore
  // (You will call this when a user actually selects a city from search results)
  Future<void> saveSearch(String city, String region, double temp, String iconCode) async {
    try {
      await _firestore.collection('recent_searches').add({
        'city': city,
        'region': region,
        'temp': temp,
        'icon': iconCode,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Refresh the list after saving
      fetchRecentSearches();
    } catch (e) {
      print("Error saving search: $e");
    }
  }

  // 3. Delete: Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      // In a real app, it's better to use a batch delete or a Cloud Function,
      // but for a small dataset, iterating is fine.
      final snapshot = await _firestore.collection('recent_searches').get();
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      recentSearches.clear();
    } catch (e) {
      print("Error clearing history: $e");
    }
  }

  void clearSearchInput() {
    textController.clear();
    searchFocusNode.unfocus();
  }
}