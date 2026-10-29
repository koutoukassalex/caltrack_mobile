import '../models/food_item.dart';

class FoodDatabase {
  static const List<FoodItem> foods = [
    // ===================== PROTEINS =====================
    FoodItem(id: "chk_breast", name: "Chicken Breast (cooked)", cal: 165, protein: 31, carbs: 0, fat: 3.6, serving: "100g", category: "protein", emoji: "🍗"),
    FoodItem(id: "chk_thigh", name: "Chicken Thigh (cooked)", cal: 209, protein: 26, carbs: 0, fat: 11, serving: "100g", category: "protein", emoji: "🍗"),
    FoodItem(id: "beef_lean", name: "Ground Beef (lean, cooked)", cal: 215, protein: 26, carbs: 0, fat: 12, serving: "100g", category: "protein", emoji: "🥩"),
    FoodItem(id: "beef_steak", name: "Beef Steak (grilled)", cal: 271, protein: 26, carbs: 0, fat: 18, serving: "100g", category: "protein", emoji: "🥩"),
    FoodItem(id: "salmon", name: "Salmon (cooked)", cal: 208, protein: 20, carbs: 0, fat: 13, serving: "100g", category: "protein", emoji: "🐟"),
    FoodItem(id: "tuna", name: "Tuna (canned in water)", cal: 116, protein: 26, carbs: 0, fat: 1, serving: "100g", category: "protein", emoji: "🐟"),
    FoodItem(id: "shrimp", name: "Shrimp (cooked)", cal: 99, protein: 24, carbs: 0.2, fat: 0.3, serving: "100g", category: "protein", emoji: "🦐"),
    FoodItem(id: "tilapia", name: "Tilapia (cooked)", cal: 128, protein: 26, carbs: 0, fat: 3, serving: "100g", category: "protein", emoji: "🐟"),
    FoodItem(id: "cod", name: "Cod (cooked)", cal: 105, protein: 23, carbs: 0, fat: 0.9, serving: "100g", category: "protein", emoji: "🐟"),
    FoodItem(id: "turkey", name: "Turkey Breast (cooked)", cal: 135, protein: 30, carbs: 0, fat: 1, serving: "100g", category: "protein", emoji: "🦃"),
    FoodItem(id: "pork_tender", name: "Pork Tenderloin (cooked)", cal: 166, protein: 29, carbs: 0, fat: 4.8, serving: "100g", category: "protein", emoji: "🥩"),
    FoodItem(id: "eggs_whole", name: "Eggs (whole, large)", cal: 143, protein: 13, carbs: 0.7, fat: 10, serving: "2 eggs (100g)", category: "protein", emoji: "🥚"),
    FoodItem(id: "egg_whites", name: "Egg Whites", cal: 52, protein: 11, carbs: 0.7, fat: 0.2, serving: "100g", category: "protein", emoji: "🥚"),
    FoodItem(id: "cottage_cheese", name: "Cottage Cheese (low-fat)", cal: 72, protein: 12, carbs: 2.7, fat: 1, serving: "100g", category: "dairy", emoji: "🫙"),
    FoodItem(id: "greek_yogurt", name: "Greek Yogurt (plain 0%)", cal: 59, protein: 10, carbs: 3.6, fat: 0.4, serving: "100g", category: "dairy", emoji: "🥛"),
    FoodItem(id: "tofu", name: "Tofu (firm)", cal: 83, protein: 9, carbs: 2, fat: 5, serving: "100g", category: "protein", emoji: "🧊"),
    FoodItem(id: "tempeh", name: "Tempeh", cal: 193, protein: 19, carbs: 9, fat: 11, serving: "100g", category: "protein", emoji: "🧊"),
    FoodItem(id: "edamame", name: "Edamame", cal: 122, protein: 11, carbs: 10, fat: 5, serving: "100g", category: "protein", emoji: "🫘"),
    FoodItem(id: "lentils", name: "Lentils (cooked)", cal: 116, protein: 9, carbs: 20, fat: 0.4, serving: "100g", category: "legumes", emoji: "🫘"),
    FoodItem(id: "black_beans", name: "Black Beans (cooked)", cal: 132, protein: 9, carbs: 24, fat: 0.5, serving: "100g", category: "legumes", emoji: "🫘"),
    FoodItem(id: "chickpeas", name: "Chickpeas (cooked)", cal: 164, protein: 9, carbs: 27, fat: 2.6, serving: "100g", category: "legumes", emoji: "🫘"),
    FoodItem(id: "whey_powder", name: "Whey Protein Powder", cal: 400, protein: 80, carbs: 8, fat: 5, serving: "30g scoop", category: "supplement", emoji: "💪"),

    // ===================== DAIRY =====================
    FoodItem(id: "whole_milk", name: "Whole Milk", cal: 61, protein: 3.2, carbs: 4.8, fat: 3.3, serving: "100ml", category: "dairy", emoji: "🥛"),
    FoodItem(id: "skim_milk", name: "Skim Milk", cal: 35, protein: 3.4, carbs: 4.9, fat: 0.1, serving: "100ml", category: "dairy", emoji: "🥛"),
    FoodItem(id: "cheddar", name: "Cheddar Cheese", cal: 403, protein: 25, carbs: 1.3, fat: 33, serving: "100g", category: "dairy", emoji: "🧀"),
    FoodItem(id: "mozzarella", name: "Mozzarella Cheese", cal: 280, protein: 28, carbs: 2.2, fat: 17, serving: "100g", category: "dairy", emoji: "🧀"),
    FoodItem(id: "feta", name: "Feta Cheese", cal: 264, protein: 14, carbs: 4, fat: 21, serving: "100g", category: "dairy", emoji: "🧀"),
    FoodItem(id: "butter", name: "Butter", cal: 717, protein: 0.9, carbs: 0.1, fat: 81, serving: "100g", category: "fat", emoji: "🧈"),
    FoodItem(id: "heavy_cream", name: "Heavy Cream", cal: 340, protein: 2.8, carbs: 2.8, fat: 36, serving: "100ml", category: "dairy", emoji: "🥛"),

    // ===================== GRAINS & CARBS =====================
    FoodItem(id: "white_rice", name: "White Rice (cooked)", cal: 130, protein: 2.7, carbs: 28, fat: 0.3, serving: "100g", category: "grain", emoji: "🍚"),
    FoodItem(id: "brown_rice", name: "Brown Rice (cooked)", cal: 123, protein: 2.7, carbs: 26, fat: 1, serving: "100g", category: "grain", emoji: "🍚"),
    FoodItem(id: "basmati_rice", name: "Basmati Rice (cooked)", cal: 121, protein: 3.5, carbs: 25, fat: 0.4, serving: "100g", category: "grain", emoji: "🍚"),
    FoodItem(id: "oats_dry", name: "Oats (dry)", cal: 389, protein: 17, carbs: 66, fat: 7, serving: "100g", category: "grain", emoji: "🌾"),
    FoodItem(id: "oatmeal_cooked", name: "Oatmeal (cooked)", cal: 71, protein: 2.5, carbs: 12, fat: 1.4, serving: "100g", category: "grain", emoji: "🥣"),
    FoodItem(id: "quinoa", name: "Quinoa (cooked)", cal: 120, protein: 4.4, carbs: 21, fat: 1.9, serving: "100g", category: "grain", emoji: "🌾"),
    FoodItem(id: "white_bread", name: "White Bread", cal: 265, protein: 9, carbs: 49, fat: 3.2, serving: "100g (≈2 slices)", category: "grain", emoji: "🍞"),
    FoodItem(id: "whole_wheat_bread", name: "Whole Wheat Bread", cal: 247, protein: 13, carbs: 41, fat: 4.2, serving: "100g (≈2 slices)", category: "grain", emoji: "🍞"),
    FoodItem(id: "sourdough", name: "Sourdough Bread", cal: 270, protein: 9, carbs: 52, fat: 1.7, serving: "100g", category: "grain", emoji: "🥖"),
    FoodItem(id: "spaghetti", name: "Spaghetti (cooked)", cal: 158, protein: 5.8, carbs: 31, fat: 0.9, serving: "100g", category: "grain", emoji: "🍝"),
    FoodItem(id: "whole_wheat_pasta", name: "Whole Wheat Pasta (cooked)", cal: 149, protein: 5.3, carbs: 29, fat: 1.1, serving: "100g", category: "grain", emoji: "🍝"),
    FoodItem(id: "tortilla_flour", name: "Tortilla (flour, 8\")", cal: 218, protein: 5.7, carbs: 36, fat: 5.6, serving: "1 tortilla (45g)", category: "grain", emoji: "🫓"),
    FoodItem(id: "corn_tortilla", name: "Corn Tortilla", cal: 218, protein: 5.7, carbs: 46, fat: 2.5, serving: "100g", category: "grain", emoji: "🌽"),
    FoodItem(id: "sweet_potato", name: "Sweet Potato (cooked)", cal: 90, protein: 2, carbs: 21, fat: 0.1, serving: "100g", category: "vegetable", emoji: "🍠"),
    FoodItem(id: "potato", name: "Regular Potato (cooked)", cal: 87, protein: 1.9, carbs: 20, fat: 0.1, serving: "100g", category: "vegetable", emoji: "🥔"),

    // ===================== VEGETABLES =====================
    FoodItem(id: "broccoli", name: "Broccoli (cooked)", cal: 35, protein: 2.4, carbs: 7.2, fat: 0.4, serving: "100g", category: "vegetable", emoji: "🥦"),
    FoodItem(id: "spinach", name: "Spinach (raw)", cal: 23, protein: 2.9, carbs: 3.6, fat: 0.4, serving: "100g", category: "vegetable", emoji: "🥬"),
    FoodItem(id: "carrots", name: "Carrots (raw)", cal: 41, protein: 0.9, carbs: 9.6, fat: 0.2, serving: "100g", category: "vegetable", emoji: "🥕"),
    FoodItem(id: "bell_pepper", name: "Bell Pepper (red)", cal: 31, protein: 1, carbs: 6, fat: 0.3, serving: "100g", category: "vegetable", emoji: "🫑"),
    FoodItem(id: "cucumber", name: "Cucumber", cal: 15, protein: 0.7, carbs: 3.6, fat: 0.1, serving: "100g", category: "vegetable", emoji: "🥒"),
    FoodItem(id: "avocado", name: "Avocado", cal: 160, protein: 2, carbs: 8.5, fat: 14.7, serving: "100g (≈half)", category: "fruit", emoji: "🥑"),
    FoodItem(id: "tomato", name: "Tomato", cal: 18, protein: 0.9, carbs: 3.9, fat: 0.2, serving: "100g", category: "vegetable", emoji: "🍅"),

    // ===================== FRUITS =====================
    FoodItem(id: "banana", name: "Banana", cal: 89, protein: 1.1, carbs: 23, fat: 0.3, serving: "1 medium (118g)", category: "fruit", emoji: "🍌"),
    FoodItem(id: "apple", name: "Apple", cal: 52, protein: 0.3, carbs: 14, fat: 0.2, serving: "1 medium (182g)", category: "fruit", emoji: "🍎"),
    FoodItem(id: "strawberries", name: "Strawberries", cal: 32, protein: 0.7, carbs: 7.7, fat: 0.3, serving: "100g", category: "fruit", emoji: "🍓"),
    FoodItem(id: "blueberries", name: "Blueberries", cal: 57, protein: 0.7, carbs: 14, fat: 0.3, serving: "100g", category: "fruit", emoji: "🫐"),
    FoodItem(id: "orange", name: "Orange", cal: 47, protein: 0.9, carbs: 12, fat: 0.1, serving: "1 medium (131g)", category: "fruit", emoji: "🍊"),
    FoodItem(id: "mango", name: "Mango", cal: 60, protein: 0.8, carbs: 15, fat: 0.4, serving: "100g", category: "fruit", emoji: "🥭"),
    FoodItem(id: "watermelon", name: "Watermelon", cal: 30, protein: 0.6, carbs: 7.6, fat: 0.2, serving: "100g", category: "fruit", emoji: "🍉"),

    // ===================== NUTS & HEALTHY FATS =====================
    FoodItem(id: "almonds", name: "Almonds", cal: 579, protein: 21, carbs: 22, fat: 49, serving: "100g (handful≈30g)", category: "nuts", emoji: "🥜"),
    FoodItem(id: "walnuts", name: "Walnuts", cal: 654, protein: 15, carbs: 14, fat: 65, serving: "100g", category: "nuts", emoji: "🥜"),
    FoodItem(id: "peanut_butter", name: "Peanut Butter (natural)", cal: 588, protein: 25, carbs: 20, fat: 50, serving: "2 tbsp (32g)", category: "nuts", emoji: "🥜"),
    FoodItem(id: "olive_oil", name: "Olive Oil", cal: 884, protein: 0, carbs: 0, fat: 100, serving: "1 tbsp (14g)", category: "fat", emoji: "🫒"),

    // ===================== COMPLETE MEALS & DISHES =====================
    FoodItem(id: "chk_stir_fry", name: "Chicken Stir Fry (with rice)", cal: 145, protein: 12, carbs: 18, fat: 3.5, serving: "100g", category: "meal", emoji: "🍱"),
    FoodItem(id: "beef_broccoli", name: "Beef & Broccoli (with rice)", cal: 155, protein: 11, carbs: 19, fat: 4.2, serving: "100g", category: "meal", emoji: "🥦"),
    FoodItem(id: "salmon_quinoa", name: "Grilled Salmon w/ Quinoa & Asparagus", cal: 168, protein: 14, carbs: 12, fat: 7.5, serving: "100g", category: "meal", emoji: "🐟"),
    FoodItem(id: "pesto_chk_pasta", name: "Pesto Pasta with Grilled Chicken", cal: 210, protein: 13, carbs: 24, fat: 8, serving: "100g", category: "meal", emoji: "🍝"),
    FoodItem(id: "turkey_chili", name: "Hearty Turkey Chili", cal: 110, protein: 12, carbs: 9, fat: 3, serving: "100g", category: "meal", emoji: "🥣"),
    FoodItem(id: "greek_gyro", name: "Greek Gyro (Lamb/Beef, full)", cal: 235, protein: 11, carbs: 22, fat: 12, serving: "100g", category: "meal", emoji: "🥙"),
    FoodItem(id: "poke_bowl", name: "Ahi Tuna Poke Bowl", cal: 140, protein: 10, carbs: 18, fat: 3.5, serving: "100g", category: "meal", emoji: "🥗"),
    FoodItem(id: "shakshuka", name: "Shakshuka with Pita", cal: 135, protein: 6, carbs: 14, fat: 6, serving: "100g", category: "meal", emoji: "🍳"),
    FoodItem(id: "cobb_salad", name: "Classic Cobb Salad", cal: 155, protein: 11, carbs: 4, fat: 11, serving: "100g", category: "meal", emoji: "🥗"),
    FoodItem(id: "chk_caesar_wrap", name: "Chicken Caesar Wrap", cal: 215, protein: 12, carbs: 19, fat: 10, serving: "100g", category: "meal", emoji: "🌯"),
    FoodItem(id: "butter_chicken", name: "Butter Chicken with Basmati", cal: 185, protein: 10, carbs: 21, fat: 7, serving: "100g", category: "meal", emoji: "🍛"),
    FoodItem(id: "burger", name: "Beef Burger (homemade)", cal: 295, protein: 17, carbs: 24, fat: 13, serving: "1 burger (148g)", category: "american", emoji: "🍔"),
    FoodItem(id: "pizza_margherita", name: "Pizza Margherita", cal: 266, protein: 11, carbs: 33, fat: 10, serving: "1 slice (107g)", category: "italian", emoji: "🍕"),

    // ===================== DRINKS =====================
    FoodItem(id: "coffee_black", name: "Coffee (black)", cal: 2, protein: 0.3, carbs: 0, fat: 0, serving: "1 cup (240ml)", category: "drink", emoji: "☕"),
    FoodItem(id: "latte", name: "Latte (whole milk)", cal: 123, protein: 8, carbs: 12, fat: 5, serving: "1 medium (340ml)", category: "drink", emoji: "☕"),
    FoodItem(id: "orange_juice", name: "Orange Juice (fresh)", cal: 45, protein: 0.7, carbs: 10, fat: 0.2, serving: "100ml", category: "drink", emoji: "🍊"),
    FoodItem(id: "protein_shake", name: "Protein Shake (ready-made)", cal: 160, protein: 30, carbs: 5, fat: 3, serving: "330ml", category: "drink", emoji: "🥛"),
  ];

  static List<FoodItem> search(String query) {
    if (query.trim().isEmpty) return foods;
    final q = query.toLowerCase().trim();
    return foods.where((item) {
      return item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
    }).toList();
  }

  static List<FoodItem> getByCategory(String category) {
    if (category.toLowerCase() == 'all') return foods;
    return foods.where((f) => f.category.toLowerCase() == category.toLowerCase()).toList();
  }

  static List<String> getCategories() {
    final Set<String> categories = {'all'};
    for (final f in foods) {
      categories.add(f.category);
    }
    return categories.toList();
  }
}
