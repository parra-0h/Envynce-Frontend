import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class SmartTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> data;
  final List<Widget> Function(T item) rowBuilder;
  final VoidCallback? onNextPage;
  final VoidCallback? onPrevPage;
  final int currentPage;
  final int totalPages;
  final Function(T item)? onRowTap;

  const SmartTable({
    super.key,
    required this.columns,
    required this.data,
    required this.rowBuilder,
    this.onNextPage,
    this.onPrevPage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppTheme.dividerColor),
          Expanded(
            child: data.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppTheme.dividerColor),
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return _buildRow(context, item);
                    },
                  ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.surfaceSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: columns.map((col) {
          // Last column often actions, so we might want to align it differently or give it fixed width
          // For simplicity here we treat all equally with Expanded, except if it's an empty string which implies actions
          if (col.isEmpty) return const SizedBox(width: 48);
          return Expanded(
            child: Text(
              col.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(BuildContext context, T item) {
    final cells = rowBuilder(item);
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onRowTap != null ? () => onRowTap!(item) : null,
        hoverColor: AppTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: cells.map((cell) {
              if (cell is SizedBox) return cell; // Probably actions column
              return Expanded(child: cell);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.inbox, size: 48, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          const Text(
            'No data available',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $currentPage of $totalPages',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onPrevPage,
                icon: const Icon(LucideIcons.chevronLeft, size: 20),
                color: AppTheme.textSecondary,
                splashRadius: 20,
                tooltip: 'Previous',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onNextPage,
                icon: const Icon(LucideIcons.chevronRight, size: 20),
                color: AppTheme.textSecondary,
                splashRadius: 20,
                tooltip: 'Next',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
