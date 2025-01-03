import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final void Function() onPressed;
  final bool? isAnalyze;

  const SubmitButton({
    super.key,
    required this.onPressed,
    this.isAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        isAnalyze == true ? 'Analyze Data' : 'Submit',
      ),
    );
  }
}
