import 'package:deli4route/features/routes/models/route_cards_model.dart';
import 'package:deli4route/core/services/directory_file.dart';
import 'package:flutter/material.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              childAspectRatio: 2.5,
              crossAxisCount: 1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              padding: EdgeInsets.all(16),
              children: [
                MyRouteCard(
                  title: 'Import from Excel or CSV file',
                  subTitle: 'Upload delivery addresses from CSV',
                  onTap: () {
                    showMyDialog(context);
                  },
                ),

                MyRouteCard(
                  title: 'Coming Soon...',
                  subTitle: '',
                  onTap: () {},
                ),

                // MyRouteCard(
                //   title: 'Import from Text',
                //   subTitle: 'Paste addresses as plain text',
                //   onTap: () {},
                // ),
                // MyRouteCard(
                //   title: 'Import from Sheet\n(Excel, Google Sheets)',
                //   subTitle: 'Import from Excel or Sheets',
                //   onTap: () {},
                // ),
                // MyRouteCard(
                //   title: 'Title 5',
                //   subTitle: 'Subtitle 5',
                //   onTap: () {},
                // ),
                // MyRouteCard(
                //   title: 'Title 6',
                //   subTitle: 'Subtitle 6',
                //   onTap: () {},
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showMyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Choose one"),
        content: const Text("Devam etmek istiyor musun?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              pickExcelFile();
            },
            child: const Text("Upload my file"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              downloadExcelTemplate();
            },
            child: const Text("Download the template"),
          ),
        ],
      );
    },
  );
}
