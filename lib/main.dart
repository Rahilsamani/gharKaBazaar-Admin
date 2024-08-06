import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:ghar_ka_bazaar/provider/orderProvider.dart';
import 'package:ghar_ka_bazaar/views/screens/inner_screens/buyers_screen.dart';
import 'package:ghar_ka_bazaar/views/screens/inner_screens/category_screen.dart';
import 'package:ghar_ka_bazaar/views/screens/inner_screens/order_scree.dart';
import 'package:ghar_ka_bazaar/views/screens/inner_screens/upload_banner_screen.dart';
import 'package:ghar_ka_bazaar/views/screens/inner_screens/widgets/all_products.dart';
import 'package:ghar_ka_bazaar/views/screens/upload_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: kIsWeb || Platform.isAndroid
        ? FirebaseOptions(
            apiKey: dotenv.env['API_KEY']!,
            authDomain: dotenv.env['AUTH_DOMAIN']!,
            projectId: dotenv.env['PROJECT_ID']!,
            storageBucket: dotenv.env['STORAGE_BUCKET']!,
            messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
            appId: dotenv.env['APP_ID']!,
            measurementId: dotenv.env['MEASUREMENT_ID']!)
        : null,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => OrderProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ghar Ka Bazaar',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SideMenu(),
      ),
    );
  }
}

class SideMenu extends StatefulWidget {
  static const String id = '\sideMenu';

  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  Widget _selectedScreen = BuyersScreen();
  String _selectedRoute = BuyersScreen.routeName;

  screenSelector(item) {
    switch (item.route) {
      case ProductList.id:
        setState(() {
          _selectedScreen = ProductList();
          _selectedRoute = ProductList.id;
        });
        break;
      case CategoryScreen.id:
        setState(() {
          _selectedScreen = const CategoryScreen();
          _selectedRoute = CategoryScreen.id;
        });
        break;
      case BuyersScreen.routeName:
        setState(() {
          _selectedScreen = BuyersScreen();
          _selectedRoute = BuyersScreen.routeName;
        });
        break;
      case OrderScreen.routeName:
        setState(() {
          _selectedScreen = const OrderScreen();
          _selectedRoute = OrderScreen.routeName;
        });
        break;
      case UploadBanners.id:
        setState(() {
          _selectedScreen = const UploadBanners();
          _selectedRoute = UploadBanners.id;
        });
        break;
      case ProductUploadPage.id:
        setState(() {
          _selectedScreen = ProductUploadPage();
          _selectedRoute = ProductUploadPage.id;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3C55EF),
        title: const Text(
          'Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: 'ALL Product List',
            icon: CupertinoIcons.shopping_cart,
            route: ProductList.id,
          ),
          AdminMenuItem(
            title: 'Buyers',
            route: BuyersScreen.routeName,
            icon: CupertinoIcons.person,
          ),
          AdminMenuItem(
            title: 'Orders',
            route: OrderScreen.routeName,
            icon: CupertinoIcons.shopping_cart,
          ),
          AdminMenuItem(
            title: 'Categories',
            icon: Icons.category_rounded,
            route: CategoryScreen.id,
          ),
          AdminMenuItem(
            title: 'Upload Banner',
            icon: CupertinoIcons.add,
            route: UploadBanners.id,
          ),
          AdminMenuItem(
            title: 'Add Products',
            icon: CupertinoIcons.shopping_cart,
            route: ProductUploadPage.id,
          ),
        ],
        selectedRoute: _selectedRoute,
        onSelected: (item) {
          screenSelector(item);
        },
        header: Container(
          height: 50,
          width: double.infinity,
          color: Colors.black,
          child: Center(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFFFF9933), // Saffron color
                    Colors.white, // White color
                    Color(0xFF138808), // Green color
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds);
              },
              child: const Text(
                'Ghar ka Bazaar Admin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .white, // Text color will be black for better visibility
                ),
              ),
            ),
          ),
        ),
      ),
      body: _selectedScreen,
    );
  }
}
