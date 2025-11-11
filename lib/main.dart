import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokemonApp());
}

/// Root widget of the app
class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Green Cards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

/// ------------------------------
/// HOME SCREEN (with bottom navigation)
/// ------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Two screens: All cards and Battle view
  final List<Widget> _screens = [
    const CardListScreen(),
    const BattleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "All Cards",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_martial_arts),
            label: "Battle",
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
/// ALL CARDS SCREEN
/// ------------------------------
class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final String apiUrl =
      "https://raw.githubusercontent.com/Armaan5628/pokemonapi/refs/heads/main/api.json";

  List<dynamic> cards = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  /// Fetch Pokémon data from hosted JSON (avoids CORS issue)
  Future<void> fetchCards() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cards = data["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load cards (Code: ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading data: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pokémon Green Cards")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final name = card["name"] ?? "Unknown";
                    final imageUrl = card["images"]?["small"] ??
                        "https://via.placeholder.com/150";

                    // Each list tile shows Pokémon name + small image
                    return ListTile(
                      leading: Image.network(imageUrl, width: 50, height: 50),
                      title: Text(name),
                      onTap: () {
                        // Opens a popup with full card view
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            insetPadding:
                                const EdgeInsets.all(20), // spacing from screen edges
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Card name title
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Image fits entire card properly
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height:
                                        MediaQuery.of(context).size.height * 0.6,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        card["images"]?["large"] ?? imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Close button
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Close"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

/// ------------------------------
/// BATTLE SCREEN
/// ------------------------------
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final String apiUrl =
      "https://raw.githubusercontent.com/Armaan5628/pokemonapi/refs/heads/main/api.json";

  Map<String, dynamic>? card1;
  Map<String, dynamic>? card2;
  String result = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAndBattle();
  }

  /// Fetch two random cards and compare their HP values
  Future<void> fetchAndBattle() async {
    setState(() {
      isLoading = true;
      result = "";
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cards = List<Map<String, dynamic>>.from(data["data"]);

        final random = Random();
        final index1 = random.nextInt(cards.length);
        int index2 = random.nextInt(cards.length);
        while (index2 == index1) {
          index2 = random.nextInt(cards.length);
        }

        setState(() {
          card1 = cards[index1];
          card2 = cards[index2];
          result = calculateWinner(card1!, card2!);
          isLoading = false;
        });
      } else {
        setState(() {
          result = "Failed to fetch cards (Code: ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        result = "Error fetching data: $e";
        isLoading = false;
      });
    }
  }

  /// Compare HP and decide the winner
  String calculateWinner(Map<String, dynamic> c1, Map<String, dynamic> c2) {
    int hp1 = int.tryParse(c1["hp"] ?? "0") ?? 0;
    int hp2 = int.tryParse(c2["hp"] ?? "0") ?? 0;

    if (hp1 > hp2) {
      return "🏆 Winner: ${c1["name"]} (HP: $hp1)";
    } else if (hp2 > hp1) {
      return "🏆 Winner: ${c2["name"]} (HP: $hp2)";
    } else {
      return "🤝 It's a tie! (HP: $hp1 each)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pokémon Battle Arena")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (card1 != null && card2 != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        pokemonCardView(card1!),
                        pokemonCardView(card2!),
                      ],
                    ),
                  const SizedBox(height: 25),
                  Text(
                    result,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: fetchAndBattle,
                    icon: const Icon(Icons.casino),
                    label: const Text("Play Again"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
    );
  }

  /// Displays one Pokémon card in battle mode
  Widget pokemonCardView(Map<String, dynamic> card) {
    final imageUrl = card["images"]?["large"] ??
        "https://via.placeholder.com/300x420.png?text=No+Image";
    final name = card["name"] ?? "Unknown";
    final hp = card["hp"] ?? "0";

    return Expanded(
      child: Column(
        children: [
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text("HP: $hp",
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }
}
