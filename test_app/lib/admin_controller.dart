import 'package:get/get.dart';
import 'package:test_app/db_helper.dart';

class AdminController extends GetxController {
  var users = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void fetchUsers() async {
    var result = await DBHelper.getAllUsers();
    users.assignAll(result);
  }

  void deleteUser(int id) async {
    await DBHelper.deleteUser(id);
    fetchUsers();
  }
}
