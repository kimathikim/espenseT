import 'package:flutter/material.dart';
import 'package:expensetracker/src/shared/theme.dart';

class LinkAccountScreen extends StatefulWidget {
  const LinkAccountScreen({super.key});

  @override
  _LinkAccountScreenState createState() => _LinkAccountScreenState();
}

class _LinkAccountScreenState extends State<LinkAccountScreen> {
  bool _loading = false;

  Future<void> _linkAccount() async {
    setState(() {
      _loading = true;
    });
      // TODO: Implement M-Pesa account linking logic
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('M-Pesa account linked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link M-Pesa Account'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AppTheme.buildGlassmorphicCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Link Your M-Pesa Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.whiteText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'To securely import your transactions, we will redirect you to Safaricom to grant permission.\n\nWe will never ask for your M-Pesa PIN or other sensitive credentials.',
                    style: TextStyle(color: AppColors.whiteText, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _linkAccount,
                    icon: const Icon(Icons.link),
                    label: Text(_loading ? 'Redirecting...' : 'Continue to Safaricom'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
