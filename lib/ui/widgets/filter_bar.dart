import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class FilterOption {
  final String id;
  final String label;

  /// label = texto completo que aparece na lista.
  /// valueLabel (derivado) = tentamos extrair o “valor” removendo prefixos comuns.
  const FilterOption({required this.id, required this.label});

  String valueLabel({String? title}) {
    // Se veio "Caixa: Todas" -> "Todas"
    // Se veio "Categoria: Montar" -> "Montar"
    // Se veio "Local: Quarto" -> "Quarto"
    final t = (title ?? '').trim();
    final s = label.trim();

    if (t.isNotEmpty) {
      final prefix1 = '$t: ';
      if (s.toLowerCase().startsWith(prefix1.toLowerCase())) {
        return s.substring(prefix1.length).trim();
      }
    }

    // fallback: remove "X: " se existir
    final idx = s.indexOf(':');
    if (idx >= 0 && idx + 1 < s.length) {
      return s.substring(idx + 1).trim();
    }
    return s;
  }
}

/// Barra compacta sempre lado a lado (scroll horizontal se precisar):
/// [Caixa ▼] [Categoria ▼] [Local ▼ (opcional)] [🔍] (+ opcional [X])
///
/// Visual "pro":
/// - título pequeno (label)
/// - valor em negrito
class FilterBar extends StatelessWidget {
  final List<FilterOption> boxes;
  final List<FilterOption> categories;

  /// Se null, não mostra Local.
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
    final theme = Theme.of(context);

    final showLocal =
        locations != null && selectedLocationId != null && onLocationChanged != null;

    // Larguras simples e previsíveis.
    const double w = 190;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          SizedBox(
            width: w,
            child: _ProDropdown(
              title: 'Categoria',
              valueId: selectedCategoryId,
              items: categories,
              onChanged: onCategoryChanged,
            ),
          ),
          const SizedBox(width: UiTokens.s),
          SizedBox(
            width: w,
            child: _ProDropdown(
              title: 'Caixa',
              valueId: selectedBoxId,
              items: boxes,
              onChanged: onBoxChanged,
            ),
          ),
          if (showLocal) ...[
            const SizedBox(width: UiTokens.s),
            SizedBox(
              width: w,
              child: _ProDropdown(
                title: 'Local',
                valueId: selectedLocationId!,
                items: locations!,
                onChanged: onLocationChanged!,
              ),
            ),
          ],
          const SizedBox(width: UiTokens.s),
          IconButton(
            tooltip: 'Buscar',
            onPressed: onSearchTap,
            icon: const Icon(Icons.search),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (showClear) ...[
            const SizedBox(width: UiTokens.xs),
            IconButton(
              tooltip: 'Limpar filtros',
              onPressed: onClear,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          borderRadius: BorderRadius.circular(12),
          // O DropdownButton usa esse style pros itens; no "selectedItemBuilder" controlamos o visual selecionado.
          style: theme.textTheme.bodyMedium,
          selectedItemBuilder: (context) {
            return items.map((it) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 26), // espaço pro ícone ▼
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
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
