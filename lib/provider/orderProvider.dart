import 'package:flutter/material.dart';

class Order {
  final String orderId;
  bool isDelivered;
  bool isCancelled;

  Order({
    required this.orderId,
    this.isDelivered = false,
    this.isCancelled = false,
  });
}

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => _orders;

  void addOrder(
      {required String orderId,
      bool isDelivered = false,
      bool isCancelled = false}) {
    _orders.add(Order(
        orderId: orderId, isDelivered: isDelivered, isCancelled: isCancelled));
    notifyListeners();
  }

  bool isInOrder(String orderId) {
    return _orders.any((order) => order.orderId == orderId);
  }

  bool isDelivered(String orderId) {
    final order = _orders.firstWhere(
      (order) => order.orderId == orderId,
    );
    return order != null ? order.isDelivered : false;
  }

  bool isCancelled(String orderId) {
    final order = _orders.firstWhere(
      (order) => order.orderId == orderId,
    );
    return order != null ? order.isCancelled : false;
  }
}
