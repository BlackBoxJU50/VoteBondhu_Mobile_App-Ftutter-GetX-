import 'package:get/get.dart';

class HomeController extends GetxController {
  var tabIndex = 0.obs;
  Map<String, dynamic> user = {};

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      user = Get.arguments;
    }
  }

  void changeTabIndex(int index) => tabIndex.value = index;
}
