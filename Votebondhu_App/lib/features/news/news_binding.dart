import 'package:get/get.dart';
import 'package:test_app/features/news/repository/news_repository.dart';
import 'package:test_app/core/app_http_client_provider.dart';
import 'news_controller.dart';

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppHttpClientProvider>(() => AppHttpClientProvider());
    Get.lazyPut<NewsRepository>(() => NewsRepository(httpClient: Get.find()));
    Get.lazyPut<NewsController>(() => NewsController(Get.find()));

    
  }
}
