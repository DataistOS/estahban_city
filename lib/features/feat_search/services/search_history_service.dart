// lib/features/feat_search/services/search_history_service.dart

import '../../feat_auth/services/auth_service.dart';

class SearchHistoryService {
  final _pb = AuthService.pb;

  Future<void> saveSearchQuery(String query) async {
    try {
      if (!_pb.authStore.isValid || query.trim().isEmpty) return;

      final userId = _pb.authStore.model.id;
      final formattedQuery = "دیواراستهبان: ${query.trim()}";

      await _pb
          .collection('search_history')
          .create(body: {'user_id': userId, 'search_query': formattedQuery});
    } catch (e) {
      print('خطا: $e');
    }
  }
}
