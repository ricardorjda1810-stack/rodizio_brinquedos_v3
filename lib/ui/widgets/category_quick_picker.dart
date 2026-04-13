import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

typedef CategoryIdGetter<T> = String Function(T category);
typedef CategoryNameGetter<T> = String Function(T category);
typedef CategoryExamplesGetter<T> = String? Function(T category);

class CategoryQuickPicker<T> extends StatelessWidget {
  final List<T> categories;
  final String? selectedId;
  final bool disabled;
  final CategoryIdGetter<T> getId;
  final CategoryNameGetter<T> getName;
  final CategoryExamplesGetter<T> getExamples;
  final ValueChanged<String> onSelected;

  const CategoryQuickPicker({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.disabled,
    required this.getId,
    required this.getName,
    required this.getExamples,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: UiTokens.spacingSm,
        mainAxisSpacing: UiTokens.spacingSm,
        mainAxisExtent: 90,
      ),
      itemBuilder: (context, i) {
        final category = categories[i];
        return _CategoryQuickPickerCard(
          name: getName(category),
          examplesText: getExamples(category),
          selected: selectedId == getId(category),
          disabled: disabled,
          onTap: () {
            FocusScope.of(context).unfocus();
            onSelected(getId(category));
          },
        );
      },
    );
  }
}

class _CategoryQuickPickerCard extends StatelessWidget {
  final String name;
  final String? examplesText;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _CategoryQuickPickerCard({
    required this.name,
    required this.examplesText,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedExamples = (examplesText ?? '').trim();
    final subtitle = normalizedExamples.isEmpty
        ? 'Exemplos ainda n\u00e3o definidos.'
        : 'Ex.: $normalizedExamples';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
        child: Ink(
          padding: const EdgeInsets.all(UiTokens.spacingSm),
          decoration: BoxDecoration(
            color: selected ? UiTokens.primarySoft : UiTokens.surface,
            borderRadius: BorderRadius.circular(UiTokens.radiusMd),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: UiTokens.shadow,
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
            border: Border.all(
              color: selected ? UiTokens.primaryStrong : UiTokens.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textBody.copyWith(
                        color: UiTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: UiTokens.primaryStrong,
                    ),
                ],
              ),
              const SizedBox(height: UiTokens.spacingSm),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: UiTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
