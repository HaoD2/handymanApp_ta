import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(insertLayananTablet());
}

class FormProvider extends ChangeNotifier {
  String nama = '';
  String pekerjaan = '';
  double harga = 0.0;
  bool enableField1 = false;
  bool enableField2 = false;

  void toggleField1(bool value) {
    enableField1 = value;
    if (!value) {
      // Bersihkan nilai field jika disable
    }
    notifyListeners();
  }

  void toggleField2(bool value) {
    enableField2 = value;
    if (!value) {
      // Bersihkan nilai field jika disable
    }
    notifyListeners();
  }
}

class insertLayananTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: FormPage(),
      ),
    );
  }
}

final formProviders = ChangeNotifierProvider<FormProvider>((ref) {
  return FormProvider();
});

class FormPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formProvider = ref.watch(formProviders);

    return Scaffold(
      appBar: AppBar(
        title: Text('Form Flutter dengan Riverpod'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Nama'),
              onChanged: (value) {
                formProvider.nama = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Pekerjaan'),
              onChanged: (value) {
                formProvider.pekerjaan = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                formProvider.harga = double.tryParse(value) ?? 0.0;
              },
            ),
            CheckboxListTile(
              title: Text('Field 1'),
              value: formProvider.enableField1,
              onChanged: (value) {
                formProvider.toggleField1(value ?? false);
              },
            ),
            if (formProvider.enableField1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Field 1 Content'),
                  // Widget lainnya untuk field 1
                ],
              ),
            CheckboxListTile(
              title: Text('Field 2'),
              value: formProvider.enableField2,
              onChanged: (value) {
                formProvider.toggleField2(value ?? false);
              },
            ),
            if (formProvider.enableField2)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Field 2 Content'),
                  // Widget lainnya untuk field 2
                ],
              ),
          ],
        ),
      ),
    );
  }
}
