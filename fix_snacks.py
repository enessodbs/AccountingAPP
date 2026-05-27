import os
import re

def main():
    lib_dir = r"c:\Users\Enes\.gemini\antigravity\scratch\AccountingApp\accounting_app_ui\lib\screens"
    
    # We will do a regex replacement. 
    # Match: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('MSG'), backgroundColor: Colors.green));
    # Match multi-line with re.DOTALL
    
    for root, dirs, files in os.walk(lib_dir):
        for filename in files:
            if not filename.endswith('.dart'):
                continue
            
            filepath = os.path.join(root, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # Simple replacements for generic SnackBar
            # Find: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red[700]));
            
            # Let's just use re.sub for a few common patterns:
            
            # Pattern 1: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('...'), backgroundColor: Colors.green));
            content = re.sub(
                r"ScaffoldMessenger\.of\((.*?)\)\.showSnackBar\(\s*const\s*SnackBar\(\s*content:\s*Text\('([^']+)'\)\s*,\s*backgroundColor:\s*Colors\.green\s*\)\s*\);",
                r"CustomToast.showSuccess(\1, '\2');",
                content, flags=re.DOTALL
            )
            
            # Pattern 2: ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('...')));
            content = re.sub(
                r"ScaffoldMessenger\.of\((.*?)\)\.showSnackBar\(\s*const\s*SnackBar\(\s*content:\s*Text\('([^']+)'\)\s*\)\s*\);",
                r"CustomToast.showSuccess(\1, '\2');",
                content, flags=re.DOTALL
            )
            
            # Pattern 3: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            content = re.sub(
                r"ScaffoldMessenger\.of\((.*?)\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(([^)]+)\)\s*\)\s*\);",
                r"CustomToast.showError(\1, \2);",
                content, flags=re.DOTALL
            )
            
            if "import '../widgets/custom_toast.dart';" not in content and content != original_content:
                content = "import '../widgets/custom_toast.dart';\n" + content
                
            if content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated {filename}")

if __name__ == '__main__':
    main()
