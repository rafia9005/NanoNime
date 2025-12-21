import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// A simple loading grid used as a placeholder while content is being fetched.
///
/// Usage:
/// ```dart
/// LoadingGrid(maxCrossAxisExtent: 180, itemCount: 6);
/// ```
class LoadingGrid extends StatelessWidget {
  final double maxCrossAxisExtent;
  final int itemCount;
  final double childAspectRatio;

  const LoadingGrid({
    Key? key,
    this.maxCrossAxisExtent = 180,
    this.itemCount = 6,
    this.childAspectRatio = 0.60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: [
                // Poster placeholder
                Expanded(
                  flex: 7,
                  child: Container(
                    color: AppColors.background.withOpacity(0.06),
                  ),
                ),
                // Text lines placeholder
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 8,
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
