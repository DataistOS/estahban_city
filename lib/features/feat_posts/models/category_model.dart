// lib/features/feat_posts/models/category_model.dart

import 'package:pocketbase/pocketbase.dart';

class CategoryModel {
  final RecordModel record;

  CategoryModel(this.record);

  String get id => record.id;

  String get name => record.getStringValue('name');

  String get slug => record.getStringValue('slug');

  String get parent => record.getStringValue('parent');

  RecordModel toRecord() => record;
}
