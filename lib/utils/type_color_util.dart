import 'package:flutter/material.dart';

/// Retorna uma cor baseada no tipo do Pokémon.
///
/// As cores foram escolhidas para representar bem cada tipo.
Color getColorForType(String type) {
  switch (type.toLowerCase()) {
    case 'fire':
      return Colors.orange[700]!;
    case 'water':
      return Colors.blue[700]!;
    case 'grass':
      return Colors.green[600]!;
    case 'electric':
      return Colors.yellow[600]!;
    case 'psychic':
      return Colors.purple[600]!;
    case 'ice':
      return Colors.cyan[300]!;
    case 'dragon':
      return Colors.indigo[700]!;
    case 'dark':
      return Colors.brown[800]!;
    case 'fairy':
      return Colors.pinkAccent[100]!;
    case 'normal':
      return Colors.grey[600]!;
    case 'fighting':
      return Colors.red[800]!;
    case 'flying':
      return Colors.indigo[300]!;
    case 'poison':
      return Colors.purple[800]!;
    case 'ground':
      return Colors.brown[600]!;
    case 'rock':
      return Colors.grey[800]!;
    case 'bug':
      return Colors.lightGreen[700]!;
    case 'ghost':
      return Colors.indigo[900]!;
    case 'steel':
      return Colors.blueGrey[700]!;
    default:
      return Colors.grey[700]!;
  }
}
