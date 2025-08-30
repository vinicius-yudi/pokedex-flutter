import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/api_service.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';
import 'favorites_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  _PokedexScreenState createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<PokemonListing> _pokemonList = [];
  int _offset = 0;
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialPokemon();
  }

  Future<void> _loadInitialPokemon() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final initialList = await _apiService.fetchPokemonList(offset: 0);
      setState(() {
        _pokemonList = initialList;
        _offset = 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePokemon() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final morePokemon = await _apiService.fetchPokemonList(offset: _offset);
      setState(() {
        _pokemonList.addAll(morePokemon);
        _offset += 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _searchPokemon() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() => _isSearching = true);
    
    try {
      final pokemonDetail = await _apiService.searchPokemon(query);
      final pokemonListing = PokemonListing(
        name: pokemonDetail.name,
        url: 'https://pokeapi.co/api/v2/pokemon/${pokemonDetail.id}/'
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PokemonDetailScreen(pokemon: pokemonListing),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por nome ou ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchPokemon(),
                  ),
                ),
                const SizedBox(width: 8),
                _isSearching
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _searchPokemon,
                        child: const Text('Buscar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                        ),
                      ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _pokemonList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Erro: $_error'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _pokemonList.length + 1,
      itemBuilder: (context, index) {
        if (index < _pokemonList.length) {
          final pokemon = _pokemonList[index];
          return PokemonCard(
            pokemon: pokemon,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                ),
              );
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ElevatedButton(
                      onPressed: _loadMorePokemon,
                      child: const Text('Carregar Mais'),
                    ),
                  ),
          );
        }
      },
    );
  }
}