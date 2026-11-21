import 'package:flutter/material.dart';

import 'features/pet/presentation/pet_screen.dart';

class MiniPouApp extends StatelessWidget {
  const MiniPouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Pou',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6FD3A8),
        useMaterial3: true,
      ),
      home: const PetScreen(),
    );
  }
}
