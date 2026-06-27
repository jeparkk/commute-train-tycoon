import 'package:flutter/material.dart';

class BottomActions extends StatelessWidget {
  const BottomActions({
    required this.toast,
    required this.onCabin,
    required this.onMove,
    required this.onShop,
    super.key,
  });

  final String? toast;
  final VoidCallback onCabin;
  final VoidCallback onMove;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: toast == null
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey(toast),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF263B39),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        toast!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5D8C3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavButton(
                  icon: Icons.home_rounded,
                  label: '객실',
                  selected: true,
                  onPressed: onCabin,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _NavButton(
                  icon: Icons.map_rounded,
                  label: '이동',
                  onPressed: onMove,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _NavButton(
                  icon: Icons.storefront_rounded,
                  label: '상점',
                  onPressed: onShop,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1),
      style: FilledButton.styleFrom(
        backgroundColor: selected ? const Color(0xFFDFF2EF) : Colors.white,
        foregroundColor: const Color(0xFF26403C),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
