import 'package:flutter_riverpod/flutter_riverpod.dart';

final languageProvider = StateProvider<String>((ref) => 'en');
final fontSizeMultiplierProvider = StateProvider<double>((ref) => 1.0);
