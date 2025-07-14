import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class TariffScreen extends StatelessWidget {
  const TariffScreen({super.key});

  Future<String> _loadHtmlFromAssets() async {
    return await rootBundle.loadString('assets/tariff_table_with_percentages.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tariff Details'),
      ),
      body: FutureBuilder<String>(
        future: _loadHtmlFromAssets(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: HtmlWidget(snapshot.data!),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading tariff details: ${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
