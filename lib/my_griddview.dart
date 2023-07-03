import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class MyGridView extends StatefulWidget {
  const MyGridView({super.key});

  @override
  State<MyGridView> createState() => _MyGridViewState();
}

class _MyGridViewState extends State<MyGridView> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> listMovies = [];

  bool isLoading = false;
  int page = 1;

  static const String BASE_URL = "api.themoviedb.org";

  static const String TMDB_API_KEY = "6a2a157904b466e6ed63be4bca9f7eb1";
  static final String API_KEY_KEY = "api_key";

  static final String PAGE_KEY = "page";

  @override
  void initState() {
    super.initState();

    _getMoviesList(1);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  _getMoviesList(int page) async {
    setState(() {
      isLoading = true;
    });

    Uri url = Uri.https(BASE_URL, "/3/movie/popular",
        {API_KEY_KEY: TMDB_API_KEY, PAGE_KEY: page.toString()});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      listMovies = res['results'];
    }

    setState(() {
      isLoading = false;
    });
  }

  _getSearchMoviesList(String strSearch) async {
    setState(() {
      isLoading = true;
    });

    Uri url = Uri.https(BASE_URL, "/3/search/movie",
        {'query': strSearch, API_KEY_KEY: TMDB_API_KEY});
    final response = await http.get(url);

    listMovies.clear();
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      listMovies = res['results'];
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Positioned.fill(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  if (searchController.text.isEmpty) {
                    _getMoviesList(1);
                    return;
                  } else {
                    _getSearchMoviesList(searchController.text);
                  }
                },
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_outlined),
                  hoverColor: Colors.white,
                  labelText: 'Search',
                  labelStyle: TextStyle(
                      color: Colors.black45,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ))),
      Positioned.fill(
        top: 90,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: isLoading
              ? _placeholder1()
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  scrollDirection: Axis.vertical,
                  itemCount: listMovies.length + 1,
                  itemBuilder: (context, index) {
                    if (index < listMovies.length) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20.0, left: 10, right: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  _showMovieDetail(
                                      context, listMovies[index], index);
                                },
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: const Color(0XFFECECEC)),
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: const <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(1.0, 15.0),
                                        blurRadius: 20.0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: listMovies[index]
                                                          ['backdrop_path'] ==
                                                      null
                                                  ? CachedNetworkImageProvider(
                                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrJgwdOAjqaZGS7kn35IVm_ZN6E4XFuJ7V_g&usqp=CAU')
                                                  : CachedNetworkImageProvider(
                                                      "https://www.themoviedb.org/t/p/w220_and_h330_face" +
                                                          listMovies[index][
                                                                  'backdrop_path']
                                                              .toString())),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            listMovies[index]['title'],
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ]),
                      );
                    } else {
                      _loadMore();
                      return _placeholder2();
                    }
                  }),
        ),
      ),
    ]));
  }

  _loadMore() async {
    page++;
    Uri url = Uri.https(BASE_URL, "/3/movie/popular",
        {API_KEY_KEY: TMDB_API_KEY, PAGE_KEY: page.toString()});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      listMovies += res['results'];
    }
    setState(() {});
  }

  _placeholder1() {
    return GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        scrollDirection: Axis.vertical,
        itemCount: 10,
        itemBuilder: (context, index) {
          return _placeholder2();
        });
  }

  _placeholder2() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 10, right: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              // height: 300,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0XFFECECEC)),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(1.0, 15.0),
                    blurRadius: 20.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: double.infinity,
                      height: 110,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 50,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ]),
    );
  }

  _showMovieDetail(context, item, index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 600,
                maxWidth: 450,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: item['backdrop_path'] == null
                              ? CachedNetworkImageProvider(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrJgwdOAjqaZGS7kn35IVm_ZN6E4XFuJ7V_g&usqp=CAU')
                              : CachedNetworkImageProvider(
                                  "https://www.themoviedb.org/t/p/w220_and_h330_face" +
                                      item['backdrop_path'].toString())),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildTitle("Title : "),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildDescription1(item['title']),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildTitle("Overview : "),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildDescription1(item['overview']),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildDescription2(
                      'Ratings : ', item['vote_count'].toString()),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildDescription2(
                      'Release Date : ', item['release_date'].toString()),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Close",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  _buildTitle(String strTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          strTitle,
          style: const TextStyle(
              color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  _buildDescription1(String description) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        description,
        style: const TextStyle(
            color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  _buildDescription2(String title, String description) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              description,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ));
  }
}
