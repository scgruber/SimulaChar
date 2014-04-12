library sc_action;

import 'character.dart';

abstract class Action {
  bool isAvailable(Character char);
}

class MeleeAttackAction implements Action {
  bool isAvailable(Character char) {
    return char.adjacentFoes != [];
  }
}