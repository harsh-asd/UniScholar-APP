import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class GoiTopBar extends ConsumerWidget {
  const GoiTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: GOI info
          Row(
            children: [
              Text(
                currentLang == 'hi' ? 'भारत सरकार' : 'GOVERNMENT OF INDIA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                currentLang == 'hi' ? 'जनजातीय कार्य मंत्रालय' : 'MINISTRY OF TRIBAL AFFAIRS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          
          // Right side: Accessibility Controls
          Row(
            children: [
              _buildTextButton(ref, 'A-', 0.9),
              const SizedBox(width: 8),
              _buildTextButton(ref, 'A', 1.0),
              const SizedBox(width: 8),
              _buildTextButton(ref, 'A+', 1.15, isBold: true),
              const SizedBox(width: 16),
              
              // Language Dropdown Mock
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentLang,
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      ref.read(languageProvider.notifier).state = newValue;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Accessibility Icon
              const Icon(Icons.accessibility_new, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextButton(WidgetRef ref, String text, double multiplier, {bool isBold = false}) {
    return InkWell(
      onTap: () {
        ref.read(fontSizeMultiplierProvider.notifier).state = multiplier;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
