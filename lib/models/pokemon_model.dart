class PokemonListing {
  final String name;
  final String url;

  PokemonListing({required this.name, required this.url});

  factory PokemonListing.fromJson(Map<String, dynamic> json) {
    return PokemonListing(name: json['name'], url: json['url']);
  }

  // Extrai o ID do Pokémon da URL para obter a imagem.
  String get imageUrl {
    final uriParts = url.split('/').where((part) => part.isNotEmpty).toList();
    final id = uriParts.last;
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final String imageUrl;
  final List<String> types;
  final List<String> abilities;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.imageUrl,
    required this.types,
    required this.abilities,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    // Garante que a imagem principal seja a oficial "dream world" se disponível, senão a padrão.
    final sprites = json['sprites'];
    String primaryImage = sprites['front_default'];
    if (sprites['other'] != null &&
        sprites['other']['official-artwork'] != null) {
      primaryImage =
          sprites['other']['official-artwork']['front_default'] ?? primaryImage;
    }

    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      imageUrl: primaryImage,
      types: (json['types'] as List)
          .map((typeInfo) => typeInfo['type']['name'] as String)
          .toList(),
      abilities: (json['abilities'] as List)
          .map((abilityInfo) => abilityInfo['ability']['name'] as String)
          .toList(),
    );
  }
}
