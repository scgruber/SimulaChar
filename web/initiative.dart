library sc_initiative;

import 'character.dart';
import 'log.dart' show makeLog;

// TODO implement this as a circular linked list
class Initiative {
  List<Character> chars;
  Map<Character,int> inits;
  int now;
  
  Initiative() {
    chars = new List<Character>();
    inits = new Map<Character,int>();
    now = 0;
  }
  
  void advance() {
    now = (now+1)%(chars.length);
  }
  
  Character get currentCharacter { return chars[now]; }
  int get currentInitiative { return inits[chars[now]]; }
  
  void add(Character char) {
    int initiative = char.initiative;
    inits.putIfAbsent(char, () => initiative);
    bool added = false;
    for (int iChar = 0; iChar < chars.length; iChar++) {
      if (inits[chars[iChar]] < initiative) {
        chars.insert(iChar, char);
        if (now >= iChar) { now++; }
        added = true;
      }
    }
    if (!added) { chars.add(char); }
    makeLog(char.name + " rolled initiative : " + initiative.toString());
  }
}