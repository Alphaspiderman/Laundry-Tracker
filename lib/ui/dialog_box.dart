import 'package:clothes_tracker/utils/db.dart';
import 'package:flutter/material.dart';

class Dialog extends StatelessWidget {
  const Dialog({
    super.key,
    required this.dbHelper,
    required this.title,
    required this.subtitle,
    required this.firstButtonText,
    required this.secondButtonText,
    required this.onFirstButton,
    required this.onSecondButton,
  });

  final DatabaseHelper dbHelper;
  final String title;
  final String subtitle;
  final String firstButtonText;
  final String secondButtonText;
  final Function() onFirstButton;
  final Function() onSecondButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Material(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 30,
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 26),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await onFirstButton();
                          },
                          child: Text(
                            firstButtonText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await onSecondButton();
                          },
                          child: Text(
                            secondButtonText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
