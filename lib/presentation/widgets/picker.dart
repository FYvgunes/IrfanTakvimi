import 'package:flutter/material.dart';

import '../../core/constants/theme.dart';

/// Push the full-page picker and return the user's selection (or null if
/// they backed out without choosing).
Future<T?> showPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  T? selected,
  String searchHint = 'Ara…',
  String emptyText = 'Sonuç bulunamadı',
}) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(
      fullscreenDialog: false,
      builder: (_) => _PickerScreen<T>(
        title: title,
        items: items,
        labelOf: labelOf,
        selected: selected,
        searchHint: searchHint,
        emptyText: emptyText,
      ),
    ),
  );
}

/// Tappable field that mimics an input row: small label on top, current value
/// below, chevron to the right. Tapping it should open a picker via
/// [showPicker] in the caller's onTap.
class PickerField extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;

  const PickerField({
    super.key,
    required this.label,
    required this.value,
    this.placeholder = 'Seç',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasValue = value != null && value!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: p.groundSoft,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(color: p.copper.withOpacity(0.40), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: bodyFont(
                      size: 10,
                      color: p.copper,
                      letterSpacing: 1.8,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasValue ? value! : placeholder,
                    style: bodyFont(
                      size: 16,
                      color: hasValue ? p.ink : p.inkMuted,
                      weight: hasValue ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: p.copper.withOpacity(0.7),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerScreen<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final T? selected;
  final String searchHint;
  final String emptyText;

  const _PickerScreen({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.selected,
    required this.searchHint,
    required this.emptyText,
  });

  @override
  State<_PickerScreen<T>> createState() => _PickerScreenState<T>();
}

class _PickerScreenState<T> extends State<_PickerScreen<T>> {
  late final TextEditingController _ctl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _ctl = TextEditingController();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  // Map Turkish letters to base letters so a search like "uskudar" matches
  // "Üsküdar", "sanliurfa" matches "Şanlıurfa", etc.
  static const _trFold = {
    'ç': 'c', 'ğ': 'g', 'ı': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
    'â': 'a', 'î': 'i', 'û': 'u',
    'İ': 'i', 'I': 'i', // both Turkish uppercase I forms fold to i
  };

  String _fold(String s) {
    final lower = s.toLowerCase();
    final buf = StringBuffer();
    for (final ch in lower.split('')) {
      buf.write(_trFold[ch] ?? ch);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final folded = _fold(_query.trim());
    final filtered = folded.isEmpty
        ? widget.items
        : widget.items
            .where((e) => _fold(widget.labelOf(e)).contains(folded))
            .toList(growable: false);

    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        title: Text(widget.title.toUpperCase()),
        titleTextStyle: displayFont(
          size: 18,
          color: p.ink,
          letterSpacing: 2.4,
          weight: FontWeight.w500,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            child: TextField(
              controller: _ctl,
              autofocus: true,
              style: bodyFont(size: 15, color: p.ink),
              cursorColor: p.copper,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: bodyFont(size: 15, color: p.inkMuted),
                prefixIcon: Icon(Icons.search, color: p.copper, size: 20),
                filled: true,
                fillColor: p.groundSoft,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: BorderSide(color: p.copper.withOpacity(0.30)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: BorderSide(color: p.copper.withOpacity(0.30)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: BorderSide(color: p.copper.withOpacity(0.75)),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Container(height: 1, color: p.copper.withOpacity(0.20)),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      widget.emptyText,
                      style: bodyFont(size: 14, color: p.inkMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      color: p.copper.withOpacity(0.10),
                    ),
                    itemBuilder: (context, i) {
                      final item = filtered[i];
                      final isSelected = item == widget.selected;
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md),
                          child: Row(
                            children: [
                              _SelectionDot(selected: isSelected),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  widget.labelOf(item),
                                  style: bodyFont(
                                    size: 16,
                                    color: p.ink,
                                    weight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check, color: p.copper, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  final bool selected;
  const _SelectionDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? p.copper : p.inkMuted.withOpacity(0.5),
          width: selected ? 4.5 : 1.5,
        ),
        color: selected ? p.ground : Colors.transparent,
      ),
    );
  }
}
