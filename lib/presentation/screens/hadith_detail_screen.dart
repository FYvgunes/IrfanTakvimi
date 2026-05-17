import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/theme.dart';
import '../../data/datasources/hadith_repository.dart';
import '../../data/models/hadith_model.dart';
import '../widgets/artistic_card.dart';
import '../widgets/platform_aware_button.dart';
import '../widgets/platform_aware_scaffold.dart';

class HadithDetailScreen extends StatefulWidget {
  final int initialIndex;
  const HadithDetailScreen({super.key, required this.initialIndex});

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final all = context.read<IHadithRepository>().getAll();
    final hadith = all[_index];
    final hasPrev = _index > 0;
    final hasNext = _index < all.length - 1;

    return PlatformAwareScaffold(
      title: 'Hadis #${hadith.hadithNo}',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _BodyCard(hadith: hadith),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: PlatformAwareButton(
                  label: 'Önceki',
                  variant: ButtonVariant.secondary,
                  icon: Icons.arrow_back,
                  onPressed: hasPrev ? () => setState(() => _index--) : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PlatformAwareButton(
                  label: 'Sonraki',
                  variant: ButtonVariant.secondary,
                  icon: Icons.arrow_forward,
                  onPressed: hasNext ? () => setState(() => _index++) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BodyCard extends StatelessWidget {
  final HadithModel hadith;
  const _BodyCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return ArtisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hadith.source.toUpperCase(),
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Hadis No. ${hadith.hadithNo}',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hadith.text,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: AppColors.indigoDeep,
            ),
          ),
        ],
      ),
    );
  }
}
