import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../provider/orderProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class OrderDetails extends StatefulWidget {
  final QueryDocumentSnapshot order;

  const OrderDetails({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  late bool isDelivered;
  late bool isCancelled;
  late String? adminCancelReason;

  late TextEditingController _cancelReasonController;

  @override
  void initState() {
    super.initState();
    // Initialize delivery and cancellation status
    isDelivered = widget.order['delivered'];
    isCancelled = !widget.order['processing'];

    // Fetch admin cancellation reason if order is cancelled
    if (isCancelled) {
      fetchAdminCancelReason();
    }

    _cancelReasonController = TextEditingController();
  }

  // Method to fetch admin cancellation reason
  void fetchAdminCancelReason() async {
    try {
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .get();

      if (orderSnapshot.exists) {
        setState(() {
          adminCancelReason = orderSnapshot['adminCancelReason'];
        });
      } else {
        print('Order document does not exist');
      }
    } catch (e) {
      print('Error fetching admin cancellation reason: $e');
    }
  }

  Widget _rowHeader(int flex, String text) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          color: const Color(0xFF3C55EF),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget vendorData(Widget widget, int? flex, bool? last) {
    return Expanded(
      flex: flex!,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white12,
          border: Border(
            right:
                last! ? BorderSide.none : const BorderSide(color: Colors.grey),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Buyer Id
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Buyer Id: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' ${widget.order['buyerId']}'),
                          ],
                        ),
                      ),
                      // Name
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' ${widget.order['fullName']}'),
                          ],
                        ),
                      ),
                      // Address
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Address:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' ${widget.order['locality']}, ${widget.order['city']}, ${widget.order['pinCode']}, ${widget.order['state']}',
                            ),
                          ],
                        ),
                      ),
                      // Email
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Email: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.order['email']}',
                            ),
                          ],
                        ),
                      ),
                      // Phone Number
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Phone Number: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.order['phoneNumber']}',
                            ),
                          ],
                        ),
                      ),
                      // Order Id
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Order Id:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' ${widget.order['orderId']}'),
                          ],
                        ),
                      ),
                      // Order Time
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Ordered Time: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' ${widget.order['timestamp']}'),
                          ],
                        ),
                      ),
                      // Display admin cancellation reason if available
                      if (isCancelled && adminCancelReason != null)
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              const TextSpan(
                                text: 'Admin Cancellation Reason: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: adminCancelReason!,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  // Delivered
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDelivered ||
                              (orderProvider.isInOrder(widget.order['orderId'])
                                  ? orderProvider
                                      .isDelivered(widget.order['orderId'])
                                  : false)
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isDelivered ||
                              (orderProvider.isInOrder(widget.order['orderId'])
                                  ? orderProvider
                                      .isDelivered(widget.order['orderId'])
                                  : false)
                          ? 'Delivered'
                          : isCancelled ||
                                  (orderProvider
                                          .isInOrder(widget.order['orderId'])
                                      ? orderProvider
                                          .isCancelled(widget.order['orderId'])
                                      : false)
                              ? 'Cancelled'
                              : 'Pending',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  _rowHeader(1, 'Image'),
                  _rowHeader(1, 'Product Id'),
                  _rowHeader(1, 'Name'),
                  _rowHeader(1, 'Quantity'),
                  _rowHeader(1, 'Price'),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.order['items'].length,
                itemBuilder: ((context, index) {
                  final product = widget.order['items'][index];
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black54),
                        right: BorderSide(color: Colors.black54),
                        left: BorderSide(color: Colors.black54),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Order Id
                        vendorData(
                          Image.network(product['productImage']),
                          1,
                          false,
                        ),

                        // Full Name
                        vendorData(
                          Text(
                            product['productId'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          1,
                          false,
                        ),

                        // Product Name
                        vendorData(
                          Column(
                            children: [
                              Text(
                                '${product['productName']} ${product['size'] != '' ? '[${product['size']}]' : ''}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 5,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          1,
                          false,
                        ),

                        // Phone Number
                        vendorData(
                          Text(
                            product['quantity'].toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          1,
                          false,
                        ),

                        // Payment Mode
                        vendorData(
                          Text(
                            '\u{20B9}${product['price']}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          1,
                          false,
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Total Price: \u{20B9}${widget.order['price']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Display buttons to mark as delivered or cancel order
              if (!isDelivered &&
                  !isCancelled &&
                  !orderProvider.isInOrder(widget.order['orderId']))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mark as delivered
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        // Show confirmation dialog
                        bool confirm = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm'),
                              content: const Text(
                                  'Are you sure you want to mark this order as delivered?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        false); // Return false when canceled
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        true); // Return true when confirmed
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          // If confirmed, proceed with marking the order as delivered
                          try {
                            // Update 'delivered' status to true and processing to false
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(widget.order.id)
                                .update({
                              'delivered': true,
                              'processing': false,
                            });

                            setState(() {
                              isDelivered = true;
                              isCancelled = false;
                            });

                            // Increment the sale count for each product in the order
                            for (var item in widget.order['items']) {
                              await FirebaseFirestore.instance
                                  .runTransaction((transaction) async {
                                DocumentSnapshot productSnapshot =
                                    await transaction.get(
                                  FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(item['productId']),
                                );

                                // Check if the product exists
                                if (productSnapshot.exists) {
                                  // Increment the sale count by 1
                                  int currentSaleCount =
                                      productSnapshot['salesCount'] ?? 0;
                                  transaction.update(
                                    FirebaseFirestore.instance
                                        .collection('products')
                                        .doc(item['productId']),
                                    {'salesCount': currentSaleCount + 1},
                                  );
                                }
                              });
                            }
                            // Send order notification
                            sendOrderNotification(widget.order.id, false);
                          } catch (error) {
                            print('Error marking order as delivered: $error');
                          }
                        }
                      },
                      child: const Text(
                        'Mark Delivered',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 30,
                    ),

                    // Cancel order
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        // Show cancellation reason input dialog
                        String? cancelReason = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Enter Cancellation Reason'),
                              content: TextField(
                                controller: _cancelReasonController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter reason here...',
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        _cancelReasonController.text.trim());
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );

                        if (cancelReason != null && cancelReason.isNotEmpty) {
                          // If cancellation reason is provided, proceed with canceling the order
                          try {
                            // Update 'delivered' status to false and processing to false
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(widget.order.id)
                                .update({
                              'delivered': false,
                              'processing': false,
                              'adminCancelReason': cancelReason,
                            });

                            setState(() {
                              isCancelled = true;
                              isDelivered = false;
                              adminCancelReason = cancelReason;
                            });

                            // Increment product quantities
                            List<dynamic> items = widget.order['items'];
                            WriteBatch batch =
                                FirebaseFirestore.instance.batch();

                            for (var item in items) {
                              DocumentReference productRef = FirebaseFirestore
                                  .instance
                                  .collection('products')
                                  .doc(item['productId']);

                              batch.update(productRef, {
                                'quantity':
                                    FieldValue.increment(item['quantity']),
                              });
                            }

                            await batch.commit();
                            // Send order notification
                            sendOrderNotification(widget.order.id, true);
                          } catch (error) {
                            print('Error canceling order: $error');
                          }
                        }
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
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

        var result = http.post(
          Uri.parse(EmailJS_API_URL),
          headers: {
            'origin': 'http:localhost',
            'Content-Type': 'application/json'
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
              'productList': productList
            }
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
}
