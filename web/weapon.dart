part of sc_equipment;

class Weapon implements Equipment{
  String name;
  final num weight;
  int toHitModifier;
  DiceRoll damageRoll;
  
  Weapon(this.name, this.weight, this.toHitModifier, this.damageRoll) {}
  
  int get damage {
    return damageRoll.roll();
  }
  
  String toString() {
    return name + " +" + toHitModifier.toString() + "H " + damageRoll.toString() + "D ";
  }
}

Weapon unarmed = new Weapon("Unarmed Strike", 0, 0, new DiceRoll(0,0,0,0,0,0,0,1));
Weapon greatSword = new Weapon("Great Sword", 7, 0, new DiceRoll(0,0,0,0,0,2,0,0));