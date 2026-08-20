import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/pos_provider.dart';
import 'providers/language_provider.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BienPosApp());
}

class BienPosApp extends StatelessWidget {
  const BienPosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        title: 'Bien POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            primary: Colors.indigo,
            secondary: Colors.teal,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'Roboto',
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
