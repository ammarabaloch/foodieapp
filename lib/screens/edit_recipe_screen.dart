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

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _caloriesController;

  late String _selectedCategory;
  late String _selectedDifficulty;
  late bool _isHealthy;
  bool _isDirty = false;

  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _instructionControllers;

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
      'label': 'Roast',
      'url':
          'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;

    _titleController = TextEditingController(text: r.title);
    _descController = TextEditingController(text: r.description);
    _imageUrlController = TextEditingController(text: r.imageUrl);
    _prepTimeController = TextEditingController(text: r.prepTime);
    _cookTimeController = TextEditingController(text: r.cookTime);
    _servingsController = TextEditingController(text: '${r.servings}');
    _caloriesController = TextEditingController(text: '${r.calories}');

    _selectedCategory = r.category;
    _selectedDifficulty = r.difficulty;
    _isHealthy = r.isHealthy;

    _ingredientControllers = r.ingredients
        .map((ing) => TextEditingController(text: ing))
        .toList();
    if (_ingredientControllers.isEmpty) {
      _ingredientControllers.add(TextEditingController());
    }

    _instructionControllers = r.instructions
        .map((step) => TextEditingController(text: step))
        .toList();
    if (_instructionControllers.isEmpty) {
      _instructionControllers.add(TextEditingController());
    }
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
            content: Text('✓ Image updated!'),
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
          'You have unsaved edits. Are you sure you want to discard them?',
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

  Future<void> _updateRecipe() async {
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

    final updated = widget.recipe.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      category: _selectedCategory,
      prepTime: _prepTimeController.text.trim(),
      cookTime: _cookTimeController.text.trim(),
      servings: int.tryParse(_servingsController.text.trim()) ??
          widget.recipe.servings,
      calories: int.tryParse(_caloriesController.text.trim()) ??
          widget.recipe.calories,
      difficulty: _selectedDifficulty,
      ingredients: ingredients,
      instructions: instructions,
      isHealthy: _isHealthy,
    );

    await recipeState.updateRecipe(updated);

    _isDirty = false;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Recipe "${updated.title}" updated successfully!'),
          backgroundColor: AppColors.healthyGreenDark,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Recipe?'),
          content: Text(
            'Are you sure you want to permanently delete "${widget.recipe.title}"? This cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final state = RecipeScope.read(context);
                await state.deleteRecipe(widget.recipe.id);
                _isDirty = false;
                if (ctx.mounted) Navigator.pop(ctx); // Close dialog
                if (mounted) {
                  Navigator.pop(context); // Pop edit screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Recipe "${widget.recipe.title}" deleted.'),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = RecipeCategory.defaultCategories()
        .where((c) => c.id != 'all' && c.id != 'my_food')
        .map((c) => c.name)
        .toList();

    if (!categories.contains(_selectedCategory)) {
      categories.add(_selectedCategory);
    }

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
          title: const Text('Edit Recipe'),
          actions: [
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.danger,
              tooltip: 'Delete Recipe',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: ElevatedButton.icon(
                onPressed: _updateRecipe,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Update'),
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
                    'Or choose a preset:',
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
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category & Difficulty
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
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Healthy Switch
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
                                  hintText: 'Ingredient ${index + 1}',
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

                  // Update and Delete Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _updateRecipe,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text(
                              'Update Recipe',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _confirmDelete,
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                            label: const Text(
                              'Delete',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.dangerLight, width: 1.5),
                              backgroundColor: AppColors.dangerLight.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    ],
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
