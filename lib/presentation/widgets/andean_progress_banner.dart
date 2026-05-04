import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../providers/practice_notifier.dart';
import 'andean_avatar_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AndeanProgressBanner — Banner superior de progreso con avatar de llamita
// ─────────────────────────────────────────────────────────────────────────────

class AndeanProgressBanner extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;
  final LlamaMood mood;
  final int coins;

  const AndeanProgressBanner({
    super.key,
    required this.completedSteps,
    required this.totalSteps,
    required this.mood,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🏮 Avatar Llamita
          SizedBox(
            width: 70,
            height: 82,
            child: FittedBox(
              fit: BoxFit.contain,
              child: AndeanAvatarWidget(
                currentStepIndex: completedSteps,
                totalSteps: totalSteps,
                mood: mood,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 📈 Progreso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Nuestra Llamita',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreenDk,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Paso $completedSteps de $totalSteps',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _LocalProgressBar(
                  value: totalSteps > 0 ? completedSteps / totalSteps : 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalProgressBar extends StatelessWidget {
  final double value;
  const _LocalProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
        backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
      ),
    );
  }
}
