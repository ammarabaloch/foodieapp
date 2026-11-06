import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'state/recipe_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for seamless warm background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FoodieApp());
}

class FoodieApp extends StatefulWidget {
  const FoodieApp({super.key});

  @override
  State<FoodieApp> createState() => _FoodieAppState();
}

class _FoodieAppState extends State<FoodieApp> {
  late final RecipeState _recipeState;

  @override
  void initState() {
    super.initState();
    _recipeState = RecipeState();
  }

  @override
  void dispose() {
    _recipeState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RecipeScope(
      state: _recipeState,
      child: MaterialApp(
        title: 'Foodie - Recipe App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
