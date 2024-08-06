import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductList extends StatefulWidget {
  static const String id = '/ProductList';

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final int _perPage = 10;
  List<DocumentSnapshot> _products = [];
  bool _loading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
      // Remove the deleted product from the list
      setState(() {
        _products.removeWhere((product) => product.id == productId);
      });
    } catch (error) {
      print('Error deleting product: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  Future<void> _loadProducts() async {
    if (!_loading && _hasMore) {
      setState(() {
        _loading = true;
      });

      QuerySnapshot querySnapshot;
      if (_lastDocument == null) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .orderBy('productName')
            .limit(_perPage)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .orderBy('productName')
            .startAfterDocument(_lastDocument!)
            .limit(_perPage)
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _products.addAll(querySnapshot.docs);
          _lastDocument = querySnapshot.docs.last;
          _loading = false;
        });
      } else {
        setState(() {
          _hasMore = false;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by product name',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _products.length) {
                  return _loading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _loadProducts,
                          child: Text('Load More'),
                        );
                } else {
                  return _searchQuery.isEmpty ||
                          _products[index]['productName']
                              .toLowerCase()
                              .contains(_searchQuery)
                      ? _buildProductContainer(_products[index])
                      : Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductContainer(DocumentSnapshot productSnapshot) {
    Map<String, dynamic> data = productSnapshot.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductUpdateScreen(productId: productSnapshot.id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 150.0,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  enableInfiniteScroll: false,
                ),
                items: _buildProductImages(data['productImages']),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['productName'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Category: ${data['category'] ?? ''}'),
                  Text('Price: \$${data['price'] ?? ''}'),
                  Text('Stock: ${data['quantity'] ?? ''}'),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteProduct(productSnapshot.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProductImages(List<dynamic>? images) {
    List<Widget> imageWidgets = [];

    if (images != null && images.isNotEmpty) {
      images.forEach((imageUrl) {
        imageWidgets.add(
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        );
      });
    }

    return imageWidgets;
  }
}

class ProductUpdateScreen extends StatefulWidget {
  final String productId;

  const ProductUpdateScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  _ProductUpdateScreenState createState() => _ProductUpdateScreenState();
}

class _ProductUpdateScreenState extends State<ProductUpdateScreen> {
  late TextEditingController _categoryController;
  late TextEditingController _salesCountController;
  late TextEditingController _quantityController;
  late TextEditingController _discountPriceController;
  late TextEditingController _priceController;
  List<String> _existingImages = []; // Store existing image URLs

  @override
  void initState() {
    super.initState();
    // Initialize text controllers
    _categoryController = TextEditingController();
    _salesCountController = TextEditingController();
    _quantityController = TextEditingController();
    _discountPriceController = TextEditingController();
    _priceController = TextEditingController();
    // Fetch current product details
    fetchProductDetails();
  }

  @override
  void dispose() {
    // Dispose text controllers
    _categoryController.dispose();
    _salesCountController.dispose();
    _quantityController.dispose();
    _discountPriceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> fetchProductDetails() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (productSnapshot.exists) {
        setState(() {
          // Update text controllers with current product details
          _categoryController.text = productSnapshot['category'] ?? '';
          _salesCountController.text =
              productSnapshot['salesCount']?.toString() ?? '';
          _quantityController.text =
              productSnapshot['quantity']?.toString() ?? '';
          _discountPriceController.text =
              productSnapshot['discountPrice']?.toString() ?? '';
          _priceController.text = productSnapshot['price']?.toString() ?? '';
          // Store existing images
          _existingImages =
              List<String>.from(productSnapshot['productImages'] ?? [])
                  .where((element) => element != null)
                  .cast<String>()
                  .toList();
        });
      }
    } catch (error) {
      print('Error fetching product details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Show existing images with delete icons
            if (_existingImages.isNotEmpty) ..._buildExistingImages(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _selectAndUploadImages,
              child: Text('Add New Images'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextFormField(
              controller: _salesCountController,
              decoration: InputDecoration(labelText: 'Sales Count'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _discountPriceController,
              decoration: InputDecoration(labelText: 'Discount Price'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: updateProductDetails,
              child: Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build existing images with delete icons
  List<Widget> _buildExistingImages() {
    return _existingImages.map((imageUrl) {
      return Row(
        children: [
          Image.network(imageUrl, height: 100),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _existingImages.remove(imageUrl);
              });
            },
          ),
        ],
      );
    }).toList();
  }

  // Function to select and upload new images
  Future<void> _selectAndUploadImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result != null) {
        for (PlatformFile file in result.files) {
          final bytes = file.bytes;
          if (bytes != null) {
            await _uploadImageToFirebaseStorage(bytes);
          } else {
            print('Error: Image bytes are null.');
          }
        }
      } else {
        print('Error: No image selected.');
      }
    } catch (e) {
      print('Error selecting/uploading images: $e');
    }
  }

  // Function to upload image to Firebase Storage
  Future<void> _uploadImageToFirebaseStorage(Uint8List imageBytes) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('product_images/$fileName');
      final UploadTask uploadTask = storageReference.putData(imageBytes);
      final TaskSnapshot downloadTask = await uploadTask;
      final String imageUrl = await downloadTask.ref.getDownloadURL();
      setState(() {
        _existingImages.add(imageUrl);
      });
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }

  // Function to update product details
  Future<void> updateProductDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'category': _categoryController.text,
        'salesCount': int.tryParse(_salesCountController.text) ?? 0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'discountPrice': double.tryParse(_discountPriceController.text) ?? 0.0,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'productImages': _existingImages,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product details updated successfully')));
    } catch (error) {
      print('Error updating product details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product details')));
    }
  }
}
