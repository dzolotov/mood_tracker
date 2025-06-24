import 'package:realm/realm.dart';

part 'activity_model.realm.dart';

@RealmModel()
class _ActivityModel {
  @PrimaryKey()
  late String name;
  late String category;
  late DateTime createdAt;
  late int usageCount;
  String? description;
  String? iconCode;
}