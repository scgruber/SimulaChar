library sc_equipment;

import 'dice.dart';

part 'weapon.dart';

abstract class Equipment {
  String name;
  final num weight = 0;
  
  String toString();
}

// Money

class Money implements Equipment {
  String name = "Money";
  static const List<String> units = const ["PP", "GP", "EP", "SP", "CP"]; 
  List<int> amounts = new List(5);
  int get platinum { return amounts[0]; }
  void set platinum(int amt) { amounts[0] = amt; }
  int get gold { return amounts[1]; }
  void set gold(int amt) { amounts[1] = amt; }
  int get electrum { return amounts[2]; }
  void set electrum(int amt) { amounts[2] = amt; }
  int get silver { return amounts[3]; }
  void set silver(int amt) { amounts[3] = amt; }
  int get copper { return amounts[4]; }
  void set copper(int amt) { amounts[4] = amt; }
  
  Money(int pp, int gp, int ep, int sp, int cp) {
    platinum = pp;
    gold = gp;
    electrum = ep;
    silver = sp;
    copper = cp;
  } 
  
  num get weight { return (platinum+gold+electrum+silver+copper)*0.01; }
  
  num get gpValue { return (platinum*10) + (gold) + (electrum/2) + (silver/10) + (copper/100); }
  
  String toString() {
    String result = name + ": ";
    
    for (int iDenom = 0; iDenom < 5; iDenom++) {
      if (amounts[iDenom] > 0) {
        result += amounts[iDenom].toString() + " " + units[iDenom] + ", ";
      }
    }
    
    return result.substring(0, result.length-2);
  }
}