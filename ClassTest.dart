////////////////////// Cargar Pelicula Json /////////////////

Future<MovieData> fetchMovieData(int movieId) async {
  final response = await http.get(
      Uri.https('pelispedia.is', '/hcapi/movie/' + movieId.toString() + '/'));
  print("LLamando a la api movie: " + movieId.toString());
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON
    return await compute(parseMovieData, response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

MovieData parseMovieData(String responseBody) {
  final parsed = MovieData.fromJson(json.decode(responseBody));
  return parsed;
}

class MovieData {
  MovieData({
    this.movieName,
    this.movieContent,
    this.movieRelease,
    this.movieBackdrop,
    this.moviePoster,
    this.movieTrailer,
    this.movieDuration,
    this.movieCategories,
    this.movieStreams,
  });

  String? movieName;
  String? movieContent;
  String? movieRelease;
  String? movieBackdrop;
  String? moviePoster;
  String? movieTrailer;
  String? movieDuration;
  String? movieCategories;
  List<MovieStream>? movieStreams;

  factory MovieData.fromJson(Map<String, dynamic> json) => MovieData(
        movieName: json["movie_name"],
        movieContent: json["movie_content"],
        movieRelease: json["movie_release"],
        movieBackdrop: json["movie_backdrop"],
        moviePoster: json["movie_poster"],
        movieTrailer: json["movie_trailer"],
        movieDuration: json["movie_duration"],
        movieCategories: json["movie_categories"],
        movieStreams: List<MovieStream>.from(
            json["movie_streams"].map((x) => MovieStream.fromJson(x))),
      );
}

class MovieStream {
  MovieStream({
    this.type,
    this.server,
    this.lang,
    this.quality,
    this.link,
    this.date,
  });

  int? type;
  int? server;
  String? lang;
  int? quality;
  String? link;
  String? date;

  factory MovieStream.fromJson(Map<String, dynamic> json) => MovieStream(
        type: json["type"],
        server: json["server"],
        lang: json["lang"],
        quality: json["quality"],
        link: json["link"],
        date: json["date"],
      );
}
