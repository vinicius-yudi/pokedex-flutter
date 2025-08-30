import 'package:flutter/foundation.dart';
import '../models/pokemon_model.dart';

class FavoritesProvider with ChangeNotifier {
  final List<PokemonListing> _favorites = [];

  // Getter para acessar a lista de favoritos de forma segura.
  List<PokemonListing> get favorites => _favorites;

  // Adiciona um Pokémon aos favoritos e notifica os ouvintes.
  void addFavorite(PokemonListing pokemon) {
    if (!isFavorite(pokemon)) {
      _favorites.add(pokemon);
      notifyListeners(); // Notifica os widgets que a lista mudou.
    }
  }

  // Remove um Pokémon dos favoritos e notifica os ouvintes.
  void removeFavorite(PokemonListing pokemon) {
    _favorites.removeWhere((p) => p.name == pokemon.name);
    notifyListeners();
  }

  // Verifica se um Pokémon já está na lista de favoritos.
  bool isFavorite(PokemonListing pokemon) {
    return _favorites.any((p) => p.name == pokemon.name);
  }

  // Método para alternar o estado de favorito.
  void toggleFavorite(PokemonListing pokemon) {
    if (isFavorite(pokemon)) {
      removeFavorite(pokemon);
    } else {
      addFavorite(pokemon);
    }
  }
}