import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ghar_ka_bazaar/views/screens/inner_screens/orderDetailScreen.dart';

class OrderWidget extends StatefulWidget {
  final String searchQuery;

  const OrderWidget({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  final Stream<QuerySnapshot> _orderStream =
      FirebaseFirestore.instance.collection('orders').snapshots();

  Widget vendorData(Widget widget, int? flex, bool? last) {
    return Expanded(
      flex: flex!,
      child: Container(
        height: 100,
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
    return StreamBuilder<QuerySnapshot>(
      stream: _orderStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        final List<QueryDocumentSnapshot> documents = snapshot.data!.docs
            .cast<QueryDocumentSnapshot>(); // Cast to QueryDocumentSnapshot
        final reversedDocuments =
            documents.reversed.toList(); // Reverse the list

        // Filter the documents based on the search query
        final filteredDocuments = widget.searchQuery.isEmpty
            ? reversedDocuments
            : reversedDocuments
                .where((doc) => doc['orderId']
                    .toString()
                    .toLowerCase()
                    .contains(widget.searchQuery.toLowerCase()))
                .toList();

        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredDocuments.length,
          itemBuilder: ((context, index) {
            final order = filteredDocuments[index];
            final orderData = order.data() as Map<String, dynamic>;
            final orderId = orderData['orderId'] ?? '';
            final fullName = orderData['fullName'] ?? '';
            final email = orderData['email'] ?? '';
            final locality = orderData['locality'] ?? '';
            final city = orderData['city'] ?? '';
            final pinCode = orderData['pinCode'] ?? '';
            final state = orderData['state'] ?? '';
            final phoneNumber = orderData['phoneNumber'] ?? '';
            final mode = orderData['mode'] ?? '';
            final time = orderData['timestamp'] ?? '';

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
                  vendorData(
                    Text(
                      orderId,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    1,
                    false,
                  ),
                  vendorData(
                    Text(
                      fullName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false,
                  ),
                  vendorData(
                    Text(
                      email,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false,
                  ),
                  vendorData(
                    Text(
                      '$locality $city $pinCode $state',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false,
                  ),
                  vendorData(
                    Text(
                      phoneNumber,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false,
                  ),
                  vendorData(
                    Text(
                      mode,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false,
                  ),
                  vendorData(
                    Text(
                      time,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false,
                  ),
                  vendorData(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C55EF),
                        ),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetails(
                                order: order,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'View Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    1,
                    true,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
