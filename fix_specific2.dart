import 'dart:io';

void main() async {
  final filesToFix = [
    'c:\\Users\\Enes\\.gemini\\antigravity\\scratch\\AccountingApp\\accounting_app_ui\\lib\\screens\\user_management_screen.dart',
    'c:\\Users\\Enes\\.gemini\\antigravity\\scratch\\AccountingApp\\accounting_app_ui\\lib\\screens\\settings_screen.dart',
  ];

  for (final filePath in filesToFix) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    String content = await file.readAsString();
    bool changed = false;

    // Fix 1: e.toString(); -> e.toString());
    if (content.contains('e.toString();')) {
      content = content.replaceAll('e.toString();', 'e.toString());');
      changed = true;
    }
    // Fix 2: l.get(...); -> l.get(...));
    content = content.replaceAllMapped(RegExp(r"l\.get\('([^']+)'\);"), (match) {
      changed = true;
      return "l.get('${match.group(1)}'));";
    });
    // Fix 3: '\${l.get('error'); -> l.get('error'));
    if (content.contains("'\${l.get('error');")) {
      content = content.replaceAll(
        "CustomToast.showSuccess(context, '\${l.get('error');",
        "CustomToast.showError(context, l.get('error')); //"
      );
      changed = true;
    }

    if (changed) {
      await file.writeAsString(content);
      print('Fixed: ${file.path}');
    }
  }
}
