import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/theme.dart';
import '../../data/datasources/hadith_repository.dart';
import '../../data/models/hadith_model.dart';
import '../widgets/artistic_card.dart';
import '../widgets/platform_aware_scaffold.dart';
import 'hadith_detail_screen.dart';

class HadithListScreen extends StatelessWidget {
  const HadithListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final all = context.read<IHadithRepository>().getAll();
    return PlatformAwareScaffold(
      title: 'Hadisler',
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: all.length,
        itemBuilder: (context, i) => _HadithTile(
          hadith: all[i],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HadithDetailScreen(initialIndex: i),
            ),
          ),
        ),
      ),
    );
  }
}

class _HadithTile extends StatelessWidget {
  final HadithModel hadith;
  final VoidCallback onTap;

  const _HadithTile({required this.hadith, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: ArtisticCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#${hadith.hadithNo}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    hadith.source,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hadith.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                fontStyle: FontStyle.italic,
                color: AppColors.indigoDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
