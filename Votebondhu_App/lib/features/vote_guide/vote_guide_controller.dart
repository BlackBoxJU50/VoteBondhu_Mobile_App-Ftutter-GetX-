import 'package:get/get.dart';
import 'package:test_app/features/vote_guide/repository/vote_guide_repository.dart';

import 'data/vote_guide_dto.dart';

class VoteGuideController extends GetxController {
  final VoteGuideRepository repository;

  VoteGuideController({required this.repository});

  var steps = <VoteGuideDTO>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSteps();
  }

  void loadSteps() async {
    try {
      isLoading.value = true;
      steps.value = await repository.fetchSteps();
    } finally {
      isLoading.value = false;
    }
  }
}
