enum NewsSourceType { rss, html }

enum Newspaper { prothomAlo, jugantor, ittefaq, bdPratidin, dailyInqilab }

extension NewspaperName on Newspaper {
  String get displayName {
    switch (this) {
      case Newspaper.prothomAlo:
        return "Prothom Alo";
      case Newspaper.jugantor:
        return "Jugantor";
      case Newspaper.ittefaq:
        return "Ittefaq";
      case Newspaper.bdPratidin:
        return "BD Pratidin";
      case Newspaper.dailyInqilab:
        return "Daily Inqilab";
    }
  }
}
