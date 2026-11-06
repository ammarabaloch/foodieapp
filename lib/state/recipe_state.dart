import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

class RecipeState extends ChangeNotifier {
  static const String _keyFavorites = 'foodie_favorite_ids_v1';
  static const String _keyUserRecipes = 'foodie_user_recipes_v1';
  static const String _keyEditedRecipes = 'foodie_edited_recipes_v1';

  RecipeState() {
    _recipes = _getInitialRecipes();
    _loadPersistentData();
  }

  late List<Recipe> _recipes;
  final Set<String> _favoriteIds = {};
  String _searchQuery = '';
  String _selectedCategoryId = 'all';
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<Recipe> get allRecipes => List.unmodifiable(_recipes);
  String get searchQuery => _searchQuery;
  String get selectedCategoryId => _selectedCategoryId;

  // Featured recipes
  List<Recipe> get featuredRecipes =>
      _recipes.where((r) => r.isFeatured).toList();

  // Popular recipes
  List<Recipe> get popularRecipes =>
      _recipes.where((r) => !r.isFeatured || r.rating >= 4.8).toList();

  // Favorite recipes (ordered by favorite status)
  List<Recipe> get favoriteRecipes =>
      _recipes.where((r) => r.isFavorite || _favoriteIds.contains(r.id)).toList();

  // User-created recipes ("My Food" / "My Recipes")
  List<Recipe> get userRecipes =>
      _recipes.where((r) => r.isUserCreated).toList();

  // Filtered recipes: filters strictly by active category and search query
  List<Recipe> get filteredRecipes {
    return _recipes.where((recipe) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          recipe.title.toLowerCase().contains(query) ||
          recipe.category.toLowerCase().contains(query) ||
          recipe.description.toLowerCase().contains(query) ||
          recipe.ingredients.any((ing) => ing.toLowerCase().contains(query));

      bool matchesCategory = true;
      if (_selectedCategoryId != 'all') {
        if (_selectedCategoryId == 'my_food') {
          matchesCategory = recipe.isUserCreated;
        } else if (_selectedCategoryId == 'healthy') {
          matchesCategory = recipe.isHealthy;
        } else {
          matchesCategory = recipe.category.toLowerCase() ==
              _selectedCategoryId.toLowerCase();
        }
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = 'all';
    } else {
      _selectedCategoryId = categoryId;
    }
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = 'all';
    notifyListeners();
  }

  bool isFavorite(String recipeId) {
    return _favoriteIds.contains(recipeId);
  }

  Future<void> toggleFavorite(String recipeId) async {
    final isFav = _favoriteIds.contains(recipeId);
    if (isFav) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }

    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _recipes[index] = _recipes[index].copyWith(isFavorite: !isFav);
    }

    notifyListeners();
    await _saveFavorites();
  }

  Future<void> addRecipe(Recipe recipe) async {
    // Add to top of list
    _recipes.insert(0, recipe);
    notifyListeners();
    await _saveUserRecipes();
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    final index = _recipes.indexWhere((r) => r.id == updatedRecipe.id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      notifyListeners();
      if (updatedRecipe.isUserCreated) {
        await _saveUserRecipes();
      } else {
        await _saveEditedRecipes();
      }
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    _recipes.removeWhere((r) => r.id == recipeId);
    _favoriteIds.remove(recipeId);
    notifyListeners();
    await _saveUserRecipes();
    await _saveFavorites();
  }

  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Persistence Methods using shared_preferences ---

  Future<void> _loadPersistentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load favorites
      final savedFavs = prefs.getStringList(_keyFavorites);
      if (savedFavs != null) {
        _favoriteIds.clear();
        _favoriteIds.addAll(savedFavs);
      }

      // 2. Load custom user recipes
      final savedUserJson = prefs.getString(_keyUserRecipes);
      List<Recipe> userRecipes = [];
      if (savedUserJson != null) {
        final List<dynamic> decoded = jsonDecode(savedUserJson) as List<dynamic>;
        userRecipes = decoded
            .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // 3. Load edited versions of built-in recipes
      final savedEditedJson = prefs.getString(_keyEditedRecipes);
      Map<String, Recipe> editedMap = {};
      if (savedEditedJson != null) {
        final List<dynamic> decoded = jsonDecode(savedEditedJson) as List<dynamic>;
        for (final item in decoded) {
          final r = Recipe.fromJson(item as Map<String, dynamic>);
          editedMap[r.id] = r;
        }
      }

      // Merge data
      final baseRecipes = _getInitialRecipes();
      final List<Recipe> mergedList = [];

      // Add user custom recipes first
      if (userRecipes.isNotEmpty) {
        mergedList.addAll(userRecipes);
      } else {
        // Keep initial user recipe if none saved yet
        final initialUserRecipe = baseRecipes.firstWhere((r) => r.isUserCreated);
        mergedList.add(initialUserRecipe);
      }

      // Add built-in recipes (replacing with edited if modified)
      for (final r in baseRecipes) {
        if (r.isUserCreated) continue;
        if (editedMap.containsKey(r.id)) {
          mergedList.add(editedMap[r.id]!);
        } else {
          mergedList.add(r);
        }
      }

      // Apply favorite status to all recipes
      _recipes = mergedList.map((r) {
        final isFav = _favoriteIds.contains(r.id);
        return r.copyWith(isFavorite: isFav);
      }).toList();

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading persistent recipe data: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyFavorites, _favoriteIds.toList());
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  Future<void> _saveUserRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userList = _recipes.where((r) => r.isUserCreated).toList();
      final jsonString = jsonEncode(userList.map((r) => r.toJson()).toList());
      await prefs.setString(_keyUserRecipes, jsonString);
    } catch (e) {
      debugPrint('Error saving user recipes: $e');
    }
  }

  Future<void> _saveEditedRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final editedBuiltIn =
          _recipes.where((r) => !r.isUserCreated).map((r) => r.toJson()).toList();
      await prefs.setString(_keyEditedRecipes, jsonEncode(editedBuiltIn));
    } catch (e) {
      debugPrint('Error saving edited recipes: $e');
    }
  }

  static List<Recipe> _getInitialRecipes() {
    return [
      const Recipe(
        id: 'rec_10',
        title: 'Grandma’s Golden Herb Roast Chicken',
        description:
            'Whole roasted farm chicken with crisp golden skin, basted with rosemary-thyme garlic butter and roasted baby potatoes.',
        imageUrl:
            'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?auto=format&fit=crop&w=900&q=80',
        category: 'Dinner',
        prepTime: '20 min',
        cookTime: '55 min',
        servings: 5,
        calories: 520,
        difficulty: 'Medium',
        isFavorite: false,
        isFeatured: false,
        isHealthy: false,
        isUserCreated: true,
        rating: 4.93,
        reviewCount: 42,
        author: 'You (Home Chef)',
        ingredients: [
          '1 whole chicken (approx 3.5 lbs), cleaned',
          '4 tbsp softened unsalted butter',
          '3 sprigs fresh rosemary, minced',
          '4 sprigs fresh thyme leaves',
          '6 cloves garlic, crushed',
          '1 lemon, halved',
          '1 lb baby Yukon gold potatoes, halved',
          '2 tbsp olive oil, salt, and coarse black pepper',
        ],
        instructions: [
          'Pat chicken completely dry. Season cavity with salt, pepper, lemon halves, and garlic.',
          'Mix softened butter with minced rosemary, thyme, salt, and black pepper.',
          'Carefully loosen the breast skin and rub herb butter directly onto the meat and over the skin.',
          'Toss halved baby potatoes with olive oil, salt, and pepper in a roasting pan, placing chicken on top.',
          'Roast at 400°F (200°C) for 55-60 minutes until juices run clear and skin is deep golden crisp.',
          'Rest for 10 minutes before carving and serving with roasted potatoes.',
        ],
      ),
      const Recipe(
        id: 'rec_1',
        title: 'Avocado & Poached Egg Toast',
        description:
            'Crispy toasted artisanal sourdough topped with rich smashed avocado, perfectly poached organic eggs, chili flakes, and microgreens.',
        imageUrl:
            'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=900&q=80',
        category: 'Breakfast',
        prepTime: '10 min',
        cookTime: '5 min',
        servings: 2,
        calories: 320,
        difficulty: 'Easy',
        isFavorite: true,
        isFeatured: true,
        isHealthy: true,
        rating: 4.9,
        reviewCount: 142,
        author: 'Chef Isabella',
        ingredients: [
          '2 thick slices sourdough bread',
          '2 large organic free-range eggs',
          '1 ripe Hass avocado',
          '1 tbsp extra virgin olive oil',
          '1/2 tsp crushed red pepper flakes',
          '1 tbsp freshly squeezed lemon juice',
          'Fresh microgreens or baby arugula',
          'Flaky sea salt & freshly ground black pepper',
        ],
        instructions: [
          'Toast the sourdough slices until golden and crisp with a sturdy crust.',
          'In a bowl, coarsely mash the avocado with lemon juice, a pinch of sea salt, and black pepper.',
          'Bring a saucepan of water to a gentle simmer. Create a gentle whirlpool and slip in the cracked eggs one at a time. Poach for 3 minutes until whites are set and yolks remain runny.',
          'Generously spread the seasoned mashed avocado over the warm toasted sourdough.',
          'Gently place a poached egg on each slice. Top with red pepper flakes, microgreens, and a drizzle of olive oil.',
        ],
      ),
      const Recipe(
        id: 'rec_2',
        title: 'Creamy Tuscan Garlic Butter Salmon',
        description:
            'Pan-seared salmon fillets in a velvety garlic parmesan cream sauce infused with sun-dried tomatoes and baby spinach.',
        imageUrl:
            'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=900&q=80',
        category: 'Dinner',
        prepTime: '15 min',
        cookTime: '20 min',
        servings: 4,
        calories: 490,
        difficulty: 'Medium',
        isFavorite: true,
        isFeatured: true,
        isHealthy: true,
        rating: 4.95,
        reviewCount: 238,
        author: 'Chef Marco Rossi',
        ingredients: [
          '4 fresh skin-on salmon fillets (6 oz each)',
          '2 tbsp olive oil and 2 tbsp unsalted butter',
          '6 cloves garlic, finely minced',
          '1 cup heavy cream or coconut cream',
          '1/2 cup grated Parmigiano-Reggiano',
          '1/2 cup sun-dried tomatoes, drained and sliced',
          '3 cups fresh baby spinach leaves',
          '1 tbsp freshly chopped flat-leaf parsley',
          'Salt and freshly cracked black pepper to taste',
        ],
        instructions: [
          'Pat salmon fillets dry with paper towels. Season both sides generously with salt and pepper.',
          'Heat olive oil in a large skillet over medium-high heat. Sear salmon skin-side up for 5 minutes, flip and cook for 3-4 minutes until golden. Transfer to a plate.',
          'Melt butter in the same skillet. Add minced garlic and cook for 1 minute until fragrant.',
          'Pour in heavy cream and bring to a gentle simmer. Stir in grated Parmesan until smoothly melted.',
          'Add sun-dried tomatoes and fresh spinach. Cook for 2-3 minutes until spinach wilts.',
          'Return salmon fillets to the skillet, spooning sauce over each fillet. Simmer for 2 minutes and garnish with fresh parsley.',
        ],
      ),
      const Recipe(
        id: 'rec_3',
        title: 'Authentic Margherita Pizza',
        description:
            'Classic Italian pizza with hand-stretched dough, sweet San Marzano tomato sauce, fresh mozzarella di bufala, and fragrant basil.',
        imageUrl:
            'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=900&q=80',
        category: 'Italian',
        prepTime: '25 min',
        cookTime: '12 min',
        servings: 3,
        calories: 640,
        difficulty: 'Medium',
        isFavorite: false,
        isFeatured: true,
        isHealthy: false,
        rating: 4.88,
        reviewCount: 310,
        author: 'Chef Antonio',
        ingredients: [
          '1 ball artisan pizza dough (fermented 24 hrs)',
          '1/2 cup crushed San Marzano tomatoes',
          '200g fresh mozzarella di bufala, torn',
          'Fresh Italian basil leaves',
          '2 tbsp premium extra virgin olive oil',
          '1/2 tsp sea salt',
        ],
        instructions: [
          'Preheat pizza oven or standard oven with a baking stone to 500°F (260°C).',
          'Stretch dough on a floured work surface by hand, pushing air from the center out to create a puffy crust border.',
          'Spread crushed San Marzano tomatoes evenly across the dough, leaving a 1-inch border.',
          'Distribute torn mozzarella evenly over the sauce and drizzle with olive oil.',
          'Bake for 10-12 minutes until crust is blistered and cheese is bubbling with golden spots.',
          'Finish with fresh torn basil leaves immediately upon removing from oven.',
        ],
      ),
      const Recipe(
        id: 'rec_4',
        title: 'Tokyo Tonkotsu Miso Ramen',
        description:
            'Rich 12-hour bone broth infused with red miso, springy wheat noodles, tender rolled chashu pork, marinated soft-boiled egg, and nori.',
        imageUrl:
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=900&q=80',
        category: 'Asian',
        prepTime: '20 min',
        cookTime: '40 min',
        servings: 2,
        calories: 590,
        difficulty: 'Hard',
        isFavorite: true,
        isFeatured: false,
        isHealthy: false,
        rating: 4.92,
        reviewCount: 185,
        author: 'Master Kenji',
        ingredients: [
          '2 portions fresh artisan ramen noodles',
          '4 cups rich pork or chicken bone broth',
          '3 tbsp Japanese red miso paste',
          '4 slices slow-braised chashu pork belly',
          '2 ajitsuke tamago (ramen eggs, halved)',
          '2 sheets crispy nori seaweed',
          '1/2 cup sliced bamboo shoots (menma)',
          '2 stalks green scallions, thinly sliced',
          '1 tbsp black garlic oil or sesame oil',
        ],
        instructions: [
          'In a medium pot, bring bone broth to a steady simmer. Whisk in red miso paste until completely dissolved.',
          'Cook fresh ramen noodles in boiling unsalted water for exactly 90 seconds until al dente. Drain thoroughly.',
          'Warm soup bowls with hot water, discard water, then add black garlic oil.',
          'Divide hot miso broth between bowls, fold in the cooked noodles gently.',
          'Artfully arrange braised chashu pork, soft-boiled egg halves, bamboo shoots, and green onions on top.',
          'Tuck nori sheets into the side of the bowl and serve steaming hot.',
        ],
      ),
      const Recipe(
        id: 'rec_5',
        title: 'Fluffy Buttermilk Berry Pancakes',
        description:
            'Golden, extra fluffy buttermilk pancakes loaded with wild blueberries and served with whipped butter and warm pure maple syrup.',
        imageUrl:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=900&q=80',
        category: 'Breakfast',
        prepTime: '15 min',
        cookTime: '15 min',
        servings: 4,
        calories: 410,
        difficulty: 'Easy',
        isFavorite: false,
        isFeatured: false,
        isHealthy: false,
        rating: 4.82,
        reviewCount: 94,
        author: 'Baker Chloe',
        ingredients: [
          '2 cups all-purpose flour',
          '2 tbsp cane sugar',
          '2 tsp baking powder & 1/2 tsp baking soda',
          '1/2 tsp fine sea salt',
          '2 cups whole buttermilk',
          '2 large eggs, separated',
          '1/4 cup melted butter',
          '1 cup fresh blueberries',
          'Pure Vermont maple syrup for serving',
        ],
        instructions: [
          'In a large bowl, whisk together flour, sugar, baking powder, baking soda, and salt.',
          'In a separate bowl, whisk buttermilk, egg yolks, and melted butter.',
          'Gently fold wet ingredients into dry ingredients until just combined (leave small lumps).',
          'Whip egg whites to soft peaks and gently fold into the batter for maximum fluffiness.',
          'Heat a cast-iron griddle over medium heat and lightly butter. Pour 1/3 cup batter per pancake, scatter blueberries on top.',
          'Cook until bubbles burst on surface (2-3 min), flip and cook 2 minutes more until golden.',
        ],
      ),
      const Recipe(
        id: 'rec_6',
        title: 'Mediterranean Rainbow Quinoa Bowl',
        description:
            'Vibrant plant-powered bowl with fluffy tri-color quinoa, crispy chickpeas, Kalamata olives, cucumbers, feta, and lemon oregano dressing.',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
        category: 'Healthy',
        prepTime: '15 min',
        cookTime: '10 min',
        servings: 2,
        calories: 340,
        difficulty: 'Easy',
        isFavorite: true,
        isFeatured: false,
        isHealthy: true,
        rating: 4.89,
        reviewCount: 167,
        author: 'Chef Maya Green',
        ingredients: [
          '1.5 cups cooked tri-color quinoa',
          '1 cup roasted seasoned chickpeas',
          '1 English cucumber, diced',
          '1 cup sweet cherry tomatoes, halved',
          '1/3 cup pitted Kalamata olives',
          '1/2 cup crumbled Greek feta cheese',
          '3 tbsp extra virgin olive oil',
          '1.5 tbsp fresh lemon juice',
          '1 tsp dried oregano and fresh mint leaves',
        ],
        instructions: [
          'Prepare grain base by dividing fluffy cooked quinoa into two wide bowls.',
          'Whisk olive oil, lemon juice, dried oregano, salt, and pepper in a small jar.',
          'Arrange chickpeas, diced cucumbers, halved tomatoes, olives, and crumbled feta in colorful sections over quinoa.',
          'Drizzle generously with lemon oregano vinaigrette.',
          'Garnish with fresh mint and cracked black pepper before serving.',
        ],
      ),
      const Recipe(
        id: 'rec_7',
        title: 'Crispy Baja Fish Tacos',
        description:
            'Crispy beer-battered fresh cod fillets in warm corn tortillas, topped with crunchy cilantro-lime slaw and smoky chipotle crema.',
        imageUrl:
            'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=900&q=80',
        category: 'Mexican',
        prepTime: '20 min',
        cookTime: '15 min',
        servings: 3,
        calories: 450,
        difficulty: 'Medium',
        isFavorite: false,
        isFeatured: false,
        isHealthy: false,
        rating: 4.86,
        reviewCount: 112,
        author: 'Chef Carlos',
        ingredients: [
          '1 lb fresh cod or halibut fillets, cut into strips',
          '1 cup flour + 1 tsp cumin + 1 tsp paprika',
          '3/4 cup chilled sparkling water or Mexican beer',
          '6 small street corn tortillas, warmed',
          '2 cups shredded purple & green cabbage',
          '1/3 cup sour cream + 1 tbsp chipotle in adobo',
          'Fresh lime wedges & chopped cilantro',
        ],
        instructions: [
          'Whisk flour, spices, and sparkling liquid to make a smooth light batter.',
          'Toss shredded cabbage with lime juice, cilantro, and sea salt to make the slaw.',
          'Blend sour cream, adobo sauce, and lime juice for the smoky crema.',
          'Dip fish strips in batter and fry in hot oil (375°F) for 3-4 minutes until crunchy and golden.',
          'Assemble tacos: warm tortillas, crunchy fish, fresh slaw, and a drizzle of chipotle crema.',
        ],
      ),
      const Recipe(
        id: 'rec_8',
        title: 'Dark Chocolate Molten Lava Cake',
        description:
            'Intensely rich individual chocolate cakes with an irresistible warm molten chocolate center, dusted with cocoa and powdered sugar.',
        imageUrl:
            'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=900&q=80',
        category: 'Desserts',
        prepTime: '15 min',
        cookTime: '14 min',
        servings: 2,
        calories: 520,
        difficulty: 'Medium',
        isFavorite: false,
        isFeatured: false,
        isHealthy: false,
        rating: 4.96,
        reviewCount: 320,
        author: 'Pastry Chef Pierre',
        ingredients: [
          '100g 70% dark bittersweet chocolate',
          '1/2 cup unsalted European butter',
          '2 whole eggs + 2 egg yolks',
          '1/4 cup granulated cane sugar',
          '2 tbsp all-purpose flour',
          '1/2 tsp vanilla bean extract',
          'Pinch of flaky sea salt',
          'Vanilla bean gelato for serving',
        ],
        instructions: [
          'Butter two ramekins generously and dust with unsweetened cocoa powder.',
          'Melt dark chocolate and butter together in a heatproof bowl over simmering water.',
          'In a separate bowl, whisk eggs, egg yolks, and sugar until pale and slightly thick.',
          'Gently fold melted chocolate into the egg mixture, then fold in flour and salt.',
          'Divide batter into ramekins and bake at 425°F (220°C) for 12-14 minutes until edges are firm but center is soft.',
          'Let stand 1 minute, invert onto plates, and serve immediately with gelato.',
        ],
      ),
      const Recipe(
        id: 'rec_9',
        title: 'Iced Ceremonial Mango Matcha',
        description:
            'Layered refreshing iced drink featuring sweet Alphonso mango puree, silky oat milk, and vibrant Japanese ceremonial grade matcha.',
        imageUrl:
            'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=900&q=80',
        category: 'Beverages',
        prepTime: '8 min',
        cookTime: '2 min',
        servings: 1,
        calories: 180,
        difficulty: 'Easy',
        isFavorite: true,
        isFeatured: false,
        isHealthy: true,
        rating: 4.79,
        reviewCount: 88,
        author: 'Barista Sora',
        ingredients: [
          '1.5 tsp ceremonial grade Uji matcha',
          '1/4 cup hot water (175°F / 80°C)',
          '1/3 cup ripe mango puree',
          '3/4 cup creamy oat milk',
          '1 tsp agave nectar or honey (optional)',
          '1 cup fresh ice cubes',
        ],
        instructions: [
          'Sift matcha powder into a bowl and whisk vigorously in a W motion with hot water until foamy.',
          'Spoon the sweet mango puree into the bottom of a tall glass.',
          'Fill glass completely with fresh ice cubes.',
          'Slowly pour oat milk over the ice to form the middle creamy layer.',
          'Gently float the whisked vibrant green matcha over the top for a gorgeous layered presentation.',
          'Stir well right before drinking!',
        ],
      ),
    ];
  }
}

/// InheritedWidget wrapper for reactive state distribution
class RecipeScope extends InheritedNotifier<RecipeState> {
  const RecipeScope({
    super.key,
    required RecipeState state,
    required super.child,
  }) : super(notifier: state);

  static RecipeState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RecipeScope>();
    assert(scope != null, 'No RecipeScope found in context');
    return scope!.notifier!;
  }

  static RecipeState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<RecipeScope>();
    assert(scope != null, 'No RecipeScope found in context');
    return scope!.notifier!;
  }
}
