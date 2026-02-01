import 'package:html/parser.dart' as html_parser;
import 'package:xml/xml.dart';

import 'package:test_app/core/app_http_client_provider.dart';
import 'package:test_app/enums/enums.dart';
import '../data/news_dto.dart';
import '../data/news_source.dart';

extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class NewsRepository {
  final AppHttpClientProvider httpClient;
  NewsRepository({required this.httpClient});
  Future<List<NewsHeadlineDto>> fetchAllLatestHeadlines() async {
    List<NewsHeadlineDto> allHeadlines = [];

    for (var source in newsSources) {
      try {
        final response = await httpClient.get(source.url, headers: {
          "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36",
          "Referer": source.url,
          "Accept-Language": "en-US,en;q=0.9",
        });

        if (response.statusCode != 200) continue;

        NewsHeadlineDto? dto;

        if (source.type == NewsSourceType.rss) {
          dto = _parseRss(response.body, source);
        } else {
          dto = _parseHtml(response.body, source);
        }

        if (dto != null) allHeadlines.add(dto);
      } catch (_) {}
    }

    return allHeadlines;
  }

  NewsHeadlineDto? _parseRss(String body, NewsSource source) {
    final xml = XmlDocument.parse(body);
    final firstEntry =
        xml.findAllElements('entry').firstOrNull ?? xml.findAllElements('item').firstOrNull;

    if (firstEntry == null) return null;

    final headline = firstEntry.findElements('title').firstOrNull?.text.trim() ?? "";

    String url = firstEntry.findElements('link').firstOrNull?.getAttribute('href') ??
        firstEntry.findElements('link').firstOrNull?.text ??
        firstEntry.findElements('guid').firstOrNull?.text.trim() ??
        "";

    final datetime = firstEntry.findElements('pubDate').firstOrNull?.text.trim() ?? "";

    if (headline.isEmpty || url.isEmpty) return null;

    return NewsHeadlineDto(
      headline: headline,
      url: url,
      newspaper: source.newspaper.displayName,
      datetime: datetime,
    );
  }

  NewsHeadlineDto? _parseHtml(String body, NewsSource source) {
    final document = html_parser.parse(body);

    String headline = "";
    String url = "";
    String datetime = "";

    switch (source.newspaper) {
      case Newspaper.jugantor:
        final element = document.querySelector("div.media-body.marginL5 h4.title10");
        final parentDiv = element?.parent?.parent;
        final linkElement = parentDiv?.querySelector("a[href]");
        headline = element?.text.trim() ?? "";
        url = linkElement?.attributes['href'] ?? "";
        datetime = document.querySelector("div.media-body.marginL5 p.desktopTime")?.text.trim() ?? "";
        break;

      case Newspaper.ittefaq:
        final element = document.querySelector("div.info.has_ai h2.title a.link_overlay");
        headline = element?.text.trim() ?? "";
        url = _makeAbsoluteUrl(element?.attributes['href'] ?? "", source.url);
        break;

      case Newspaper.bdPratidin:
        final headlineElement = document.querySelector("h5.card-title");
        final linkElement = document.querySelector("a.stretched-link");
        headline = headlineElement?.text.trim() ?? "";
        url = _makeAbsoluteUrl(linkElement?.attributes['href'] ?? "", source.url);
        break;

      case Newspaper.dailyInqilab:
        final element = document.querySelector("a.border-bottom.mb-2 p.latest-contents-title");
        final parentLink = element?.parent;
        headline = element?.text.trim() ?? "";
        url = _makeAbsoluteUrl(parentLink?.attributes['href'] ?? "", source.url);
        break;

      default:
        final element = document.querySelector("a");
        headline = element?.text.trim() ?? "";
        url = _makeAbsoluteUrl(element?.attributes['href'] ?? "", source.url);
        break;
    }

    if (headline.isEmpty || url.isEmpty) return null;

    return NewsHeadlineDto(
      headline: headline,
      url: url,
      newspaper: source.newspaper.displayName,
      datetime: datetime,
    );
  }

  String _makeAbsoluteUrl(String url, String baseUrl) {
    if (url.startsWith("http")) return url;
    if (url.startsWith("//")) return "https:$url";

    final uri = Uri.parse(baseUrl);
    return "${uri.scheme}://${uri.host}$url";
  }
}
