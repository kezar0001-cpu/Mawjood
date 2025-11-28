# Mawjood Theme Guide (Flutter)

## Theme Configuration
```dart
ThemeData mawjoodTheme = ThemeData(
  primaryColor: Color(0xFF00897B),
  colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00897B)),
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Cairo',
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF00897B),
    elevation: 0,
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFF00897B), width: 1.8),
    ),
  ),
);
```

## Typography
- Headings: Weight 700  
- Section titles: Weight 600  
- Body: Weight 400  
- Captions: Weight 300  

## Shape & Spacing
- Border radius: 16 for cards and buttons  
- Padding: 12–16px standard  
- Use the 8px spacing system throughout  

## Components
- Buttons: Teal primary, white text  
- Cards: Soft shadow, white background  
- Inputs: Rounded edges, teal focus border  
