import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class NewsItem {
  final String title;
  final String description;
  final String link;
  final String source;
  final DateTime? date;

  NewsItem({
    required this.title, 
    required this.description, 
    required this.link, 
    required this.source,
    this.date,
  });
}

class NewsService {
  // URLs
  static const String dhakaTribuneUrl = 'https://www.dhakatribune.com/rss/all-news.xml'; 
  static const String dailyStarUrl = 'https://www.thedailystar.net/frontpage/rss.xml'; 
  static const String banglaTribuneUrl = 'https://www.banglatribune.com/feed/rss.xml';

  static Future<List<NewsItem>> fetchNews() async {
    List<NewsItem> allNews = [];

    await Future.wait([
      _fetchFeed(dhakaTribuneUrl, 'Dhaka Tribune'),
      _fetchFeed(dailyStarUrl, 'The Daily Star'),
      _fetchFeed(banglaTribuneUrl, 'Bangla Tribune'),
    ]).then((results) {
      for (var list in results) {
        allNews.addAll(list);
      }
    });

    // Sort by date descending
    allNews.sort((a, b) => (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000)));
    return allNews;
  }

  static Future<List<NewsItem>> _fetchFeed(String url, String sourceName) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        
        return items.map((node) {
          String title = node.findElements('title').singleOrNull?.innerText ?? 'No Title';
          String desc = _cleanDescription(node.findElements('description').singleOrNull?.innerText ?? '');
          
          return NewsItem(
            title: title,
            description: desc,
            link: node.findElements('link').singleOrNull?.innerText ?? '',
            source: sourceName,
            date: _parseDate(node.findElements('pubDate').singleOrNull?.innerText),
          );
        }).where((item) {
          // Filter logic
          final keywords = ['election', 'vote', 'voting', 'voter', 'poll', 'commission', 'candidate', 'politics', 'party', 'ballot', 'campaign', 'democracy'];
          final text = '${item.title} ${item.description}'.toLowerCase();
          return keywords.any((k) => text.contains(k));
        }).toList();
      }
    } catch (e) {
      print('Error fetching $sourceName: $e');
    }
    return [];
  }

  static String _cleanDescription(String raw) {
    // Simple HTML tag removal
    return raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      // Common RSS date format: "Mon, 25 Dec 2023 12:00:00 GMT"
      // or "Mon, 25 Dec 2023 12:00:00 +0600"
      return HttpDate.parse(dateString); 
    } catch (e) {
      try {
         // Fallback for different formats if needed, or simple DateFormat
         return DateFormat("EEE, d MMM yyyy HH:mm:ss Z").parse(dateString);
      } catch (e2) {
         return null;
      }
    }
  }
}
