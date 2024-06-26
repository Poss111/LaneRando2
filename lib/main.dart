import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lanerando/models/champions.dart';
import 'package:url_launcher/url_launcher.dart';

import 'clients/riot_client.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

const Map<String, String> laneIdToLane = {
  'top-lane': 'Top',
  'jg': 'Jungle',
  'mid-lane': 'Mid',
  'bot-lane': 'Bot',
  'support-lane': 'Support',
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lane Rando!',
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      home: const MyHomePage(title: 'Lane Rando!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: SlideTransition(
            position: _offsetAnimation,
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SlideTransition(
                  position: _offsetAnimation,
                  child: Card.outlined(
                    child: ListTile(
                        title: Center(
                          child: Text(
                              'A simple app to have some fun with League of Legends and randomize your champion picks for each of your team members.',
                              style: Theme.of(context).textTheme.bodyLarge),
                        )),
                  ),
                ),
                const RandomChampionsWidget(),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(children: [
                      Text(
                        'Last Updated: 3/30/2024',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ]),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          text: 'Made By: Daniel Poss ',
                          style: Theme.of(context).textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: '(Poss111)',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrl(Uri.parse(
                                      "https://github.com/Poss111"));
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            // Positioned(
            //     bottom: 100, left: 30, child: GitHubCard(username: "Poss111")),
          ],
        ));
  }
}

class StaggeredAnimation {
  final AnimationController controller;
  final int index;
  final Animation<double> animation;

  StaggeredAnimation({
    required this.controller,
    required this.index,
  }) : animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              (index + 1) * 0.2,
              1.0,
              curve: Curves.easeInOut,
            ),
          ),
        );
}

class RandomChampionsWidget extends StatefulWidget {
  const RandomChampionsWidget({Key? key}) : super(key: key);

  @override
  State<RandomChampionsWidget> createState() => _RandomChampionsWidget();
}

class _RandomChampionsWidget extends State<RandomChampionsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  List<Champion> championNames = [];

  List<StaggeredAnimation> _animations = [];
  List<String> laneNames = laneIdToLane.keys.toList();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    for (int i = 0; i < 5; i++) {
      _animations.add(
        StaggeredAnimation(
          controller: _controller,
          index: i,
        ),
      );
    }

    retrieveRandomChampionNames();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void retrieveRandomChampionNames() {

    for (int i = 0; i < 5; i++) {
    _animations.add(
        StaggeredAnimation(
          controller: _controller,
          index: i,
        )
      );
    }
    _animations.forEach((element) {
      element.controller.reset();
      element.controller.forward();
    });
    getRandomUniqueChampionNames(5)
        .then((value) => setState(() {
              championNames = value;
            }))
        .catchError((error) => SnackBar(content: Text('Woops! $error')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Champion>>(
        future: getRandomUniqueChampionNames(5),
        builder:
            (BuildContext context, AsyncSnapshot<List<Champion>> snapshot) {
          if (snapshot.hasData) {
            return Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    return FadeTransition(
                      opacity: _animations[index].animation,
                      child: RotationTransition(
                        turns: _animations[index].animation,
                        child: SlideTransition(
                          position: _offsetAnimation,
                          child: ImageAndTextWidgetTwo(
                            svgPath: "assets/images/${laneNames[index]}.svg",
                            champion: championNames[index],
                            delay: (index + 1) * 200,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  width: 200,
                  child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: retrieveRandomChampionNames,
                            child: const Text('Randomize!'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy current names to clipboard',
                          onPressed: () {
                            String championListText =
                                championNames.asMap().entries.map((e) {
                              return "${laneIdToLane.keys.elementAt(e.key)} ${e.value.parsedName}";
                            }).join(', \n');
                            FlutterClipboard.copy(championListText)
                                .then((result) {
                              const snackBar = SnackBar(
                                content: Text('Copied to Clipboard'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            });
                          },
                        )
                      ]),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            // Handle error state
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class ImageAndTextWidgetTwo extends StatefulWidget {
  const ImageAndTextWidgetTwo({
    Key? key,
    required this.svgPath,
    required this.champion,
    this.delay = 0,
  }) : super(key: key);

  final String svgPath;
  final Champion champion;
  final int delay;

  @override
  State<ImageAndTextWidgetTwo> createState() => _ImageAndTextWidgetTwoState();
}

class _ImageAndTextWidgetTwoState extends State<ImageAndTextWidgetTwo> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          getChampionImageURL(widget.champion.rawName),
          key: ValueKey<String>(widget.champion.rawName),
          width: 150,
          height: 150,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
        Positioned(
          top: 16,
          left: 16,
          child: SvgPicture.asset(
            widget.svgPath,
            width: 32,
            height: 32,
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              widget.champion.parsedName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GitHubCard extends StatefulWidget {
  final String username;
  bool isExpanded = false;

  GitHubCard({required this.username});

  @override
  _GitHubCardState createState() => _GitHubCardState();
}

class _GitHubCardState extends State<GitHubCard> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  fetchUserData() async {
    var response = await http
        .get(Uri.parse('https://api.github.com/users/${widget.username}'));
    var jsonData = jsonDecode(response.body);
    setState(() {
      userData = jsonData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isExpanded
        ? Card(
            child: userData == null
                ? CircularProgressIndicator()
                : ExpansionTile(
                    title: Image.network(
                      userData!['avatar_url'],
                      height: 30,
                      width: 30,
                    ),
                    children: [
                      ListTile(
                        leading: Image.network(userData!['avatar_url']),
                        title: Text(userData!['name'] ?? 'No name provided'),
                        subtitle: Text(userData!['bio'] ?? 'No bio provided'),
                        trailing: ElevatedButton(
                            child: const Text('Follow'),
                            onPressed: () => {
                                  launchUrl(
                                      Uri.parse("https://github.com/Poss111"))
                                }),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text('${userData!['followers'] ?? 0}'),
                                  const Text('Followers'),
                                ],
                              ),
                              const VerticalDivider(
                                color: Colors.grey,
                                indent: 10,
                                endIndent: 10,
                              ),
                              Column(
                                children: [
                                  Text('${userData!['public_gists'] ?? 0}'),
                                  Text('Gists'),
                                ],
                              ),
                              const VerticalDivider(
                                color: Colors.grey,
                                indent: 10,
                                endIndent: 10,
                              ),
                              Column(
                                children: [
                                  Text('${userData!['public_repos'] ?? 0}'),
                                  Text('Repos'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                          leading: Text.rich(TextSpan(
                        text: 'Lane Rando Github Repository',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse("https://github.com/Poss111"));
                          },
                      ))),
                    ],
                  ),
          )
        : IconButton(
            onPressed: () => {
              setState(() {
                widget.isExpanded = !widget.isExpanded;
              })
            },
            icon: Card(
                margin: EdgeInsets.all(10),
                child: Image.network(
                  userData!['avatar_url'],
                  height: 60,
                  width: 60,
                )),
            iconSize: 30,
          );
  }
}
