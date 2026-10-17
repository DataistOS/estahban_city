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

  List<String> get gallery {
    try {
      final value = record.data['gallery'];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  String get category => record.getStringValue('category');

  String get status => record.getStringValue('status', 'pending');

  String get userId => record.getStringValue('user');

  String get userTier {
    try {
      final userRecord = record.get<RecordModel?>('expand.user');
      if (userRecord != null) {
        return userRecord.getStringValue('tier', 'free');
      }

      final userList = record.get<List<RecordModel>>('expand.user');
      if (userList.isNotEmpty) {
        return userList.first.getStringValue('tier', 'free');
      }
    } catch (_) {}
    return 'free';
  }

  RecordModel toRecord() => record;
}
