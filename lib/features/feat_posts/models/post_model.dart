// lib/features/feat_posts/models/post_model.dart

import 'package:pocketbase/pocketbase.dart';

class PostModel {
  final RecordModel record;

  PostModel(this.record);

  String get id => record.id;

  String get title => record.getStringValue('title');

  String get description => record.getStringValue('description');

  double get price => record.getDoubleValue('price');

  String get image => record.getStringValue('image');

  String get category => record.getStringValue('category');

  String get status => record.getStringValue('status', 'pending');

  String get userId => record.getStringValue('user');

  String get userTier {
    try {
      final expandedMap = record.expand;
      if (expandedMap.containsKey('user')) {
        final dynamic userData = expandedMap['user'];

        if (userData is List) {
          if (userData.isNotEmpty) {
            final firstUser = userData.first;
            if (firstUser is RecordModel) {
              return firstUser.getStringValue('tier', 'free');
            }
          }
        } else if (userData is RecordModel) {
          return userData.getStringValue('tier', 'free');
        }
      }
    } catch (_) {}
    return 'free';
  }

  RecordModel toRecord() => record;
}
