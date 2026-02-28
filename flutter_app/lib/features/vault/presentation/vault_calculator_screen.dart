import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';

class VaultCalculatorScreen extends HookConsumerWidget {
  const VaultCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Secret pin to enter the vault. In production, this would be hashed and stored.
    const secretPin = '008989='; 
    var currentInput = ref.watch(_calculatorStateProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Text(
                  currentInput,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            _buildKeypad(ref, secretPin, context),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(WidgetRef ref, String secretPin, BuildContext context) {
    // Dummy keypad generation for the disguise
    final buttons = [
      '7', '8', '9', '÷',
      '4', '5', '6', '×',
      '1', '2', '3', '-',
      'C', '0', '=', '+',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        return _CalculatorButton(
          label: buttons[index],
          onTap: () {
            final notifier = ref.read(_calculatorStateProvider.notifier);
            notifier.state += buttons[index];
            
            if (buttons[index] == 'C') {
              notifier.state = '';
            }

            if (notifier.state == secretPin) {
              notifier.state = '';
              // Transition to Secret Vault
              Navigator.of(context).pushReplacementNamed('/hidden-vault');
            } else if (notifier.state == '999111=') {
                 // Panic Pin: Wipe database immediately
                 // locator<SecurityService>().triggerPanicWipe();
                 notifier.state = 'ERR';
            }
          },
        );
      },
    );
  }
}

final _calculatorStateProvider = StateProvider<String>((ref) => '');

class _CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CalculatorButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: _isOperator(label) ? Colors.orange : Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  bool _isOperator(String label) {
    return ['÷', '×', '-', '+', '='].contains(label);
  }
}
