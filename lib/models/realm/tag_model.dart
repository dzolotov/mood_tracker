import 'package:realm/realm.dart';

part 'tag_model.realm.dart';

@RealmModel()
class _TagModel {
  @PrimaryKey()
  late String name;
  late String color;
  late DateTime createdAt;
  late int usageCount;
  String? description;
}