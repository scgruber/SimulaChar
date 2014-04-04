library sc_globals;

import 'dart:html';
import 'dart:svg';

import 'character.dart' show Character;
import 'initiative.dart' show Initiative;

SvgElement gMap;
DivElement gControlPanel;
List<Character> gChars = new List<Character>();
Initiative gInitiative;