
import 'package:test_app/enums/enums.dart';

class NewsSource {
  final Newspaper newspaper;
  final String url;
  final NewsSourceType type;

  const NewsSource({
    required this.newspaper,
    required this.url,
    required this.type,
  });
}

/// List of all sources
const List<NewsSource> newsSources = [
  NewsSource(
    newspaper: Newspaper.prothomAlo,
    url: "https://www.prothomalo.com/feed",
    type: NewsSourceType.rss,
  ),
  NewsSource(
    newspaper: Newspaper.jugantor,
    url: "https://www.jugantor.com/latest",
    type: NewsSourceType.html,
  ),
  NewsSource(
    newspaper: Newspaper.ittefaq,
    url: "https://www.ittefaq.com.bd/latest-news",
    type: NewsSourceType.html,
  ),
  NewsSource(
    newspaper: Newspaper.bdPratidin,
    url: "https://www.bd-pratidin.com/online/todaynews",
    type: NewsSourceType.html,
  ),
  NewsSource(
    newspaper: Newspaper.dailyInqilab,
    url: "https://dailyinqilab.com/",
    type: NewsSourceType.html,
  ),
];
