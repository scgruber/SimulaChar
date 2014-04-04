library sc_dice;

import 'dart:math' as MATH;

class DiceRoll {
  static const List<int> dice = const [100, 20, 12, 10, 8, 6, 4];
  List<int> diceCts;
  int modifier;
  static MATH.Random rand;
  
  DiceRoll(int d100, int d20, int d12, int d10, int d8, int d6, int d4, int mod) {
    diceCts = [d100, d20, d12, d10, d8, d6, d4];
    modifier = mod;
    if (rand == null) {
      rand = new MATH.Random((new DateTime.now()).millisecondsSinceEpoch);
    }
  }
  
  int roll() {
    int result = modifier;
    
    for (int iDie = 0; iDie < 7; iDie++) {
      // Note: this ignores negative dice numbers, so don't do that
      for (int iRoll = 0; iRoll < diceCts[iDie]; iRoll++) {
        result += rand.nextInt(dice[iDie]) + 1;
      }
    }
    
    return result;
  }
  
  String toString() {
    String result = "";
    
    for (int iDie = 0; iDie < 7; iDie++) {
      if (diceCts[iDie] > 0) {
        result += diceCts[iDie].toString() + "d" + dice[iDie].toString() + "+";
      }
    }
    
    if (modifier != 0) {
      result += modifier.toString();
    } else {
      result = result.substring(0, result.length - 1);
    }
    
    return result;
  }
}

DiceRoll dPercent = new DiceRoll(1,0,0,0,0,0,0,0);
DiceRoll dTwenty = new DiceRoll(0,1,0,0,0,0,0,0);