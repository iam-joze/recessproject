// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:housingapp/utils/app_styles.dart'; // Import your app styles

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;        // Renamed from backgroundColor for clarity but functions the same
  final Color? textColor;
  final Widget? leadingIcon; // NEW: Optional widget for a leading icon/logo

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.leadingIcon, // NEW: Include in constructor
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // Use provided color, fallback to AppStyles.primaryColor, then to theme primary
        backgroundColor: color ?? AppStyles.primaryColor,
        foregroundColor: textColor ?? Colors.white, // Text/icon color
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600, // Make text a bit bolder
        ),
        elevation: 2, // Add a subtle shadow
        minimumSize: const Size(double.infinity, 50), // Ensure full width and a minimum height
      ),
      child: Row( // Use a Row to align icon and text
        mainAxisAlignment: MainAxisAlignment.center, // Center contents horizontally
        mainAxisSize: MainAxisSize.min, // Wrap content tightly
        children: [
          if (leadingIcon != null) ...[ // If an icon is provided
            leadingIcon!,
            const SizedBox(width: 10), // Space between icon and text
          ],
          Flexible( // Allows text to wrap or truncate if too long with icon
            child: Text(
              text,
              // The textColor from styleFrom already applies, but can override here if needed
            ),
          ),
        ],
      ),
    );
  }
}