import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.agencyNumber,
    required this.statusText,
    this.isApproved = true,
    this.avatarText = 'NH',
    this.onTap,
  });

  final String name;
  final String email;
  final String agencyNumber;

  /// e.g. "Approved"
  final String statusText;

  /// If you want to switch icon (check / close) and semantic state
  final bool isApproved;

  /// e.g. "NH"
  final String avatarText;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + Status (first)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.secondary,
                      // border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      avatarText,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StatusChip(
                    text: statusText,
                    isApproved: isApproved,
                  ),
                ],
              ),

              const SizedBox(width: 22),

              // Name + Email (beside avatar)
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text("Agency Number".tr, style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500, 
                            color: cs.onSurfaceVariant,
                          ),),
                          const SizedBox(width: 6),
                          Text(agencyNumber, style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),),
                        ],
                      ),
                    ],
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.text,
    required this.isApproved,
  });

  final String text;
  final bool isApproved;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
        color: cs.secondaryFixed,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApproved ? Icons.check : Icons.close,
            size: 14,
            color: cs.onPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            text.tr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cs.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
