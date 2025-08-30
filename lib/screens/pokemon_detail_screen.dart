import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon_model.dart';
import '../services/api_service.dart';
import '../providers/favorites_provider.dart';

class PokemonDetailScreen extends StatefulWidget {
  final PokemonListing pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<PokemonDetail> _pokemonDetailFuture;

  @override
  void initState() {
    super.initState();
    _pokemonDetailFuture = _apiService.fetchPokemonDetails(widget.pokemon.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemon.name.toUpperCase()),
        actions: [
          // O Consumer reconstrói apenas o ícone quando o estado de favoritos muda.
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              final isFavorite = favoritesProvider.isFavorite(widget.pokemon);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.yellow : Colors.white,
                ),
                onPressed: () {
                  favoritesProvider.toggleFavorite(widget.pokemon);
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<PokemonDetail>(
        future: _pokemonDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum detalhe encontrado.'));
          }

          final detail = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  detail.imageUrl,
                  height: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : const CircularProgressIndicator();
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  '#${detail.id} - ${detail.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(context, detail),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, PokemonDetail detail) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoRow('Altura', '${detail.height / 10} m'),
            const Divider(),
            _buildInfoRow('Peso', '${detail.weight / 10} kg'),
            const Divider(),
            _buildInfoRow('Tipos', detail.types.join(', ')),
            const Divider(),
            _buildInfoRow('Habilidades', detail.abilities.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
