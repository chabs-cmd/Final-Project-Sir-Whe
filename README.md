# Filipino Recipe App

A Flutter mobile application for exploring and saving favorite Filipino food recipes.

## Features

- **User Authentication**: Create an account and login
- **Browse Recipes**: Explore a collection of popular Filipino dishes
- **Recipe Details**: View detailed ingredients and cooking instructions
- **Favorites**: Save your favorite recipes to your profile
- **Profile**: View your account information and saved favorites

## Default Recipes Included

1. Chicken Adobo
2. Sinigang na Baboy
3. Lechon Kawali
4. Kare-Kare
5. Pancit Canton
6. Lumpia
7. Halo-Halo
8. Tapsilog
9. Bibingka
10. Puto Bumbong
11. Sapin-Sapin

## Setup

1. Make sure Flutter is installed on your system
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Project Structure

```
lib/
  main.dart                 # App entry point and navigation
  models/                   # Data models (User, Recipe, Favorite)
  services/                 # Business logic (Auth, Storage, Recipe)
  providers/                # State management (AuthProvider, RecipeProvider)
  screens/                  # UI screens
    auth/                   # Login and Register screens
    home_screen.dart        # Featured recipes
    explore_screen.dart     # All recipes
    profile_screen.dart     # User profile and favorites
    recipe_detail_screen.dart # Recipe details
  widgets/                  # Reusable UI components
  data/                     # Default recipe data
  theme/                    # App theme configuration
```

## Dependencies

- `provider`: State management
- `shared_preferences`: Local data storage
- `crypto`: Password hashing
- `intl`: Internationalization support

## Notes

- All data is stored locally on the device
- Default placeholder images are used for recipes (replace in `assets/images/`)
- Passwords are hashed using SHA-256 before storage
