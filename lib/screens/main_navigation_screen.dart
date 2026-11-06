import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../state/recipe_state.dart';
import 'add_recipe_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'my_food_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationScreenState>();
    state?.setTab(index);
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeState = RecipeScope.of(context);
    final favCount = recipeState.favoriteRecipes.length;
    final myFoodCount = recipeState.userRecipes.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 768;

        final screens = [
          const HomeScreen(),
          const FavoritesScreen(),
          const MyFoodScreen(),
        ];

        if (isLargeScreen) {
          // Large screen layout (Web / Tablet) with side NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: setTab,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF7A59)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowAccent,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.soup_kitchen_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: FloatingActionButton.small(
                          elevation: 2,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          tooltip: 'Add Recipe',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddRecipeScreen(),
                              ),
                            );
                          },
                          child: const Icon(Icons.add_rounded),
                        ),
                      ),
                    ),
                  ),
                  indicatorColor: AppColors.primaryLight,
                  selectedIconTheme: const IconThemeData(color: AppColors.primary),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Badge(
                        isLabelVisible: favCount > 0,
                        label: Text('$favCount'),
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.favorite_outline_rounded),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: favCount > 0,
                        label: Text('$favCount'),
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.favorite_rounded),
                      ),
                      label: const Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Badge(
                        isLabelVisible: myFoodCount > 0,
                        label: Text('$myFoodCount'),
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.restaurant_menu_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: myFoodCount > 0,
                        label: Text('$myFoodCount'),
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.restaurant_menu_rounded),
                      ),
                      label: const Text('My Food'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppColors.borderLight),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: IndexedStack(
                        index: _currentIndex,
                        children: screens,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile layout with modern BottomNavigationBar
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: setTab,
                height: 68,
                backgroundColor: Colors.white,
                elevation: 0,
                indicatorColor: AppColors.primaryLight,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
                    selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: favCount > 0,
                      label: Text('$favCount'),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.favorite_outline_rounded, color: AppColors.textSecondary),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: favCount > 0,
                      label: Text('$favCount'),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.favorite_rounded, color: AppColors.primary),
                    ),
                    label: 'Favorites',
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: myFoodCount > 0,
                      label: Text('$myFoodCount'),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.restaurant_menu_outlined, color: AppColors.textSecondary),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: myFoodCount > 0,
                      label: Text('$myFoodCount'),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary),
                    ),
                    label: 'My Food',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
