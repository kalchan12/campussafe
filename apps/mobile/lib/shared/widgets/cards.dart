import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/design_tokens.dart';
import 'status_badge.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final Border? border;
  final VoidCallback? onTap;
  final bool isElevated;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.shadows,
    this.border,
    this.onTap,
    this.isElevated = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.defaultRadius),
        boxShadow: shadows ?? (isElevated ? [AppShadows.cardShadow] : []),
        border: border ?? Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.defaultRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.defaultRadius),
            child: cardContent,
          ),
        ),
      );
    }

    return margin != null
        ? Padding(padding: margin!, child: cardContent)
        : cardContent;
  }
}

class IncidentCard extends StatelessWidget {
  final String id;
  final String type;
  final String status;
  final String? description;
  final String? location;
  final DateTime createdAt;
  final int priority;
  final VoidCallback? onTap;
  final bool showPriority;

  const IncidentCard({
    super.key,
    required this.id,
    required this.type,
    required this.status,
    this.description,
    this.location,
    required this.createdAt,
    this.priority = 1,
    this.onTap,
    this.showPriority = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusVariant = status.statusBadgeVariant;
    final typeIcon = type.typeIcon;
    final typeColor = type.typeColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Emergency Type Badge + Status Pill + Time
                Row(
                  children: [
                    // Emergency Type Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 14, color: typeColor),
                          const SizedBox(width: 6),
                          Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: typeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status Pill
                    StatusBadge(
                      label: status.statusDisplayName,
                      variant: statusVariant,
                      isSmall: true,
                    ),

                    const Spacer(),

                    // Elapsed Time
                    Text(
                      _formatRelativeTime(createdAt),
                      style: AppTypography.technicalSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Location / Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location ?? 'Main Campus Area',
                        style: AppTypography.headlineMd.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showPriority && priority == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'P1 CRITICAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),

                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(
                      description!,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Bottom Footer: ID tag & Tap to View Details
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '#${id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase()}',
                        style: AppTypography.technicalSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'View Live Response',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class ReportCard extends StatelessWidget {
  final String id;
  final String type;
  final String status;
  final String description;
  final DateTime createdAt;
  final bool isAnonymous;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.id,
    required this.type,
    required this.status,
    required this.description,
    required this.createdAt,
    this.isAnonymous = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusVariant = status.statusBadgeVariant;

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: status.statusDisplayName,
                variant: statusVariant,
                isSmall: true,
              ),
              if (isAnonymous) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'Anonymous',
                    style: AppTypography.technicalSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            type.toUpperCase(),
            style: AppTypography.labelMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _formatDateTime(createdAt),
                style: AppTypography.technicalSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }
}

class ResponderCard extends StatelessWidget {
  final String name;
  final String role;
  final String distance;
  final String status;
  final String? avatarUrl;
  final VoidCallback? onContact;
  final VoidCallback? onViewDetails;

  const ResponderCard({
    super.key,
    required this.name,
    required this.role,
    required this.distance,
    required this.status,
    this.avatarUrl,
    this.onContact,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryContainer,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.headlineMd.copyWith(
                    fontSize: 16,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        distance,
                        style: AppTypography.technicalSm.copyWith(
                          color: AppColors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(
                      label: status,
                      variant: status.statusBadgeVariant,
                      isSmall: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onContact != null)
            OutlinedButton.icon(
              onPressed: onContact,
              icon: Icon(Icons.call, size: 18, color: AppColors.primary),
              label: Text(
                'Contact',
                style: AppTypography.labelMd.copyWith(color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmergencyTypeCard extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const EmergencyTypeCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeIcon = type.typeIcon;
    final typeColor = type.typeColor;
    final typeContainerColor = type.typeContainerColor;
    final typeOnContainerColor = type.typeOnContainerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? typeContainerColor
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? typeColor : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? typeColor.withValues(alpha: 0.1)
                    : typeContainerColor,
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.outlineVariant),
              ),
              child: Center(
                child: Icon(
                  typeIcon,
                  size: 20,
                  color: isSelected ? typeColor : typeOnContainerColor,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              type.toUpperCase(),
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? typeColor : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerMargin,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineMd.copyWith(
                  fontSize: 20,
                  color: AppColors.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          if (trailing != null && onTrailingTap != null)
            TextButton(
              onPressed: onTrailingTap,
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

class BentoGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const BentoGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = AppSpacing.sm,
    this.runSpacing = AppSpacing.sm,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: runSpacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}