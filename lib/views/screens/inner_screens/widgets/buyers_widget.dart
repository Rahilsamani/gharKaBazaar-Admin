import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../user_order_screen.dart";

class BuyersWidget extends StatefulWidget {
  @override
  _BuyersWidgetState createState() => _BuyersWidgetState();
}

class _BuyersWidgetState extends State<BuyersWidget> {
  final Stream<QuerySnapshot> _orderStream =
      FirebaseFirestore.instance.collection('buyers').snapshots();

  Widget _vendorData(Widget widget, int? flex, bool? last) {
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

  Future<void> _toggleBan(String buyerId, bool currentBanStatus) async {
    final buyerRef =
        FirebaseFirestore.instance.collection('buyers').doc(buyerId);
    bool confirmAction = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentBanStatus ? 'Unban Buyer' : 'Ban Buyer'),
          content: Text(currentBanStatus
              ? 'Are you sure you want to unban this buyer?'
              : 'Are you sure you want to ban this buyer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(currentBanStatus ? 'Unban' : 'Ban'),
            ),
          ],
        );
      },
    );

    if (confirmAction != null && confirmAction) {
      await buyerRef.update({'ban': !currentBanStatus});
    }
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

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: ((context, index) {
            final vendor = snapshot.data!.docs[index];
            final bool isBanned = vendor['ban'] ?? false;
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserOrderScreen(
                            userId: vendor['uid'],
                          )),
                );
              },
              child: Container(
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
                    _vendorData(
                        vendor['profileImage'] == ""
                            ? Image.network(
                                "https://cdn.pixabay.com/photo/2014/04/03/10/32/businessman-310819_1280.png",
                                fit: BoxFit.contain,
                              )
                            : Image.network(
                                vendor['profileImage'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                        1,
                        false),
                    _vendorData(
                        Text(
                          vendor['fullName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        1,
                        false),
                    _vendorData(
                        Text(
                          vendor['locality'] +
                              " " +
                              vendor['city'] +
                              " " +
                              vendor['state'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        2,
                        false),
                    _vendorData(
                        Text(
                          vendor['email'],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        1,
                        false),
                    _vendorData(
                        Text(
                          vendor['phoneNumber'],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        1,
                        false),
                    _vendorData(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isBanned ? Colors.green : Colors.red,
                            ),
                            onPressed: () async {
                              await _toggleBan(vendor.id, isBanned);
                            },
                            child: Text(
                              isBanned ? 'Unban' : 'Ban',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        1,
                        true),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
