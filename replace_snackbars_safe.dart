// ignore_for_file: unused_local_variable
import 'dart:io';

void main() async {
  final dir = Directory('c:\\Users\\Enes\\.gemini\\antigravity\\scratch\\AccountingApp\\accounting_app_ui\\lib\\screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  // A safer regex that doesn't eat brackets
  final scaffoldRegex = RegExp(
    r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(([^)]+)\)\s*(?:,\s*backgroundColor:\s*([^,)]+))?[^)]*\)\s*,\s*\);"
  );

  for (final file in files) {
    if (file.path.endsWith('user_management_screen.dart') || file.path.endsWith('settings_screen.dart')) {
      continue; // Skip these since they are already updated
    }
    String content = await file.readAsString();
    if (content.contains('ScaffoldMessenger.of(')) {
      bool changed = false;
      
      // Let's just do targeted string replacements for the specific known lines instead of complex regex
      // From the previous output, here are the common ones:
      
      final replaces = {
        "ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));": "CustomToast.showError(context, e.toString());",
        "ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.replaceAll('Exception: ', '')), backgroundColor: Colors.red));": "CustomToast.showError(context, msg.replaceAll('Exception: ', ''));",
        "ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tebrikler! Müşteri adayı başarıyla müşteriye (iş ortağına) dönüştürüldü.')));": "CustomToast.showSuccess(context, 'Tebrikler! Müşteri adayı başarıyla müşteriye (iş ortağına) dönüştürüldü.');",
        "if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));": "if (mounted) CustomToast.showError(context, e.toString());",
        "ScaffoldMessenger.of(ctx2).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));": "CustomToast.showError(ctx2, e.toString());",
      };

      for (var entry in replaces.entries) {
        if (content.contains(entry.key)) {
          content = content.replaceAll(entry.key, entry.value);
          changed = true;
        }
      }

      // If there are still scaffold messengers, try a slightly looser replace
      content = content.replaceAll(
        "ScaffoldMessenger.of(context).showSnackBar(\n        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),\n      );",
        "CustomToast.showError(context, e.toString());"
      );
      content = content.replaceAll(
        "ScaffoldMessenger.of(context).showSnackBar(\n          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),\n        );",
        "CustomToast.showError(context, e.toString());"
      );
      content = content.replaceAll(
        "ScaffoldMessenger.of(context).showSnackBar(\n            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),\n          );",
        "CustomToast.showError(context, e.toString());"
      );
      content = content.replaceAll(
        "ScaffoldMessenger.of(context).showSnackBar(\n              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),\n            );",
        "CustomToast.showError(context, e.toString());"
      );

      if (content != await file.readAsString()) {
        changed = true;
      }

      if (changed) {
        if (!content.contains('custom_toast.dart')) {
          content = "import '../widgets/custom_toast.dart';\n" + content;
        }
        await file.writeAsString(content);
        print('Updated: ${file.path}');
      }
    }
  }
}
