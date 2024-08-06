import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

void main() async {
  await dotenv.load(fileName: ".env");
}

void sendOrderNotification(String orderId, bool isCancelled) async {
  var Service_id = dotenv.env['SERVICE_ID']!;
  var Template_id = isCancelled
      ? dotenv.env['TEMPLATE_ID_CANCELLED']!
      : dotenv.env['TEMPLATE_ID_DELIVERED']!;
  var User_id = dotenv.env['USER_ID']!;
  var EmailJS_API_URL = dotenv.env['EMAILJS_API_URL']!;

  try {
    // Fetch order data using the orderId
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    if (orderSnapshot.exists) {
      Map<String, dynamic> orderData =
          orderSnapshot.data() as Map<String, dynamic>;

      String productList = orderData['items'].map((product) {
        // Check if the product has a size
        String sizeInfo = '';
        if (product['size'] != null && product['size'].isNotEmpty) {
          sizeInfo = 'Weight: ${product['size']}';
        }

        return '''
        Name: ${product['productName']}
        Category: ${product['productCategory']}
        $sizeInfo
        Price: ${product['price']}
        
        
      ''';
      }).join('');

      var result = await http.post(
        Uri.parse(EmailJS_API_URL),
        headers: {
          'origin': 'http:localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': Service_id,
          'user_id': User_id,
          'template_id': Template_id,
          'template_params': {
            'sender_email': orderData['email'],
            'subject': isCancelled ? 'Order Cancelled' : 'Order Delivered',
            'orderId': orderSnapshot['orderId'],
            'email': orderSnapshot['email'],
            'pinCode': orderSnapshot['pinCode'],
            'locality': orderSnapshot['locality'],
            'city': orderSnapshot['city'],
            'state': orderSnapshot['state'],
            'fullName': orderSnapshot['fullName'],
            'phoneNumber': orderSnapshot['phoneNumber'],
            'mode': orderSnapshot['mode'],
            'price': orderSnapshot['price'],
            'timestamp': orderSnapshot['timestamp'],
            'productList': productList,
          },
        }),
      );
    } else {
      print('Order document does not exist');
    }
  } catch (e) {
    print('Something went wrong while fetching or sending mail');
    print('Error: $e');
  }
}
