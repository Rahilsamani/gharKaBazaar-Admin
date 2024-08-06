import 'package:flutter/material.dart';
import 'package:ghar_ka_bazaar/views/screens/inner_screens/widgets/order_widget.dart';

class OrderScreen extends StatefulWidget {
  static const String routeName = '\orderScreen';

  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Orders',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by Order ID',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _rowHeader(1, 'Order Id'),
                _rowHeader(1, 'Full Name '),
                _rowHeader(1, 'Email'),
                _rowHeader(1, 'Address'),
                _rowHeader(1, 'Mobile'),
                _rowHeader(1, 'Mode'),
                _rowHeader(1, 'Time'),
                _rowHeader(1, 'ACTION'),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: OrderWidget(searchQuery: _searchQuery),
            ),
          ],
        ),
      ),
    );
  }
}
