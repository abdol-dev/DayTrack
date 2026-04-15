import 'package:flutter/material.dart';

class StatusEmojiPicker extends StatelessWidget {
  final int value; // 0–3
  final ValueChanged<int> onChanged;

  const StatusEmojiPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const emojis = ["😢", "🥺", "😇", "🥳"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(emojis.length, (index) {
        return GestureDetector(
          onTap: () => onChanged(index),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: value == index ? 1.35 : 1.0,
            child: Text(
              emojis[index],
              style: TextStyle(
                fontSize: value == index ? 34 : 28,
                color: value == index ? Colors.orange : Colors.grey[600],
              ),
            ),
          ),
        );
      }),
    );
  }
}
