import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:view_with_provider/products/detail.dart';
import 'package:view_with_provider/products/product_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class StoreCatalogModel extends ChangeNotifier {
  List<Product> products;
  List<String> categories = [];
  String? selectedCategory;
  bool isLoading = false;

  StoreCatalogModel({required this.products}) {
    // Initialize the model asynchronously
    initialize();
  }

  // Asynchronous initialization method
  Future<void> initialize() async {
    // Fetch categories
    isLoading = true;
    await fetchCategories();
    if (categories.isNotEmpty) {
      selectedCategory = categories.first;
      await fetchData(selectedCategory);
    }
    isLoading = false;
    // Notify listeners after initialization
    notifyListeners();
  }

  void setFromJson(List<dynamic> json) {
    if (json != null) {
      products = <Product>[];
      json.forEach((productJson) {
        products.add(Product.fromJson(productJson));
      });
      notifyListeners();
    }
  }

  void setSelectedCategory(String? category) {
    selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchData(String? category) async {
    if (category == null) return; // Return if category is null
    isLoading = true;
    notifyListeners();
    String url =
        category == 'All' ? "https://fakestoreapi.com/products/" : "https://fakestoreapi.com/products/category/$category";
    final response = await http.get(Uri.parse(url));
    isLoading = false; // Set isLoading to false regardless of response
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch data");
    }
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse("https://fakestoreapi.com/products/categories"));
    if (response.statusCode == 200) {
      categories = List<String>.from(jsonDecode(response.body));
      // Add "All" option to categories
      categories.insert(0, "All");
    } else {
      throw Exception("Failed to fetch categories");
    }
  }
}

class StoreCatalogPage extends StatelessWidget {
  StoreCatalogPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Catalog'),
      ),
      body:
        Consumer<StoreCatalogModel>(
          builder: ((context, value, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: value.selectedCategory, // Make sure selectedCategory is a valid category value
                  items: value.isLoading
                    ? [const DropdownMenuItem(child: Text('Loading...'))] // Show loading indicator
                    : value.categories.map((String category) {
                      return DropdownMenuItem<String>(
                        child: Text(category),
                        value: category,
                      );
                    }).toList(),
                  onChanged: (String? category) {
                    value.setSelectedCategory(category);
                    value.fetchData(category); // Fetch data for the selected category
                  },
                ),

                // Show loading indicator if products list is empty or if data is being fetched
                if (value.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  // Show GridView if data is available
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: value.products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: value.products[index]);
                      },
                    ),
                  ),
              ],
            );
          }),
        ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductDetailPage(productId: product.id))),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                product.image, // Use product image URL
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
