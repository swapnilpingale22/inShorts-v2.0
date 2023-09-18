import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_model.dart';
import '../secrets/secrets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String selectedCategory = 'general'; // Default category
  String searchQuery = ''; // User's search query

  Future<NewsModel> loadNews() async {
    String categoryUrl =
        "https://newsapi.org/v2/top-headlines?country=in&category=$selectedCategory&q=$searchQuery&pageSize=100&apiKey=$apiKey";

    final response = await http.get(Uri.parse(categoryUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      final NewsModel newsData = NewsModel.fromJson(jsonData);
      return newsData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Function to open URLs
  void launchThisUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(
        Uri.parse(url),
        mode: LaunchMode.inAppWebView,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to handle category selection
  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  // Function to handle search query submission
  void submitSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<NewsModel>(
        future: loadNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error.toString()}',
              ),
            );
          } else if (snapshot.hasData) {
            final NewsModel news = snapshot.data!;
            return PageView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: news.articles.length,
              itemBuilder: (context, index) {
                DateTime publishedAt =
                    DateTime.parse(news.articles[index].publishedAt);
                Duration difference = DateTime.now().difference(publishedAt);
                String timeAgo = formatDuration(difference);

                return GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx < 0) {
                      launchThisUrl(
                        news.articles[index].url,
                      );
                    }
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 300,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl:
                                  news.articles[index].urlToImage.toString(),
                              cacheKey:
                                  news.articles[index].urlToImage.toString(),
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Center(
                                      child: Text('No Image available')),
                            ),
                          ),
                          Positioned(
                            right: 7,
                            top: 25,
                            child: CircleAvatar(
                              backgroundColor: Colors.black87,
                              child: Text(
                                '${index + 1}/${news.articles.length.toString()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            //source name
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '⚪ ${news.articles[index].source.name}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Hubballi",
                                  ),
                                ),
                                Text(
                                  '⌚ $timeAgo ago',
                                  // '⌚ ${news.articles[index].publishedAt}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Hubballi",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            //headline
                            Text(
                              news.articles[index].title,
                              maxLines: 3,
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            //Sub headline
                            (news.articles[index].description.toString() !=
                                    'null')
                                ? Text(
                                    news.articles[index].description.toString(),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Hubballi",
                                    ),
                                  )
                                : const Text(''),

                            const SizedBox(height: 10),
                            //news content
                            Text(
                              news.articles[index].content.toString() != 'null'
                                  ? news.articles[index].content
                                      .toString()
                                      .substring(
                                          0,
                                          news.articles[index].content
                                                  .toString()
                                                  .length -
                                              15)
                                  : '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: "Hubballi",
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'No data available',
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search News',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              // Trigger search when the search icon is pressed.
                              submitSearchQuery(searchQuery);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        onChanged: (value) {
                          // Update the search query as the user types.
                          searchQuery = value;
                        },
                        onSubmitted: (value) {
                          // Trigger search when the user presses Enter on the keyboard.
                          submitSearchQuery(value);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.currency_rupee),
                      title: const Text('Business'),
                      onTap: () {
                        selectCategory('business');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_movies),
                      title: const Text('Entertainment'),
                      onTap: () {
                        selectCategory('entertainment');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_hospital),
                      title: const Text('Health'),
                      onTap: () {
                        selectCategory('health');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.science),
                      title: const Text('Science'),
                      onTap: () {
                        selectCategory('science');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.sports_baseball),
                      title: const Text('Sports'),
                      onTap: () {
                        selectCategory('sports');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.computer),
                      title: const Text('Technology'),
                      onTap: () {
                        selectCategory('technology');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.assignment),
                      title: const Text('General'),
                      onTap: () {
                        selectCategory('general');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.category),
      ),
    );
  }

  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}
