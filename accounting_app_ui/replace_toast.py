import os

def replace_in_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    
    # Add import if not present
    if "import '../widgets/custom_toast.dart';" not in content and "import 'package:flutter/material.dart';" in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../widgets/custom_toast.dart';")

    replacements = {
        # leads_screen
        """          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aşama güncellendi'), backgroundColor: Colors.green),
          );""": "          CustomToast.showSuccess(context, 'Aşama güncellendi');",
        """          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );""": "          CustomToast.showError(context, e.toString());",
        """                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kayıt silindi'), backgroundColor: Colors.green),
                    );""": "                    CustomToast.showSuccess(context, 'Kayıt silindi');",
        """                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                    );""": "                    CustomToast.showError(context, e.toString());",
        """                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isEdit ? 'Kayıt güncellendi' : 'Kayıt oluşturuldu'), backgroundColor: Colors.green),
                        );""": "                        CustomToast.showSuccess(context, isEdit ? 'Kayıt güncellendi' : 'Kayıt oluşturuldu');",
        """                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                        );""": "                        CustomToast.showError(context, e.toString());",
                        
        # employee_list_screen
        """        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );""": "        CustomToast.showError(context, 'Hata: $e');",
        """    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hata: $msg', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red[700]),
    );""": "    CustomToast.showError(context, 'Hata: $msg');",
        "                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));": "                                          CustomToast.showError(context, e.toString());",
        "                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));": "                                            CustomToast.showError(context, e.toString());",
        """                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Hata: $e')),
                        );""": "                        CustomToast.showError(context, 'Hata: $e');",
                        
        # currencies_screen
        "    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));": "    CustomToast.showError(context, msg);",
        
        # contact_screen
        """                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen yetkili kişinin adını girin')),
                      );""": "                      CustomToast.showError(context, 'Lütfen yetkili kişinin adını girin');",
                      
        # business_contacts_screen
        """                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kayıt silindi'), backgroundColor: Colors.green),
                    );""": "                    CustomToast.showSuccess(context, 'Kayıt silindi');",
        """                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                    );""": "                    CustomToast.showError(context, e.toString());",
                    
        # barcode_stock_entry_screen
        """      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red[700]),
      );""": "      CustomToast.showError(context, e.toString().replaceAll('Exception: ', ''));",
        """        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen geçerli bir miktar girin'), backgroundColor: Colors.red),
        );""": "        CustomToast.showError(context, 'Lütfen geçerli bir miktar girin');",
        """        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok başarıyla güncellendi'), backgroundColor: Colors.green),
        );""": "        CustomToast.showSuccess(context, 'Stok başarıyla güncellendi');"
    }

    for k, v in replacements.items():
        if k in content:
            content = content.replace(k, v)

    if content != original:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {path}")

files_to_update = [
    'lib/screens/leads_screen.dart',
    'lib/screens/employee_list_screen.dart',
    'lib/screens/currencies_screen.dart',
    'lib/screens/contact_screen.dart',
    'lib/screens/business_contacts_screen.dart',
    'lib/screens/barcode_stock_entry_screen.dart'
]

for file in files_to_update:
    if os.path.exists(file):
        replace_in_file(file)
