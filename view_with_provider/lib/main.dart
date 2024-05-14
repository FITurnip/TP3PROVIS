import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:view_with_provider/products/index.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<StoreCatalogModel>(
        create: (context) => StoreCatalogModel(products: []),
        child: StoreCatalogPage(),
      ),  
    );;
  }
}
