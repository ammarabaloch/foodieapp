import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../core/theme/app_colors.dart';
import '../models/category_model.dart';
import '../models/recipe_model.dart';
import '../state/recipe_state.dart';
import '../widgets/recipe_image.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '15 min');
  final _cookTimeController = TextEditingController(text: '20 min');
  final _servingsController = TextEditingController(text: '4');
  final _caloriesController = TextEditingController(text: '380');

  String _selectedCategory = 'Dinner';
  String _selectedDifficulty = 'Medium';
  bool _isHealthy = false;
  bool _isDirty = false;

  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(text: '2 cups fresh organic vegetables'),
    TextEditingController(text: '2 tbsp extra virgin olive oil'),
    TextEditingController(text: '1 tsp sea salt & cracked black pepper'),
  ];

  final List<TextEditingController> _instructionControllers = [
    TextEditingController(text: 'Rinse and chop all fresh ingredients into bite-sized pieces.'),
    TextEditingController(text: 'Heat a pan over medium heat, add olive oil and seasonings.'),
    TextEditingController(text: 'Cook for 15-20 minutes until tender and deeply flavorful. Serve hot.'),
  ];

  static const List<Map<String, String>> _imagePresets = [
    {
      'label': 'Pasta',
      'url':
          'https://images.unsplash.com/photo-1621996346565-e3d5d6281699?auto=format&fit=crop&w=800&q=80',
    },
    {
      'label': 'Salad',
      'url':
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    },
    {
      'label': 'Burger',
      'url':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
    },
    {
      'label': 'Dessert',
      'url':
          'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
    },
    {
      'label': 'Smoothie',
      'url':
          'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _imageUrlController.text = _imagePresets[0]['url']!;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final c in _instructionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (picked == null) return;

      if (!kIsWeb) {
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/recipe_photos');
        if (!imagesDir.existsSync()) {
          imagesDir.createSync(recursive: true);
        }
        final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedFile = await File(picked.path).copy('${imagesDir.path}/$fileName');
        setState(() {
          _imageUrlController.text = savedFile.path;
          _markDirty();
        });
      } else {
        setState(() {
          _imageUrlController.text = picked.path;
          _markDirty();
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Image selected and saved locally!'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load image: $e')),
        );
      }
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
      _markDirty();
    });
  }

  void _removeIngredient(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
        _markDirty();
      });
    }
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
      _markDirty();
    });
  }

  void _removeInstruction(int index) {
    if (_instructionControllers.length > 1) {
      setState(() {
        _instructionControllers[index].dispose();
        _instructionControllers.removeAt(index);
        _markDirty();
      });
    }
  }

  Future<bool> _showDiscardDialog() async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them and leave?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
      return;
    }

    final ingredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient.')),
      );
      return;
    }

    final instructions = _instructionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one instruction step.')),
      );
      return;
    }

    final recipeState = RecipeScope.read(context);

    final newRecipe = Recipe(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? 'Delicious home-cooked recipe prepared with love.'
          : _descController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      category: _selectedCategory,
      prepTime: _prepTimeController.text.trim().isEmpty
          ? '15 min'
          : _prepTimeController.text.trim(),
      cookTime: _cookTimeController.text.trim().isEmpty
          ? '20 min'
          : _cookTimeController.text.trim(),
      servings: int.tryParse(_servingsController.text.trim()) ?? 2,
      calories: int.tryParse(_caloriesController.text.trim()) ?? 350,
      difficulty: _selectedDifficulty,
      ingredients: ingredients,
      instructions: instructions,
      isUserCreated: true,
      isHealthy: _isHealthy,
      rating: 5.0,
      reviewCount: 1,
      author: 'You (Home Chef)',
    );

    await recipeState.addRecipe(newRecipe);

    _isDirty = false;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Recipe "${newRecipe.title}" saved successfully!'),
          backgroundColor: AppColors.healthyGreenDark,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = RecipeCategory.defaultCategories()
        .where((c) => c.id != 'all' && c.id != 'my_food')
        .map((c) => c.name)
        .toList();

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _showDiscardDialog();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              final shouldLeave = await _showDiscardDialog();
              if (shouldLeave && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text('Add New Recipe'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: ElevatedButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Save Recipe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Image Section
                  _buildSectionHeader('Recipe Photography'),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 210,
                      width: double.infinity,
                      color: AppColors.surfaceMuted,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          RecipeImage(
                            imageUrl: _imageUrlController.text,
                            height: 210,
                            width: double.infinity,
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_rounded, size: 18),
                              label: const Text('Change Photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.95),
                                foregroundColor: AppColors.textPrimary,
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_rounded, size: 18),
                          label: const Text('Gallery'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_rounded, size: 18),
                          label: const Text('Camera'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Or select a recipe photo preset:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imagePresets.length,
                      itemBuilder: (context, index) {
                        final preset = _imagePresets[index];
                        final isSelected =
                            _imageUrlController.text == preset['url'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(preset['label']!),
                            selected: isSelected,
                            selectedColor: AppColors.primaryLight,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _imageUrlController.text = preset['url']!;
                                  _markDirty();
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recipe Information
                  _buildSectionHeader('Recipe Information'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    onChanged: (_) => _markDirty(),
                    decoration: const InputDecoration(
                      labelText: 'Recipe Title *',
                      hintText: 'e.g. Grandma\'s Honey Glazed Salmon',
                      prefixIcon: Icon(Icons.restaurant_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Recipe name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    onChanged: (_) => _markDirty(),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Short Description',
                      hintText: 'A brief description of this recipe...',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category & Difficulty Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            prefixIcon: Icon(Icons.category_rounded),
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _selectedCategory = v;
                                _markDirty();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedDifficulty,
                          decoration: const InputDecoration(
                            labelText: 'Difficulty *',
                            prefixIcon: Icon(Icons.tune_rounded),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Easy',
                              child: Text('Easy', style: TextStyle(fontSize: 13)),
                            ),
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text('Medium', style: TextStyle(fontSize: 13)),
                            ),
                            DropdownMenuItem(
                              value: 'Hard',
                              child: Text('Hard', style: TextStyle(fontSize: 13)),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _selectedDifficulty = v;
                                _markDirty();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prepTimeController,
                          onChanged: (_) => _markDirty(),
                          decoration: const InputDecoration(
                            labelText: 'Prep Time',
                            hintText: '15 min',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _cookTimeController,
                          onChanged: (_) => _markDirty(),
                          decoration: const InputDecoration(
                            labelText: 'Cook Time',
                            hintText: '25 min',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _servingsController,
                          onChanged: (_) => _markDirty(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Servings',
                            hintText: '4',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _caloriesController,
                          onChanged: (_) => _markDirty(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Calories',
                            hintText: '400',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Healthy Option Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.healthyGreen,
                    title: const Text(
                      'Mark as Healthy Choice',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Highlights recipe with green nutritional badge',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    value: _isHealthy,
                    onChanged: (val) {
                      setState(() {
                        _isHealthy = val;
                        _markDirty();
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Ingredients Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Ingredients (${_ingredientControllers.length})'),
                      TextButton.icon(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Ingredient'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ingredientControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ingredientControllers[index],
                                onChanged: (_) => _markDirty(),
                                decoration: InputDecoration(
                                  hintText: 'Ingredient ${index + 1} (e.g. 2 tbsp olive oil)',
                                  prefixIcon: const Icon(Icons.egg_alt_outlined, size: 18),
                                ),
                              ),
                            ),
                            if (_ingredientControllers.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: AppColors.danger,
                                ),
                                tooltip: 'Remove ingredient',
                                onPressed: () => _removeIngredient(index),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Instructions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Cooking Instructions (${_instructionControllers.length})'),
                      TextButton.icon(
                        onPressed: _addInstruction,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Step'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _instructionControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 14, right: 8),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _instructionControllers[index],
                                onChanged: (_) => _markDirty(),
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: 'Describe Step ${index + 1}...',
                                ),
                              ),
                            ),
                            if (_instructionControllers.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: AppColors.danger,
                                  ),
                                  tooltip: 'Remove step',
                                  onPressed: () => _removeInstruction(index),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _saveRecipe,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text(
                        'Save Recipe to My Food',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}
