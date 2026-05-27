import 'dart:io';

void main() async {
  final dir = Directory('c:\\Users\\Enes\\.gemini\\antigravity\\scratch\\AccountingApp\\accounting_app_ui\\lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final scaffoldRegex = RegExp(r"ScaffoldMessenger\.of\([^)]+\)\.showSnackBar\s*\(\s*SnackBar\s*\(\s*content\s*:\s*Text\s*\(([^)]+)\)\s*(?:,\s*backgroundColor\s*:\s*([^)]+)\s*)?\)\s*\);");

  for (final file in files) {
    String content = await file.readAsString();
    if (content.contains('ScaffoldMessenger.of(')) {
      bool changed = false;
      content = content.replaceAllMapped(scaffoldRegex, (match) {
        changed = true;
        final textArg = match.group(1);
        final colorArg = match.group(2);
        bool isError = colorArg != null && colorArg.contains('red');
        if (isError) {
          return 'CustomToast.showError(context, $textArg);';
        } else {
          return 'CustomToast.showSuccess(context, $textArg);';
        }
      });
      
      // Also catch multiline ones if possible, but the regex above might not catch multiline well due to \s* matching newlines.
      // Let's use a simpler regex for multi-line:
      final fallbackRegex = RegExp(r"ScaffoldMessenger\.of\((.*?)\)\.showSnackBar\([\s\S]*?SnackBar\([\s\S]*?content:\s*Text\((.*?)\)[\s\S]*?(?:backgroundColor:\s*(.*?),)?[\s\S]*?\)\s*\)?\s*;");
      
      content = content.replaceAllMapped(fallbackRegex, (match) {
        changed = true;
        final ctx = match.group(1)!.trim();
        final textArg = match.group(2)!.trim();
        final colorArg = match.group(3)?.trim();
        bool isError = colorArg != null && colorArg.contains('red');
        return isError ? 'CustomToast.showError($ctx, $textArg);' : 'CustomToast.showSuccess($ctx, $textArg);';
      });

      if (changed) {
        // add import if missing
        if (!content.contains('custom_toast.dart')) {
          content = "import '../widgets/custom_toast.dart';\n" + content;
        }
        await file.writeAsString(content);
        print('Updated: ${file.path}');
      }
    }
  }
}
