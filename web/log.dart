library sc_log;

import 'dart:html';

OListElement logList = querySelector('#log-list');

void makeLog(String logText) {
  LIElement logEntry = new LIElement();
  logEntry.innerHtml = logText;
  logList.append(logEntry);
}