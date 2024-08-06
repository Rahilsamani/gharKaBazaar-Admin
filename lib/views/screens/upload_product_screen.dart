import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

class ProductUploadPage extends StatefulWidget {
  static const String id = '/productScreen';

  @override
  _ProductUploadPageState createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<double> taxPercentages = [0, 5, 9, 12, 18, 28];
  double selectedTaxPercentage = 0;

  final List<String> imagesUrl = [];
  List<Uint8List> images = [];
  final TextEditingController _sizeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _categoryList = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String productName;
  late int price;
  late int discountPrice;
  int? weight;
  late String description;
  String? selectedCategoryValue;
  String? selectedUnit;
  List<String> sizeList = [];
  String? fileName;
  int quantity = 0;
  FilePickerResult? result;

  // upload image
  Future<void> uploadImage() async {
    for (var selectedImage in images) {
      Reference ref =
          _storage.ref().child('productImages').child(const Uuid().v4());

      await ref.putData(selectedImage).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          setState(() {
            imagesUrl.add(value);
          });
        });
      });
    }
  }

  bool isUploading = false;

  // upload data to cloud
  Future<void> uploadData() async {
    setState(() {
      isUploading = true;
    });

    // Check if there are processed images in the imagesUrl list
    if (imagesUrl.isNotEmpty) {
      final productId = const Uuid().v4();

      if (weight != null && selectedUnit != null) {
        String unitWeight = '$weight $selectedUnit';
        sizeList.add(unitWeight);
      }

      await _firestore.collection('products').doc(productId).set({
        'productId': productId,
        'taxPercentage': selectedTaxPercentage,
        'category': selectedCategoryValue,
        'productSize': sizeList,
        'productName': productName,
        'price': price,
        'discountPrice': discountPrice,
        'quantity': quantity,
        'description': description,
        'productImages': imagesUrl,
        "salesCount": 0,
        'totalReviews': 0,
        'popular': false,
        'recommened': true,
      }).then((_) {
        selectedCategoryValue = null;
        sizeList.clear();
        images.clear();
        imagesUrl.clear();
        _sizeController.clear();

        // Resetting the isUploading flag after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            isUploading = false;
          });

          // Show success dialog
          _showSuccessDialog();

          // Show success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product uploaded successfully')),
          );
        });
      }).catchError((error) {
        print("Error uploading product: $error");
        setState(() {
          isUploading = false;
        });
      });
    } else {
      // Handle the case where there are no processed images
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No processed images to upload. Please select an image'),
        ),
      );
    }
  }

  Future<void> pickImage() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result!.files) {
        Uint8List? fileBytes = file.bytes;

        if (fileBytes != null) {
          String imageUrl = await uploadImageToStorage(fileBytes, file.name);

          setState(() {
            images.add(fileBytes);
            imagesUrl.add(imageUrl);
          });
        } else {
          print('Error: File bytes are null.');
        }
      }
    }
  }

  Future<String> uploadImageToStorage(Uint8List image, String imageName) async {
    try {
      // Append '.png' to the image name
      String imageNameWithExtension =
          const Uuid().v4() + '_' + imageName + '.png';
      Reference ref = _storage.ref().child('pm').child(imageNameWithExtension);

      // Set the content type to 'image/png' explicitly
      final metadata = SettableMetadata(contentType: 'image/png');
      await ref.putData(image, metadata);

      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  void _getCategories() {
    _firestore
        .collection('categories')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          _categoryList.add(doc['categoryName']);
        });
      }
    });
  }

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Product Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    'Product Name',
                    TextInputType.text,
                    (value) {
                      productName = value;
                    },
                    (value) {
                      if (value!.isEmpty) {
                        return "Please enter a product name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildInputField(
                          'MRP Price',
                          TextInputType.number,
                          (value) {
                            price = int.parse(value);
                          },
                          (value) {
                            if (value!.isEmpty) {
                              return "Please enter a mrp price";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: buildDropdownField('Category'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    'Discounted Price',
                    TextInputType.number,
                    (value) {
                      discountPrice = int.parse(value);
                    },
                    (value) {
                      if (value!.isEmpty) {
                        return "Please enter a discounted price";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  buildDropdownFieldTax(
                      'GST', taxPercentages, selectedTaxPercentage,
                      (double? value) {
                    setState(() {
                      selectedTaxPercentage = value!;
                    });
                  }),
                  const SizedBox(height: 16),
                  buildInputField('Description', TextInputType.multiline,
                      (value) {
                    description = value;
                  }, (value) {
                    if (value!.isEmpty) {
                      return "Please enter a description";
                    } else {
                      return null;
                    }
                  }, maxLines: 3),
                  const SizedBox(height: 16),
                  buildInputField(
                    'Stock',
                    TextInputType.number,
                    (value) {
                      quantity = int.parse(value);
                    },
                    (value) {
                      if (value!.isEmpty) {
                        return "Please enter a stock";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildInputField(
                          'Add Weight',
                          TextInputType.number,
                          (value) {
                            weight = int.parse(value);
                          },
                          (value) {
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: buildDropdownFieldWeight('Unit', [
                          null,
                          'kg',
                          'ltr',
                          'ml',
                          'dozen',
                          'pcs',
                          'gm',
                          'mg',
                          'bundle',
                          'crate'
                        ]), // Pass unit options here
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: images.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: ((context, index) {
                      if (index == 0) {
                        // Display the "Add" button for selecting more images
                        return Center(
                          child: IconButton(
                            onPressed: pickImage,
                            icon: const Icon(Icons.add),
                          ),
                        );
                      } else {
                        // Display the selected image with a delete icon
                        return Stack(
                          children: [
                            Image.memory(
                              images[index - 1],
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Remove the selected image from the list
                                    images.removeAt(index - 1);
                                    imagesUrl.removeAt(index - 1);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await uploadData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Fields must not be empty')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Upload Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
    String labelText,
    TextInputType keyboardType,
    void Function(String)? onChanged,
    String? Function(String?)? validator, {
    int? maxLines,
  }) {
    return TextFormField(
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget buildDropdownFieldTax(String labelText, List<double> items,
      double selectedItem, void Function(double?) onChanged) {
    return DropdownButtonFormField<double>(
      value: selectedItem,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<double>>((double value) {
        return DropdownMenuItem<double>(
          value: value,
          child: Text('$value%'),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }

  Widget buildDropdownField(String labelText) {
    return DropdownButtonFormField(
      value: selectedCategoryValue,
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            selectedCategoryValue = value;
          });
        }
      },
      items: _categoryList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }

  Widget buildDropdownFieldWeight(String labelText, List<String?> options) {
    return DropdownButtonFormField<String?>(
      value: selectedUnit, // Update: Set initial value to null
      onChanged: (String? value) {
        setState(() {
          selectedUnit = value;
        });
      },
      items: options.map<DropdownMenuItem<String?>>((String? value) {
        return DropdownMenuItem<String?>(
          value: value,
          child: Text(
            value ?? 'Select Unit',
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Product uploaded successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
