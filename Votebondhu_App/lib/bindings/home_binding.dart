import 'package:get/get.dart';
import 'package:test_app/core/app_http_client_provider.dart';
import 'package:test_app/features/news/news_controller.dart' as news_ctrl;
import 'package:test_app/features/news/repository/news_repository.dart';
import 'package:test_app/features/vote_guide/vote_guide_controller.dart';
import 'package:test_app/features/vote_guide/repository/vote_guide_repository.dart';
import 'package:test_app/controllers/home_controller.dart';
import 'package:test_app/controllers/poll_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AppHttpClientProvider>(() => AppHttpClientProvider());
    Get.lazyPut<NewsRepository>(() => NewsRepository(httpClient: Get.find()));
    Get.lazyPut<news_ctrl.NewsController>(() => news_ctrl.NewsController(Get.find()));
    Get.lazyPut<VoteGuideRepository>(() => VoteGuideRepository());
    Get.lazyPut<VoteGuideController>(() => VoteGuideController(repository: Get.find()));
    Get.lazyPut<PollController>(() => PollController());
  }
}
