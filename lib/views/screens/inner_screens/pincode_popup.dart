import 'package:flutter/material.dart';

class PincodePopup extends StatefulWidget {
  @override
  _PincodePopupState createState() => _PincodePopupState();
}

class _PincodePopupState extends State<PincodePopup> {
  final TextEditingController _pincodeController = TextEditingController();
  final String allowedPincode = '400614';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Pincode'),
      content: TextField(
        controller: _pincodeController,
        decoration: InputDecoration(labelText: 'Pincode'),
        keyboardType: TextInputType.number,
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            // Check if the entered pincode matches the allowed pincode
            if (_pincodeController.text == allowedPincode) {
              // Close the dialog and allow order
              Navigator.pop(context);
              // Perform action after pincode verification (e.g., navigate to order screen)
            } else {
              // Display an error message
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delivery Is Available in Entered Pincode'),
                  content: Text('You can order the product.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text('Check Delivery'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose the text controller
    _pincodeController.dispose();
    super.dispose();
  }
}
