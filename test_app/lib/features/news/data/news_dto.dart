class NewsHeadlineDto {
  final String headline;
  final String url;
  final String newspaper;
  final String datetime;

  const NewsHeadlineDto({
    required this.headline,
    required this.url,
    required this.newspaper,
    this.datetime = "",
  });
}
