import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/post.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Stack(
        children: [
          // Top image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 360,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo
                  Hero(
                    tag: 'post-photo-${post.id}',
                    child: Image.network(
                      post.photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),

                  // Back button
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          _roundIconButton(
                            context: context,
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  // Small avatar bottom-left
                  Positioned(
                    left: 20,
                    bottom: 32,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          post.author.isNotEmpty
                              ? post.author[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Page indicators
                  Positioned(
                    bottom: 18,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _pageDot(isActive: true),
                        const SizedBox(width: 8),
                        _pageDot(isActive: false),
                        const SizedBox(width: 8),
                        _pageDot(isActive: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // White rounded detail sheet
          Positioned(
            left: 0,
            right: 0,
            top: 320,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleRow(),
                      const SizedBox(height: 12),
                      _ratingRow(),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.divider, height: 32),
                      _descriptionSection(),
                      const SizedBox(height: 24),
                      _sizeColorRow(),
                      const SizedBox(height: 24),
                      _categorySection(),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.divider, height: 32),
                      const SizedBox(height: 8),
                      _locationAndClaimRow(context),
                      const SizedBox(height: 18),
                      _homeIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Top content widgets ----------

  Widget _titleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            post.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.favorite_border_rounded,
            color: Colors.redAccent,
          ),
        )
      ],
    );
  }

  Widget _ratingRow() {
    return Row(
      children: [
        // Distance pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.distancePill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: const [
              Icon(Icons.place_outlined, size: 14, color: AppColors.textMuted),
              SizedBox(width: 4),
              Text(
                '67m away',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Stars
        Row(
          children: List.generate(5, (index) {
            final isFilled = index < 4; // 4.0/5 rating look
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                isFilled
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 18,
                color: AppColors.ratingStar,
              ),
            );
          }),
        ),
        const SizedBox(width: 6),
        const Text(
          '4.3',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '(53 reviews)',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        )
      ],
    );
  }

  // ---------- Description ----------

  Widget _descriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: post.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(
                text: '  more...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Size + Color ----------

  Widget _sizeColorRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Size:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Text(
                  '32',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Color:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Categories ----------

  Widget _categorySection() {
    final tags = post.tags;
    final visibleTags = tags.take(3).toList();
    final remaining = tags.length - visibleTags.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in visibleTags) _categoryChip(tag),
            if (remaining > 0) _categoryChip('+$remaining more'),
          ],
        )
      ],
    );
  }

  Widget _categoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ---------- Location + Claim button ----------

  Widget _locationAndClaimRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post.location,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // TODO: implement claim action
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CLAIM',
                    style: TextStyle(
                      letterSpacing: 0.5,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.check_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Helpers ----------

  Widget _homeIndicator() {
    return Center(
      child: Container(
        width: 120,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _roundIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _pageDot({required bool isActive}) {
    return Container(
      width: isActive ? 8 : 7,
      height: isActive ? 8 : 7,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
