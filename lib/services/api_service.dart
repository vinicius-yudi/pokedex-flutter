import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class ApiService {
  static const String _baseUrl = 'pokeapi.co';

  // Busca uma lista paginada de Pokémon.
  Future<List<PokemonListing>> fetchPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    final uri = Uri.https(_baseUrl, '/api/v2/pokemon', {
      'offset': offset.toString(),
      'limit': limit.toString(),
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((e) => PokemonListing.fromJson(e)).toList();
      } else {
        throw Exception('Falha ao carregar a lista de Pokémon');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Busca os detalhes de um Pokémon específico pela sua URL.
  Future<PokemonDetail> fetchPokemonDetails(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return PokemonDetail.fromJson(json.decode(response.body));
      } else {
        throw Exception('Falha ao carregar detalhes do Pokémon');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Busca um Pokémon pelo nome ou ID.
  Future<PokemonDetail> searchPokemon(String nameOrId) async {
    final uri = Uri.https(
      _baseUrl,
      '/api/v2/pokemon/${nameOrId.toLowerCase()}',
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return PokemonDetail.fromJson(json.decode(response.body));
      } else {
        throw Exception('Pokémon não encontrado');
      }
    } catch (e) {
      throw Exception('Erro ao buscar Pokémon: $e');
    }
  }
}
