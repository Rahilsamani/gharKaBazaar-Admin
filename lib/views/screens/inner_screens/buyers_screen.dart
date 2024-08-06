import 'package:flutter/material.dart';
import 'package:ghar_ka_bazaar/views/screens/inner_screens/widgets/buyers_widget.dart';

class BuyersScreen extends StatefulWidget {
  static const String routeName = '\BuyersScreen';

  @override
  State<BuyersScreen> createState() => _BuyersScreenState();
}

class _BuyersScreenState extends State<BuyersScreen> {
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Buyers',
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
              Row(
                children: [
                  _rowHeader(1, 'Image'),
                  _rowHeader(1, 'Full Name '),
                  _rowHeader(2, 'Address'),
                  _rowHeader(1, 'Email'),
                  _rowHeader(1, 'Phone Number'),
                  _rowHeader(1, 'Ban User'),
                ],
              ),
              BuyersWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
