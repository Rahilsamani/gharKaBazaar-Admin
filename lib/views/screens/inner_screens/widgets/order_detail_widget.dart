import 'package:flutter/material.dart';

class OrderDetailWidget extends StatelessWidget {
  final List<dynamic> orderItems;

  const OrderDetailWidget({super.key, required this.orderItems});

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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: orderItems.length,
      itemBuilder: ((context, index) {
        final product = orderItems[index];
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
                vendorData(Image.network(product['productImage']), 1, false),

                // Full Name
                vendorData(
                    Text(
                      product['productId'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false),

                // Email
                vendorData(
                    Text(
                      product['productName'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false),

                // Phone Number
                vendorData(
                    Text(
                      product['quantity'].toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false),

                // Payment Mode
                vendorData(
                    Text(
                      '\u{20B9}' + product['price'].toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    1,
                    false),
              ],
            ));
      }),
    );
  }
}

