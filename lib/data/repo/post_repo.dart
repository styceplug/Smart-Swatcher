import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/post_model.dart';

class PostRepo {
  static const String _draftsKey = 'post_drafts';

  Future<List<PostDraft>> getDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getString(_draftsKey);

    if (draftsJson == null) return [];

    final List<dynamic> draftsList = json.decode(draftsJson);
    return draftsList.map((draft) => PostDraft.fromJson(draft)).toList();
  }

  Future<void> saveDraft(PostDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();

    final existingIndex = drafts.indexWhere((d) => d.id == draft.id);
    if (existingIndex != -1) {
      drafts[existingIndex] = draft;
    } else {
      drafts.add(draft);
    }

    final draftsJson = json.encode(drafts.map((d) => d.toJson()).toList());
    await prefs.setString(_draftsKey, draftsJson);
  }

  Future<void> deleteDraft(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();

    drafts.removeWhere((draft) => draft.id == id);

    final draftsJson = json.encode(drafts.map((d) => d.toJson()).toList());
    await prefs.setString(_draftsKey, draftsJson);
  }

  Future<void> clearAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftsKey);
  }
}