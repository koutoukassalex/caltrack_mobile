import 'package:flutter/material.dart';
import '../../models/food_item.dart';
import '../../models/food_entry.dart';
import '../../data/food_database.dart';

class AddFoodModal extends StatefulWidget {
  final MealType initialMeal;
  final Function(FoodEntry) onAddFood;

  const AddFoodModal({
    super.key,
    required this.initialMeal,
    required this.onAddFood,
  });

  @override
  State<AddFoodModal> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends State<AddFoodModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  List<FoodItem> _filteredFoods = FoodDatabase.foods;

  // Selected item for portion scaling
  FoodItem? _selectedItem;
  double _portionGrams = 100.0;
  String _unit = 'g'; // 'g' or 'oz'
  late MealType _currentMeal;

  // Manual Form Controllers
  final _manualNameController = TextEditingController();
  final _manualCaloriesController = TextEditingController();
  final _manualProteinController = TextEditingController();
  final _manualCarbsController = TextEditingController();
  final _manualFatController = TextEditingController();
  final _manualGramsController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _currentMeal = widget.initialMeal;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _manualNameController.dispose();
    _manualCaloriesController.dispose();
    _manualProteinController.dispose();
    _manualCarbsController.dispose();
    _manualFatController.dispose();
    _manualGramsController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      var results = FoodDatabase.search(query);
      if (_selectedCategory != 'all') {
        results = results
            .where((f) =>
                f.category.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();
      }
      _filteredFoods = results;
    });
  }

  void _selectFoodItem(FoodItem item) {
    setState(() {
      _selectedItem = item;
      _portionGrams = 100.0;
      _unit = 'g';
    });
  }

  void _logSelectedItem() {
    if (_selectedItem == null) return;
    final scaled = _selectedItem!.scaleToGrams(_portionGrams);

    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selectedItem!.name,
      mealType: _currentMeal,
      calories: scaled['calories']!,
      protein: scaled['protein']!,
      carbs: scaled['carbs']!,
      fat: scaled['fat']!,
      grams: _portionGrams,
      emoji: _selectedItem!.emoji,
    );

    widget.onAddFood(entry);
    Navigator.pop(context);
  }

  void _logManualFood() {
    final name = _manualNameController.text.trim();
    final calories = double.tryParse(_manualCaloriesController.text) ?? 0.0;
    final protein = double.tryParse(_manualProteinController.text) ?? 0.0;
    final carbs = double.tryParse(_manualCarbsController.text) ?? 0.0;
    final fat = double.tryParse(_manualFatController.text) ?? 0.0;
    final grams = double.tryParse(_manualGramsController.text) ?? 100.0;

    if (name.isEmpty) return;

    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      mealType: _currentMeal,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      grams: grams,
      emoji: '🍽️',
    );

    widget.onAddFood(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with Meal Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log Food',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                DropdownButton<MealType>(
                  value: _currentMeal,
                  underline: const SizedBox(),
                  dropdownColor: theme.cardColor,
                  items: MealType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text('${type.emoji} ${type.displayName}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _currentMeal = val);
                  },
                ),
              ],
            ),
          ),

          // Tab Bar: Search vs Manual
          TabBar(
            controller: _tabController,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodySmall?.color,
            tabs: const [
              Tab(text: 'Search Food Database'),
              Tab(text: 'Manual Entry'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(theme),
                _buildManualTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(ThemeData theme) {
    final categories = FoodDatabase.getCategories();

    return Column(
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search 200+ foods, fruits, meals...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Categories Chips
        SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, idx) {
              final cat = categories[idx];
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(
                  cat[0].toUpperCase() + cat.substring(1),
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                selected: isSelected,
                selectedColor: theme.colorScheme.primary,
                onSelected: (val) {
                  setState(() {
                    _selectedCategory = cat;
                    _onSearch(_searchController.text);
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Portion Scaler Banner if item is selected
        if (_selectedItem != null) _buildPortionScaler(theme),

        // Results List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filteredFoods.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final item = _filteredFoods[idx];
              final isSelected = _selectedItem?.id == item.id;

              return ListTile(
                dense: true,
                selected: isSelected,
                selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Text(item.emoji, style: const TextStyle(fontSize: 22)),
                title: Text(
                  item.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Per ${item.serving} • P:${item.protein}g C:${item.carbs}g F:${item.fat}g',
                  style: TextStyle(
                      fontSize: 11, color: theme.textTheme.bodySmall?.color),
                ),
                trailing: Text(
                  '${item.cal.round()} kcal',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                onTap: () => _selectFoodItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPortionScaler(ThemeData theme) {
    final scaled = _selectedItem!.scaleToGrams(_portionGrams);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedItem!.emoji} ${_selectedItem!.name}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _selectedItem = null),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Slider(
                  value: _portionGrams.clamp(10.0, 500.0),
                  min: 10.0,
                  max: 500.0,
                  divisions: 49,
                  label: '${_portionGrams.round()}g',
                  onChanged: (val) {
                    setState(() => _portionGrams = val);
                  },
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  '${_portionGrams.round()} g',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Macro breakdown chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _macroChip('${scaled['calories']!.round()} kcal', Colors.orange),
              _macroChip('P: ${scaled['protein']!.toStringAsFixed(1)}g', Colors.red),
              _macroChip('C: ${scaled['carbs']!.toStringAsFixed(1)}g', Colors.blue),
              _macroChip('F: ${scaled['fat']!.toStringAsFixed(1)}g', Colors.amber),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logSelectedItem,
              icon: const Icon(Icons.check, size: 18),
              label: Text('Log to ${_currentMeal.displayName}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildManualTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _manualNameController,
            decoration: const InputDecoration(
              labelText: 'Food Name',
              hintText: 'e.g. Grandma\'s Apple Crumble',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualCaloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories (kcal)',
                    hintText: '350',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _manualGramsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Serving (g)',
                    hintText: '100',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualProteinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Protein (g)',
                    hintText: '25',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _manualCarbsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Carbs (g)',
                    hintText: '40',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _manualFatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fat (g)',
                    hintText: '10',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logManualFood,
              icon: const Icon(Icons.add, size: 20),
              label: Text('Add Custom Food to ${_currentMeal.displayName}'),
            ),
          ),
        ],
      ),
    );
  }
}
