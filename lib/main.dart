import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/fossli_provider.dart';
import 'screens/fossli_list_screen.dart';
import 'ui/skin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FossliApp());
}

class FossliApp extends StatelessWidget {
  const FossliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FossliProvider()..load(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fossli Tracker',
        theme: buildFossliTheme(),
        home: const FossliListScreen(),
      ),
    );
  }
}
