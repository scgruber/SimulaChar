library sc_character;

import 'dart:math' as MATH;
import 'dart:html' as HTML;
import 'dart:svg' as SVG;

import 'globals.dart';
import 'equipment.dart';
import 'dice.dart';
import 'log.dart' show makeLog;

class Character {
  // Properties
  String name;
  Token token;
  Stats stats;
  Gear gear;
  CharControl ctrl;
  int uid;
  
  // Constructor
  Character(this.name, String inColor) {
    // Generate UID
    MATH.Random rand = new MATH.Random((new DateTime.now()).millisecondsSinceEpoch);
    uid = rand.nextInt((1<<32)-1);
    
    // Make the stats
    stats = new Stats();
    
    // Gear
    gear = new Gear();
    gear.add(greatSword);
    gear.setWeapon(greatSword);
    gear.add(new Money(rand.nextInt(10),rand.nextInt(10),rand.nextInt(10),rand.nextInt(10),rand.nextInt(10)));
    
    // Make the token
    token = new Token(this.name, inColor);
    
    // Make the control panel
    // This MUST BE LAST
    ctrl = new CharControl(this);
    
    // Add to global list
    gChars.add(this);
  }
  
  String get uidString { return uid.toRadixString(36); }
  
  // Try to make an attack against the target
  // Returns the amount of damage dealt, or 0 if the attack misses
  int tryAttack(Character target) {
    // Get the weapon
    Weapon theWeapon = null;
    if (gear.activeWeapon != null) {
      theWeapon = gear.activeWeapon;
    } else {
      theWeapon = unarmed;
    }
    
    // Make the attack roll
    int attackRoll = dTwenty.roll() + theWeapon.toHitModifier + stats.strMod;
    if (attackRoll > target.stats.armorClass) {
      return theWeapon.damage + stats.strMod;
    } else {
      return 0;
    }
  }
  
  void takeDamage(int damage) {
    stats.damageTaken += damage;
    ctrl.updateHitPoints();
    if (stats.curHitPoints < 0) {
      makeLog(name + " defeated.");
    }
  }
  
  int get initiative {
    return dTwenty.roll() + stats.dexMod;
  }
}

class Token {
  SVG.GElement token;
  MATH.Point pos;
  
  Token(String inName, String inColor) {
    token = new SVG.GElement();
    
    MATH.Random rand = new MATH.Random((new DateTime.now()).millisecondsSinceEpoch);
    pos = new MATH.Point(rand.nextInt(400)+100,rand.nextInt(400)+100);
    
    SVG.CircleElement circ = new SVG.CircleElement();
    circ.setAttribute("r", "10px");
    circ.setAttribute("cx", pos.x.toString() + "px");
    circ.setAttribute("cy", pos.y.toString() + "px");
    circ.setAttribute("fill", inColor);
    token.append(circ);
    
    SVG.TextElement text = new SVG.TextElement();
    text.innerHtml = inName;
    text.setAttribute("x", (pos.x + 10).toString() + "px");
    text.setAttribute("y", (pos.y - 10).toString() + "px");
    text.setAttribute("text-anchor", "bottom-left");
    token.append(text);
    
    gMap.append(token);
  }
}

class Stats {
  // Ability Scores
  List<int> abilityScores;
  int get strScore { return abilityScores[0]; }
  int get strMod { return ((abilityScores[0] - 10) / 2).floor(); }
  int get dexScore { return abilityScores[1]; }
  int get dexMod { return ((abilityScores[1] - 10) / 2).floor(); }
  int get intScore { return abilityScores[2]; }
  int get intMod { return ((abilityScores[2] - 10) / 2).floor(); }
  int get wisScore { return abilityScores[3]; }
  int get wisMod { return ((abilityScores[3] - 10) / 2).floor(); }
  int get conScore { return abilityScores[4]; }
  int get conMod { return ((abilityScores[4] - 10) / 2).floor(); }
  int get chaScore { return abilityScores[5]; }
  int get chaMod { return ((abilityScores[5] - 10) / 2).floor(); }
  
  // Hit points
  int maxHitPoints;
  int damageTaken;
  int get curHitPoints { return maxHitPoints - damageTaken; }
  
  // Armor Class
  int get armorClass { return 10 + dexMod; }
  
  // Constructor
  Stats() {
    abilityScores = new List(6);
    // Roll 4d6 and drop lowest for each stat
    MATH.Random diceRoller = new MATH.Random((new DateTime.now()).millisecondsSinceEpoch);
    for (int iScore = 0; iScore < 6; iScore++) {
      int one = diceRoller.nextInt(6) + 1;
      int least = one;
      int two = diceRoller.nextInt(6) + 1;
      least = MATH.min(least,two);
      int three = diceRoller.nextInt(6) + 1;
      least = MATH.min(least,three);
      int four = diceRoller.nextInt(6) + 1;
      least = MATH.min(least,four);
      abilityScores[iScore] = one+two+three+four-least;
    }
    
    maxHitPoints = 10 + conMod;
    damageTaken = 0;
  }
}

class Gear {
  List<Equipment> possessions;
  Weapon activeWeapon;
  
  Gear() {
    possessions = new List<Equipment>();
  }
  
  num get weight {
    num total = 0;
    for (Equipment obj in possessions) {
      total += obj.weight;
    }
    return total;
  }
  
  void add(Equipment equip) {
    possessions.add(equip);
  }
  
  void setWeapon(Equipment equip) {
    if (possessions.contains(equip)) {
      activeWeapon = equip;
    } else {
      throw new StateError("The specified weapon is not already held.");
    }
  }
  
  void clearWeapon() {
    activeWeapon = null;
  }
}

class CharControl {
  Character char;
  HTML.DivElement charControlPanel;
  
  CharControl(this.char){
    charControlPanel = new HTML.DivElement();
    charControlPanel.id = "cp-" + char.uidString;
    
    HTML.HeadingElement name = new HTML.HeadingElement.h3();
    name.id = "cp-" + char.uidString + "-name";
    charControlPanel.append(name);
    updateName();
    
    List<String> abilityScoreNames = ["Str", "Dex", "Int", "Wis", "Con", "Cha"];
    HTML.TableElement abilityScores = new HTML.TableElement();
    abilityScores.id = "cp-" + char.uidString + "-abilityScores";
    abilityScores.addRow();
    abilityScores.addRow();
    for (int iScore = 0; iScore < 6; iScore++) {
      abilityScores.rows[0].addCell();
      abilityScores.rows[0].cells[iScore].innerHtml = abilityScoreNames[iScore];
      abilityScores.rows[1].addCell();
    }
    charControlPanel.append(abilityScores);
    updateAbilityScores();
    
    HTML.DivElement hitPoints = new HTML.DivElement();
    hitPoints.id = "cp-" + char.uidString + "-hitPoints";
    charControlPanel.append(hitPoints);
    updateHitPoints();
    
    HTML.DivElement armorClass = new HTML.DivElement();
    armorClass.id = "cp-" + char.uidString + "-armorClass";
    charControlPanel.append(armorClass);
    updateArmorClass();
    
    HTML.DivElement gear = new HTML.DivElement();
    gear.id = "cp-" + char.uidString + "-gear";
    gear.append(new HTML.HeadingElement.h4());
    gear.children[0].innerHtml = "Gear";
    gear.append(new HTML.UListElement());
    charControlPanel.append(gear);
    updateGear();
    
    gControlPanel.append(charControlPanel);
  }
  
  void updateName() {
    HTML.HeadingElement nameHeader = charControlPanel.querySelector("#cp-" + char.uidString + "-name");
    nameHeader.innerHtml = char.name;
  }
  
  void updateAbilityScores() {
    HTML.TableElement abilityScoresTable = charControlPanel.querySelector("#cp-" + char.uidString + "-abilityScores");
    for (int iScore = 0; iScore < 6; iScore++) {
      abilityScoresTable.rows[1].cells[iScore].innerHtml = char.stats.abilityScores[iScore].toString();
    }
  }
  
  void updateHitPoints() {
    HTML.DivElement hitPointsDiv = charControlPanel.querySelector("#cp-" + char.uidString + "-hitPoints");
    hitPointsDiv.innerHtml = "Hit Points: " + char.stats.curHitPoints.toString() + "/" + char.stats.maxHitPoints.toString();
  }
  
  void updateArmorClass() {
    HTML.DivElement armorClassDiv = charControlPanel.querySelector("#cp-" + char.uidString + "-armorClass");
    armorClassDiv.innerHtml = "Armor Class: " + char.stats.armorClass.toString();
  }
  
  void updateGear() {
    HTML.DivElement gearList = charControlPanel.querySelector("#cp-" + char.uidString + "-gear");
    gearList.children[1].children = [];
    for (Equipment equip in char.gear.possessions) {
      HTML.LIElement item = new HTML.LIElement();
      if (equip == char.gear.activeWeapon) {
        item.classes.add("activeWeapon");
      }
      item.innerHtml = equip.toString();
      gearList.children[1].append(item);
    }
  }
}