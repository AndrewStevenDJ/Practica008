import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/bloc/pokemon_card_bloc.dart';

class TypeFilterDrawer extends StatefulWidget {
  const TypeFilterDrawer({super.key});

  @override
  State<TypeFilterDrawer> createState() => _TypeFilterDrawerState();
}

class _TypeFilterDrawerState extends State<TypeFilterDrawer> {
  // Lista de todos los tipos disponibles en Pokémon TCG
  static const availableTypes = [
    'Colorless',
    'Darkness',
    'Dragon',
    'Fairy',
    'Fighting',
    'Fire',
    'Grass',
    'Lightning',
    'Metal',
    'Psychic',
    'Water',
  ];

  late Set<String> selectedTypes;

  @override
  void initState() {
    super.initState();
    selectedTypes = Set.from(
      context.read<PokemonCardBloc>().state.activeFilters,
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'lightning':
        return Colors.yellow.shade700;
      case 'psychic':
        return Colors.purple;
      case 'fighting':
        return Colors.red.shade900;
      case 'darkness':
        return Colors.grey.shade800;
      case 'metal':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pink;
      case 'dragon':
        return Colors.indigo;
      case 'colorless':
        return Colors.grey.shade400;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water_drop;
      case 'grass':
        return Icons.grass;
      case 'lightning':
        return Icons.flash_on;
      case 'psychic':
        return Icons.psychology;
      case 'fighting':
        return Icons.sports_martial_arts;
      case 'darkness':
        return Icons.dark_mode;
      case 'metal':
        return Icons.hardware;
      case 'fairy':
        return Icons.auto_awesome;
      case 'dragon':
        return Icons.whatshot;
      case 'colorless':
        return Icons.circle_outlined;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.filter_list, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Filtrar por Tipo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: availableTypes.map((type) {
                final isSelected = selectedTypes.contains(type);
                final color = _getTypeColor(type);
                final icon = _getTypeIcon(type);

                return CheckboxListTile(
                  title: Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 12),
                      Text(type),
                    ],
                  ),
                  value: isSelected,
                  activeColor: color,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedTypes.add(type);
                      } else {
                        selectedTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (selectedTypes.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedTypes.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Limpiar Filtros'),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<PokemonCardBloc>()
                        .add(TypeFilterChanged(selectedTypes));
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: Text(
                    selectedTypes.isEmpty
                        ? 'Ver Todas'
                        : 'Aplicar (${selectedTypes.length})',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
