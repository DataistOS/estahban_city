import 'package:pocketbase/pocketbase.dart';

class PostModel {
  final RecordModel record;

  PostModel(this.record);

  String get id => record.id;

  String get title => record.getStringValue('title');

  String get description => record.getStringValue('description');

  double get price => record.getDoubleValue('price');

  String get image => record.getStringValue('image');

  RecordModel toRecord() => record;
}
