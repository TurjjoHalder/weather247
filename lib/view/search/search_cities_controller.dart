import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchCityController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  var isSearchFocused = false.obs;

  var recentSearches = <Map<String, dynamic>>[].obs;
  var isLoadingHistory = true.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    searchFocusNode.addListener(() {
      isSearchFocused.value = searchFocusNode.hasFocus;
    });

    fetchRecentSearches();
  }

  @override
  void onClose() {
    textController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  // --- FIRESTORE METHODS ---

  Future<void> fetchRecentSearches() async {
    try {
      isLoadingHistory(true);

      final snapshot = await _firestore
          .collection('recent_searches')
          .orderBy('timestamp', descending: true)
          .limit(5)
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

  Future<void> saveSearch(
    String city,
    String region,
    double temp,
    String iconCode,
  ) async {
    try {
      await _firestore.collection('recent_searches').add({
        'city': city,
        'region': region,
        'temp': temp,
        'icon': iconCode,
        'timestamp': FieldValue.serverTimestamp(),
      });

      fetchRecentSearches();
    } catch (e) {
      print("Error saving search: $e");
    }
  }

  // will implemnt this latter
  Future<void> deleteSearch(String docId) async {
    try {
      await _firestore.collection('recent_searches').doc(docId).delete();
      recentSearches.removeWhere((search) => search['id'] == docId);
    } catch (e) {
      print("Error deleting search: $e");
    }
  }

  Future<void> clearRecentSearches() async {
    try {
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
