import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:view_with_bloc/products/detail.dart';
import 'package:view_with_bloc/products/product_model.dart';
import 'package:view_with_bloc/products/detail.dart';
import 'package:http/http.dart' as http;
//event parent
abstract class DataEvent {}

//class untuk event mulai pengambilan data
class FetchDataEvent extends DataEvent {
  final String? category;
  FetchDataEvent(this.category);
}

//class untuk event jika data sudah selesai diambil
class DataSiapEvent extends DataEvent {
  late StoreCatalogModel activity;
  DataSiapEvent(StoreCatalogModel act) : activity = act;
} 

class StoreCatalogModel {
  List<Product> products;
  List<String> categories = [];
  String? selectedCategory;
  bool isLoading = false;
  StoreCatalogModel({
    required this.products,
    required this.categories,
    this.selectedCategory,
    required this.isLoading
  }) {}
}

class StoreCatalogBloc extends Bloc<DataEvent, StoreCatalogModel> {
  StoreCatalogBloc()
      : super(StoreCatalogModel(products: [], categories: [], isLoading: true)) {
    initialize();

    on<FetchDataEvent>((event, emit) {
      fetchData(event.category);
      setSelectedCategory(event.category);
    });

    on<DataSiapEvent>((event, emit) {
      emit(event.activity);
    });
  }

  Future<void> initialize() async {
    await fetchCategories();
    if (state.categories.isNotEmpty) {
      fetchData(state.categories[0]);
    }
  }

  void setFromJson(List<dynamic> json) {
    if (json != null) {
      List<Product> products = <Product>[];
      json.forEach((productJson) {
        products.add(Product.fromJson(productJson));
      });
      add(DataSiapEvent(StoreCatalogModel(
        products: products,
        categories: state.categories,
        selectedCategory: state.selectedCategory,
        isLoading: false, // Data fetching completed, set isLoading to false
      )));
    }
  }

  void setSelectedCategory(String? category) {
    add(DataSiapEvent(StoreCatalogModel(
      products: state.products,
      categories: state.categories,
      selectedCategory: category,
      isLoading: true, // Set isLoading to true while fetching data
    )));
  }

  Future<void> fetchData(String? category) async {
    if (category == null) return; // Return if category is null
    String url = category == 'All'
        ? "https://fakestoreapi.com/products/"
        : "https://fakestoreapi.com/products/category/$category";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  Future<void> fetchCategories() async {
    final response =
        await http.get(Uri.parse("https://fakestoreapi.com/products/categories"));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> categories = List<String>.from(data);
      categories.insert(0, "All");
      fetchData(categories[0]);
      add(DataSiapEvent(StoreCatalogModel(
        products: state.products,
        categories: categories,
        selectedCategory: categories[0],
        isLoading: true, // Set isLoading to true while fetching data
      )));
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
        BlocBuilder<StoreCatalogBloc, StoreCatalogModel>(
          builder: (context, value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: value.selectedCategory, // Make sure selectedCategory is a valid category value
                  items: value.categories.map((String category) {
                      return DropdownMenuItem<String>(
                        child: Text(category),
                        value: category,
                      );
                    }).toList(),
                  onChanged: (String? category) {
                    context.read<StoreCatalogBloc>().add(FetchDataEvent(category));
                  },
                ),

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
          }
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
