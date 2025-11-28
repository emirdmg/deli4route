import 'package:deli4route/Pages/HomePage/route_cards_model.dart';
import 'package:deli4route/Services/directory_file.dart';
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
                  title: 'Import from CSV file',
                  subTitle: 'Upload delivery addresses from CSV',
                  onTap: () {
                    pickFile();
                  },
                ),

                MyRouteCard(
                  title: 'Import from Text',
                  subTitle: 'Paste addresses as plain text',
                  onTap: () {},
                ),

                MyRouteCard(
                  title: 'Import from Picture',
                  subTitle: 'Scan addresses from an image (OCR)',
                  onTap: () {},
                ),

                MyRouteCard(
                  title: 'Import from Sheet\n(Excel, Google Sheets)',
                  subTitle: 'Import from Excel or Sheets',
                  onTap: () {},
                ),
                MyRouteCard(
                  title: 'Title 5',
                  subTitle: 'Subtitle 5',
                  onTap: () {},
                ),
                MyRouteCard(
                  title: 'Title 6',
                  subTitle: 'Subtitle 6',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
