import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/seed_phrase_password_view.dart';

class SeedPhraseWarningView extends StatelessWidget {
  const SeedPhraseWarningView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 40,
        toolbarHeight: 74,
        title: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            "Seed phrase",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 9.0, top: 18.0),
          child: BackButton(
            color: isDarkTheme ? Colors.white : Colors.black,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 20),
            Text(
              'Security Warning',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your seed phrase is the key to your wallet. Keep it safe and private:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildWarningPoint(
              context,
              '• Never share your seed phrase with anyone',
              'Legitimate services will never ask for it',
            ),
            const SizedBox(height: 16),
            _buildWarningPoint(
              context,
              '• Store it securely offline',
              'Write it down and keep it in a safe place',
            ),
            const SizedBox(height: 16),
            _buildWarningPoint(
              context,
              '• Verify your surroundings',
              'Make sure no one can see your screen',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SeedPhrasePasswordView(),
                    ),
                  );
                },
                child: const Text('I Understand, Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningPoint(
      BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
      ],
    );
  }
}
