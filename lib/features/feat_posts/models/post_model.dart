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

  RecordModel toRecord() => record;
}
