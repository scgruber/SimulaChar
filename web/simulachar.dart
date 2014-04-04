import 'dart:html';

import 'globals.dart';
import 'character.dart' show Character;
import 'initiative.dart' show Initiative;
import 'log.dart' show makeLog;

void main() {
  gMap = querySelector('#map');
  gControlPanel = querySelector('#controls');
  gInitiative = new Initiative();
  
  var billy = new Character("Billy","#ff0000");
  gInitiative.add(billy);
  var alphonse = new Character("Alphonse", "#0000ff");
  gInitiative.add(alphonse);
  
  querySelector('#step-forward').addEventListener("click", stepForward);
}

void stepForward(Event ev) {
  Character active = gInitiative.currentCharacter;
  Character target = gInitiative.chars.firstWhere((c) => active != c);
  // Try an attack from the current character, then advance the initiative
  String logMsg = active.name + " attacked " + target.name + ". ";
  int damage = active.tryAttack(target);
  if (damage > 0) {
    target.takeDamage(damage);
    logMsg += "Attack succeeded: " + target.name + " takes " + damage.toString() + " damage. ";
  } else {
    logMsg += "Attack failed. ";
  }
  makeLog(logMsg);
  
  gInitiative.advance();
}