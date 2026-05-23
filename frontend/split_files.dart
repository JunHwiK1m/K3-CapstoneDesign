import 'dart:io';

void main() async {
  final file = File('lib/main.dart');
  final lines = await file.readAsLines();

  // Helper to extract lines
  List<String> getLines(int startLine, int endLine) {
    // startLine is 1-indexed
    return lines.sublist(startLine - 1, endLine >= lines.length ? lines.length : endLine);
  }

  // Find actual line numbers
  int findClass(String className) => lines.indexWhere((l) => l.startsWith('class $className')) + 1;

  final loginStart = findClass('LoginScreen');
  final setupStart = findClass('SetupScreen');
  final homeStart = findClass('DiaryHomePage');
  final cardStart = findClass('DiaryEntryCard');
  final writeStart = findClass('LinedPaperPainter');
  final loadStart = findClass('AnalysisLoadingScreen');
  final storeStart = findClass('StoreScreen');

  Directory('lib/screens').createSync(recursive: true);
  Directory('lib/widgets').createSync(recursive: true);

  void write(String path, List<String> content, List<String> imports) {
    final f = File(path);
    String header = imports.map((e) => "import '$e';").join('\n');
    f.writeAsStringSync(header + '\n\n' + content.join('\n') + '\n');
  }

  write('lib/screens/login_screen.dart', getLines(loginStart, setupStart - 1), ['package:flutter/material.dart', 'setup_screen.dart']);
  write('lib/screens/setup_screen.dart', getLines(setupStart, homeStart - 1), ['package:flutter/material.dart', 'diary_home_page.dart']);
  write('lib/screens/diary_home_page.dart', getLines(homeStart, cardStart > 0 ? cardStart - 1 : writeStart - 1), [
    'package:flutter/material.dart', 
    'package:fl_chart/fl_chart.dart',
    'diary_write_screen.dart',
    'store_screen.dart',
    'records_screen.dart'
  ]);
  
  if (cardStart > 0) {
    write('lib/widgets/diary_entry_card.dart', getLines(cardStart, writeStart - 1), ['package:flutter/material.dart']);
  }
  
  write('lib/screens/diary_write_screen.dart', getLines(writeStart, loadStart - 1), ['package:flutter/material.dart', 'analysis_loading_screen.dart']);
  write('lib/screens/analysis_loading_screen.dart', getLines(loadStart, storeStart - 1), ['package:flutter/material.dart']);
  write('lib/screens/store_screen.dart', getLines(storeStart, lines.length), ['package:flutter/material.dart']);

  // Write new main.dart
  final mainContent = getLines(1, loginStart - 1);
  mainContent.removeWhere((l) => l.startsWith('import '));
  final mainImports = [
    'package:flutter/material.dart',
    'screens/login_screen.dart',
  ];
  write('lib/main.dart', mainContent, mainImports);
}
