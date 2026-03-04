import 'package:flutter/material.dart';

enum PowerUpType {
  secondChance,
  fiftyFifty,
  doubleDown,
}

extension PowerUpTypeExtension on PowerUpType {
  String get label {
    switch (this) {
      case PowerUpType.secondChance:
        return 'Retry'; // Shorter label for UI
      case PowerUpType.fiftyFifty:
        return '50/50';
      case PowerUpType.doubleDown:
        return '2x Pts';
    }
  }

  IconData get icon {
    switch (this) {
      case PowerUpType.secondChance:
        return Icons.favorite_rounded;
      case PowerUpType.fiftyFifty:
        return Icons.remove_circle_outline_rounded; // Or bomb
      case PowerUpType.doubleDown:
        return Icons.keyboard_double_arrow_up_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PowerUpType.secondChance:
        return Colors.redAccent;
      case PowerUpType.fiftyFifty:
        return Colors.orangeAccent;
      case PowerUpType.doubleDown:
        return Colors.blueAccent;
    }
  }

  String get description {
    switch (this) {
      case PowerUpType.secondChance:
        return 'Survive one wrong answer.';
      case PowerUpType.fiftyFifty:
        return 'Remove two wrong options.';
      case PowerUpType.doubleDown:
        return 'Double points for this question.';
    }
  }
}

class PowerUpLoadout {
  final Map<PowerUpType, int> items;
  final String id;
  final String name;

  const PowerUpLoadout({
    required this.id,
    required this.name,
    required this.items,
  });

  static const PowerUpLoadout disabled = PowerUpLoadout(
    id: 'disabled',
    name: 'Disabled',
    items: {},
  );

  static const PowerUpLoadout balanced = PowerUpLoadout(
    id: 'balanced',
    name: 'Balanced',
    items: {
      PowerUpType.secondChance: 1,
      PowerUpType.fiftyFifty: 1,
      PowerUpType.doubleDown: 1,
    },
  );

  static const PowerUpLoadout chaos = PowerUpLoadout(
    id: 'chaos',
    name: 'Chaos',
    items: {
      PowerUpType.secondChance: 0,
      PowerUpType.fiftyFifty: 3,
      PowerUpType.doubleDown: 3,
    },
  );

  static const PowerUpLoadout survivor = PowerUpLoadout(
    id: 'survivor',
    name: 'Survivor',
    items: {
      PowerUpType.secondChance: 3,
      PowerUpType.fiftyFifty: 0,
      PowerUpType.doubleDown: 0,
    },
  );

  static PowerUpLoadout fromId(String? id) {
    switch (id) {
      case 'balanced':
        return balanced;
      case 'chaos':
        return chaos;
      case 'survivor':
        return survivor;
      case 'disabled':
      default:
        return disabled; // Default to Disabled for safety/clean slate if null
    }
  }
}
