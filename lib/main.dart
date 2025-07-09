import 'package:flutter/material.dart';
import 'package:yo_broker/screens/account_screen.dart';
import 'package:yo_broker/screens/home_screen.dart';

void main() {
  runApp(const YoBrokerApp());
}

class YoBrokerApp extends StatelessWidget {
  const YoBrokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yo Broker',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Open Sans',
            ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/account',
      routes: {
        '/account': (context) => const AccountScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
