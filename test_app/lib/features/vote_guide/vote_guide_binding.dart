import 'package:get/get.dart';
import 'package:test_app/features/vote_guide/repository/vote_guide_repository.dart';
import 'package:test_app/features/vote_guide/vote_guide_controller.dart';

class VoteGuideStepBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoteGuideController>(() => VoteGuideController(repository: VoteGuideRepository()));
  }
}
