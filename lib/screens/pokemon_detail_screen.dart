import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon_model.dart';
import '../services/api_service.dart';
import '../providers/favorites_provider.dart';
import '../utils/type_color_util.dart';

// Tela que exibe os detalhes de um Pokémon específico.
class PokemonDetailScreen extends StatefulWidget {
  final PokemonListing pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final ApiService _apiService = ApiService();
  // Future para armazenar o resultado da chamada da API.
  late Future<PokemonDetail> _pokemonDetailFuture;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos detalhes do Pokémon assim que a tela é construída.
    _pokemonDetailFuture = _apiService.fetchPokemonDetails(widget.pokemon.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Permite que o corpo da tela se estenda por trás da AppBar, criando um efeito de sobreposição.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.pokemon.name.toUpperCase()),
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0,
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              final isFavorite = favoritesProvider.isFavorite(widget.pokemon);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.yellow : Colors.white,
                ),
                onPressed: () {
                  // Alterna o status de favorito ao ser pressionado.
                  favoritesProvider.toggleFavorite(widget.pokemon);
                },
              );
            },
          ),
        ],
      ),
      // FutureBuilder constrói a UI com base no estado da requisição (carregando, erro, sucesso).
      body: FutureBuilder<PokemonDetail>(
        future: _pokemonDetailFuture,
        builder: (context, snapshot) {
          final detail = snapshot.data;
          // Determina a cor de fundo com base no primeiro tipo do Pokémon.
          final primaryType =
              detail?.types.isNotEmpty ?? false ? detail!.types.first : 'normal';
          final backgroundColor = getColorForType(primaryType);

          // Stack é usado para sobrepor widgets. Aqui, o conteúdo fica sobre o fundo gradiente.
          return Stack(
            children: [
              // Camada 1: O fundo com gradiente que preenche toda a tela.
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [backgroundColor.withOpacity(0.7), backgroundColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Camada 2: O conteúdo, dentro de um SafeArea para evitar áreas do sistema (notch, etc.).
              SafeArea(
                child: _buildBodyContent(snapshot),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Constrói o conteúdo principal da tela com base no estado do [AsyncSnapshot].
  Widget _buildBodyContent(AsyncSnapshot<PokemonDetail> snapshot) {
    // Exibe um indicador de progresso enquanto os dados estão sendo carregados.
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    // Exibe uma mensagem de erro se a requisição falhar.
    if (snapshot.hasError) {
      return Center(
          child: Text('Erro: ${snapshot.error}',
              style: const TextStyle(color: Colors.white)));
    }
    // Exibe uma mensagem se nenhum dado for encontrado.
    if (!snapshot.hasData) {
      return const Center(
          child: Text('Nenhum detalhe encontrado.',
              style: TextStyle(color: Colors.white)));
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
                  : const CircularProgressIndicator(color: Colors.white);
            },
            // Mostra um ícone de erro se a imagem não puder ser carregada.
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.white, size: 100),
          ),
          const SizedBox(height: 20),
          Text(
            '#${detail.id} - ${detail.name.toUpperCase()}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 2, color: Colors.black45, offset: Offset(0, 2))
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(context, detail),
        ],
      ),
    );
  }

  /// Constrói o card com as informações detalhadas do Pokémon (altura, peso, etc.).
  Widget _buildInfoCard(BuildContext context, PokemonDetail detail) {
    return Card(
      color: Colors.white.withOpacity(0.85),
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

  /// Constrói uma linha padronizada para exibir uma informação (label e valor).
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          Text(value,
              style: const TextStyle(fontSize: 18, color: Colors.black54)),
        ],
      ),
    );
  }
}