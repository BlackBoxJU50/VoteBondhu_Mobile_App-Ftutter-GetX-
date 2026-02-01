import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NewsController extends GetxController {
  var newsList = <NewsItem>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  void loadNews() async {
    isLoading.value = true;
    var news = await NewsService.fetchNews();
    if (news.isNotEmpty) {
      newsList.value = news;
    }
    isLoading.value = false;
  }
}

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NewsController controller = Get.put(NewsController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.newsList.isEmpty) {
        return Center(
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Text('Failed to load news or no news available.'),
               ElevatedButton(onPressed: controller.loadNews, child: const Text('Retry'))
             ],
          )
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.loadNews(),
        child: ListView.builder(
          itemCount: controller.newsList.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            var item = controller.newsList[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(item.link);
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    // handle error
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40, // Smaller header
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: _getSourceColor(item.source),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                             item.source, 
                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                           ),
                           if (item.date != null)
                             Text(
                               DateFormat('MMM d, h:mm a').format(item.date!),
                               style: const TextStyle(color: Colors.white70, fontSize: 12),
                             )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (item.description.isNotEmpty)
                             Text(
                               item.description,
                               maxLines: 3,
                               overflow: TextOverflow.ellipsis,
                               style: TextStyle(color: Colors.grey[800]),
                             ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Color _getSourceColor(String source) {
    if (source.contains('Prothom')) return Colors.blue[800]!;
    if (source.contains('Star')) return Colors.purple[800]!;
    if (source.contains('Kaler')) return Colors.orange[800]!;
    if (source.contains('Amar')) return Colors.green[800]!;
    return Colors.grey[700]!;
  }
}
