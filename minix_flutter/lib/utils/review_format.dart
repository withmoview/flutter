class ParsedReview {
  final String title;
  final String genre;
  final double rating;
  final String text;
  final String posterUrl;

  const ParsedReview({
    required this.title,
    required this.genre,
    required this.rating,
    required this.text,
    required this.posterUrl,
  });
}

ParsedReview parseReview(String content) {
  if (!content.startsWith('[REVIEW]')) {
    return ParsedReview(title: '', genre: '', rating: 0, text: content, posterUrl: '');
  }

  String title = '';
  String genre = '';
  double rating = 0;
  String text = '';
  String posterUrl = '';

  final lines = content.split('\n');

  bool inText = false;
  final textBuf = <String>[];

  for (final line in lines) {
    if (line.startsWith('TITLE=')) {
      title = line.substring(6).trim();
    } else if (line.startsWith('GENRE=')) {
      genre = line.substring(6).trim();
    } else if (line.startsWith('RATING=')) {
      rating = double.tryParse(line.substring(7).trim()) ?? 0;
    } else if (line.startsWith('POSTER=')) {
      posterUrl = line.substring(7).trim();
    } else if (line.startsWith('TEXT=')) {
      inText = true;
      textBuf.add(line.substring(5));
    } else if (inText) {
      textBuf.add(line);
    }
  }

  text = textBuf.join('\n').trim();

  return ParsedReview(
    title: title,
    genre: genre,
    rating: rating,
    text: text,
    posterUrl: posterUrl,
  );
}

String oneLine(String s) => s.replaceAll('\n', ' ').trim();
