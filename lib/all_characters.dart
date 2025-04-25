import 'package:flashhanzi/database/database.dart';
import 'package:flutter/material.dart';

class AllCharacters extends StatefulWidget {
  const AllCharacters({super.key, required this.db});
  final AppDatabase db;
  @override
  State<AllCharacters> createState() => _AllCharactersState();
}

class _AllCharactersState extends State<AllCharacters> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
