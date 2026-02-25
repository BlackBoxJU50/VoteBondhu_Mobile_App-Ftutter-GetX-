import 'dart:async';
import 'package:get/get.dart';
import 'package:test_app/features/news/repository/news_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/news_dto.dart';

class NewsController extends GetxController {
  final NewsRepository repository;

  // Make sure the constructor matches
  NewsController(this.repository);

  RxList<NewsHeadlineDto> headlines = <NewsHeadlineDto>[].obs;
  RxBool isLoading = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    loadHeadlines();

    // Auto-refresh every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => loadHeadlines());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> loadHeadlines() async {
    try {
      isLoading.value = true;
      final data = await repository.fetchAllLatestHeadlines();
      headlines.assignAll(data);
    } catch (_) {
      Get.snackbar("Error", "Failed to load news");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openArticle(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not open the article");
    }
  }
}
