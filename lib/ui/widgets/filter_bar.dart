import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

class FilterOption {
  final String id;
  final String label;

  const FilterOption({required this.id, required this.label});

  String valueLabel({String? title}) {
    final t = (title ?? '').trim();
    final s = label.trim();

    if (t.isNotEmpty) {
      final prefix = '$t: ';
      if (s.toLowerCase().startsWith(prefix.toLowerCase())) {
        return s.substring(prefix.length).trim();
      }
    }

    final idx = s.indexOf(':');
    if (idx >= 0 && idx + 1 < s.length) {
      return s.substring(idx + 1).trim();
    }
    return s;
  }
}

class FilterBar extends StatelessWidget {
  final List<FilterOption> boxes;
  final List<FilterOption> categories;
  final List<FilterOption>? locations;
  final String selectedBoxId;
  final String selectedCategoryId;
  final String? selectedLocationId;
  final ValueChanged<String> onBoxChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String>? onLocationChanged;
  final VoidCallback onSearchTap;
  final bool showClear;
  final VoidCallback? onClear;

  const FilterBar({
    super.key,
    required this.boxes,
    required this.categories,
    this.locations,
    required this.selectedBoxId,
    required this.selectedCategoryId,
    this.selectedLocationId,
    required this.onBoxChanged,
    required this.onCategoryChanged,
    this.onLocationChanged,
    required this.onSearchTap,
    this.showClear = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final showLocal = locations != null &&
        selectedLocationId != null &&
        onLocationChanged != null;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingSm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          const gap = UiTokens.s;
          final compact = maxWidth < 560;
          final dropdownWidth = compact ? (maxWidth - gap) / 2 : 196.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtros do cat\u00e1logo',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                'Organize por categoria, caixa e local sem poluir a tela.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: UiTokens.spacingSm),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: dropdownWidth,
                    child: _ProDropdown(
                      title: 'Categoria',
                      valueId: selectedCategoryId,
                      items: categories,
                      onChanged: onCategoryChanged,
                    ),
                  ),
                  SizedBox(
                    width: dropdownWidth,
                    child: _ProDropdown(
                      title: 'Caixa',
                      valueId: selectedBoxId,
                      items: boxes,
                      onChanged: onBoxChanged,
                    ),
                  ),
                  if (showLocal)
                    SizedBox(
                      width: dropdownWidth,
                      child: _ProDropdown(
                        title: 'Local',
                        valueId: selectedLocationId!,
                        items: locations!,
                        onChanged: onLocationChanged!,
                      ),
                    ),
                  SizedBox(
                    width: compact ? dropdownWidth : 120,
                    height: 48,
                    child: FilledButton.tonalIcon(
                      onPressed: onSearchTap,
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ),
                  if (showClear)
                    SizedBox(
                      width: compact ? dropdownWidth : 120,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: onClear,
                        icon: const Icon(Icons.close),
                        label: const Text('Limpar'),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProDropdown extends StatelessWidget {
  final String title;
  final String valueId;
  final List<FilterOption> items;
  final ValueChanged<String> onChanged;

  const _ProDropdown({
    required this.title,
    required this.valueId,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final safeValue = items.any((e) => e.id == valueId) ? valueId : items.first.id;

    final titleStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w800,
    );

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UiTokens.radiusLg),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          borderRadius: BorderRadius.circular(UiTokens.radiusLg),
          style: theme.textTheme.bodyMedium,
          selectedItemBuilder: (context) {
            return items.map((it) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 26),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        it.valueLabel(title: title),
                        style: valueStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.id,
                  child: Text(
                    e.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}
