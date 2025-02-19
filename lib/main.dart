import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 3, 255, 221)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void _notifyOnChange(void Function() func) {
    func();
    notifyListeners();
  }


  void getNextRandomWord() => _notifyOnChange(() {
        current = WordPair.random();
      });

  void toggleFavorite() => _notifyOnChange(() {
        if (favorites.contains(current)) {
          favorites.remove(current);
        } else {
          favorites.add(current);
        }
      });

  void removeFavoritesAt(int index) => _notifyOnChange(() {
        favorites.removeAt(index);
      });
}

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ...

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // ← Add this property.

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex, // ← Change to this.
                onDestinationSelected: (value) {
        
                  // ↓ Replace print with this.
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    }
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var favoritesList = appState.favorites;

    if (favoritesList.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        Text("You have ${favoritesList.length} favorites"),
        Expanded(
          child: ListView.builder(
              itemCount: favoritesList.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(favoritesList[index].toString()),
                  onDismissed: (direction) {
                    appState.removeFavoritesAt(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 4.0, right: 4.0, bottom: 15.0),
                    child: Card(
                      color: theme.secondaryHeaderColor,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              favoritesList[index].asPascalCase,
                              textAlign: TextAlign.center,
                            ),
                            trailing: IconButton(
                                icon: Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                onPressed: () {
                                  appState.removeFavoritesAt(index);
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}

// ...
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNextRandomWord();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;
  @override
  Widget build(BuildContext context) {
  var theme = Theme.of(context);
 final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
          child: Text(pair.asPascalCase,
              style: style, semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}