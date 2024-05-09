import 'package:flutter/material.dart';
import 'package:tp2_fakestore/products/detail.dart';
import 'package:tp2_fakestore/products/product_model.dart';

class StoreCatalogPage extends StatefulWidget {
  @override
  _StoreCatalogPageState createState() => _StoreCatalogPageState();
}

class _StoreCatalogPageState extends State<StoreCatalogPage> {
  List<DropdownMenuItem<String>> items = <String>['Category 1', 'Category 2']
      .map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      child: Text(value),
      value: value,
    );
  }).toList();
  final TextEditingController categoryController = TextEditingController();
  String? pilihanCategory;

  late List<Product> products;

  @override
  void initState() {
    super.initState();
    // Initialize products with sample data
    products = List.generate(
      10,
      (index) => Product(
        id: index,
        title: 'Product $index',
        price: (index + 1) * 10.0,
        category: 'Category',
        description: 'Description',
        image: 'https://via.placeholder.com/150', // Placeholder image URL
        rating: 5.0,
        ratingCount: 120,
      ),
    );

    // Set the default category
    pilihanCategory = items.first.value; // Set to the first category
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Catalog'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<String>(
            value: pilihanCategory,
            items: items,
            onChanged: (String? category) {
              setState(() {
                pilihanCategory = category;
              });
            },
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
          ),
        ],
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
