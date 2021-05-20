import 'package:admob_flutter/admob_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_package_manager/flutter_package_manager.dart';
import 'package:homecineapp/Providers/AdmobProvider.dart';
import 'package:homecineapp/Providers/InternetDetect.dart';
import 'package:homecineapp/Providers/http_client.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:homecineapp/Theme/colors.dart';
import 'package:homecineapp/Components/blurred_container.dart';
import 'package:homecineapp/Pages/SelectLang.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homecineapp/Business_logic/cubits/ad_cubit.dart';

import 'NoInternet.dart';

bool? isFavorite;
bool firstTimeRun = true;

Future displayPlay() async {
  if (await FlutterPackageManager.getPackageInfo("com.whatsapp") == null &&
      await FlutterPackageManager.getPackageInfo("com.whatsapp.w4b") == null &&
      await FlutterPackageManager.getPackageInfo("com.facebook.katana") ==
          null &&
      await FlutterPackageManager.getPackageInfo("com.facebook.lite") == null &&
      await FlutterPackageManager.getPackageInfo("com.facebook.orca") == null &&
      await FlutterPackageManager.getPackageInfo("com.facebook.mlite") ==
          null &&
      await FlutterPackageManager.getPackageInfo("com.zhiliaoapp.musically") ==
          null &&
      await FlutterPackageManager.getPackageInfo(
              "com.zhiliaoapp.musically.go") ==
          null &&
      await FlutterPackageManager.getPackageInfo("com.instagram.android") ==
          null) {
    return false;
  } else {
    return true;
  }
}

class MoviePage extends StatelessWidget {
  final int Movie_ID;
  final String Movie_Title;

  MoviePage(this.Movie_ID, this.Movie_Title);

  @override
  Widget build(BuildContext context) {
    return MoviePageBody(Movie_ID, Movie_Title);
  }
}

class MoviePageBody extends StatefulWidget {
  final int Movie_ID;
  final String Movie_Title;

  MoviePageBody(this.Movie_ID, this.Movie_Title);

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePageBody> {
  //Future<MovieData>? _loadfetchMovieData;
  Future? _displayPlay;
  Future<bool>? _checkFavorite;
  AdmobBannerSize? bannerSize;
  final _admobProvider = new AdmobProvider();
  InternetDetect _internetDetect = new InternetDetect();
  bool isInternetConnected = true;

  refresh() {
    _internetDetect.connexionChecker(this);
  }

  @override
  void initState() {
    super.initState();
    //print("se llama Init Movie");
    //_loadfetchMovieData = fetchMovieData(widget.Movie_ID);
    _checkFavorite = checkFavoritePost(widget.Movie_ID, 1);
    _displayPlay = displayPlay();
    bannerSize = AdmobBannerSize.BANNER;
    _internetDetect.connexionChecker(this);
  }

  @override
  void dispose() {
    super.dispose();
    firstTimeRun = true;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    SingleChildScrollView? singleChild;

    if (isInternetConnected) {
      singleChild = SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: FutureBuilder(
            future: Future.wait([
              fetchMovieData(widget.Movie_ID),
              //_loadfetchMovieData,
              displayPlay(),
              checkFavoritePost(widget.Movie_ID, 1)
            ]),
            /*future: fetchMovieData(widget.Movie_ID),*/
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasError)
                print(snapshot.error);
              else if (snapshot.hasData) {
                Widget playbtn;
                Widget playbtn_large;
                Widget paddingbtns;
                print(snapshot.data.toString());
                if (firstTimeRun) {
                  isFavorite = snapshot.data![2];
                  firstTimeRun = false;
                }

                //isFavorite = true;

                if (snapshot.data![1]) {
                  playbtn = Positioned(
                    top: screenHeight / 6,
                    left: screenWidth / 2.5,
                    child: BlurredContainer(
                      child: IconButton(
                        icon: Icon(Icons.play_arrow),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SelectLang(snapshot.data![0].movieStreams),
                                settings: RouteSettings(
                                    name: 'Seleccionar Idioma Película: ' +
                                        snapshot.data![0].movieName),
                              ));
                        },
                      ),
                    ),
                  );
                  playbtn_large = RawMaterialButton(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 90.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    fillColor: mainColor,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          "Ver ahora",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              new SelectLang(snapshot.data![0].movieStreams),
                          settings: RouteSettings(
                              name: 'Seleccionar Idioma Película: ' +
                                  snapshot.data![0].movieName),
                        ),
                      );
                    },
                  );

                  paddingbtns = Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        playbtn_large,
                        Spacer(),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xff212020),
                          child: IconButton(
                              color: mainColor,
                              icon: Icon(isFavorite!
                                  ? Icons.check_circle_rounded
                                  : Icons.add),
                              onPressed: () {
                                print(isFavorite.toString());
                                setState(() {
                                  if (isFavorite!) {
                                    isFavorite = false;
                                    removeFavoritePost(widget.Movie_ID, 1);
                                  } else {
                                    saveFavoritePost(widget.Movie_ID, 1);
                                    isFavorite = true;
                                  }
                                });
                              }),
                        ),
                        Spacer(),
                        /*
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xff212020),
                                child: IconButton(
                                  color: mainColor,
                                  icon: Icon(Icons.file_download),
                                  onPressed: () {
                                  },
                                ),
                              ),*/
                        Spacer(),
                      ],
                    ),
                  );
                } else {
                  playbtn = Container();
                  playbtn_large = Container();
                  paddingbtns = Container();
                }

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      height: screenHeight / 1.7,
                      child: Stack(children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                "https://image.tmdb.org/t/p/w1280" +
                                    snapshot.data![0].movieBackdrop),
                            fit: BoxFit.cover,
                          )),
                          foregroundDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                transparentColor,
                                scaffoldBackgroundColor
                              ],
                              stops: [0.0, 0.75],
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                            ),
                          ),
                        ),
                        playbtn,
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                snapshot.data![0].movieName,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(color: unselectedLabelColor),
                                    children: [
                                      TextSpan(
                                          text:
                                              snapshot.data![0].movieDuration),
                                      TextSpan(
                                          text: '   |   ',
                                          style: TextStyle()
                                              .copyWith(color: mainColor)),
                                      TextSpan(
                                        text: snapshot.data![0].movieCategories,
                                      ),
                                      TextSpan(
                                          text: '   |   ',
                                          style: TextStyle()
                                              .copyWith(color: mainColor)),
                                      TextSpan(
                                          text: snapshot.data![0].movieRelease),
                                      TextSpan(
                                          text: '   |   ',
                                          style: TextStyle()
                                              .copyWith(color: mainColor)),
                                    ],
                                  ),
                                ),
                              ),
                              paddingbtns,
                            ],
                          ),
                        ),
                      ]),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            ExpandText(
                              snapshot.data![0].movieContent,
                              hideArrowOnExpanded: true,
                              maxLines: 3,
                              style: TextStyle(
                                  color: lightTextColor, fontSize: 14),
                            ),
                          ],
                        )),
                    //TabSection(tab1: AppLocalizations.of(context).clips),
                  ],
                );
              }
              return Center(child: CircularProgressIndicator());
            }),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      body: FadedSlideAnimation(
        isInternetConnected
            ? singleChild!
            : NoInternetPage(notifyParent: refresh),
        beginOffset: Offset(0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.transparent,
        child: Builder(
          builder: (context) {
            final bottomAds = context.watch<AdBottomCubit>().state;
            if (bottomAds is LoadedBottomAds) {
              return bottomAds.adBottomWidget!;
            } else {
              return Container();
            }
          },
        ),
      ),
      /*bottomNavigationBar: Container(
        height: bannerSize!.height.toDouble(),
        color: Colors.transparent,
        child: _admobProvider.requestBannerBottom(bannerSize),
      ),*/
    );
  }
}
