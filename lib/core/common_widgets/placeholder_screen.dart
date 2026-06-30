import 'package:flutter/material.dart';
import '../../theme/stira_tokens.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 48, color: StiraTokens.stiraAmber),
            const SizedBox(height: 16),
            Text(
              '$title',
              style: StiraTokens.displayTitle,
            ),
            const SizedBox(height: 8),
            Text(
              'Currently in development.',
              style: StiraTokens.bodyText,
            ),
          ],
        ),
      ),
    );
  }
}
