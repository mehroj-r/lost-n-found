import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = <_FaqItem>[
      _FaqItem(
        question: 'What is Findly?',
        answer:
        'Findly is a lost & found platform that helps students and staff '
            'report lost items and find items that have been found by others.',
      ),
      _FaqItem(
        question: 'How do I create a post?',
        answer:
        'Go to the home screen and tap the "+" button (or "Create post"). '
            'Fill in the title, description, type (lost/found), upload a photo, '
            'and choose the location, then tap "Publish".',
      ),
      _FaqItem(
        question: 'How do favourites work?',
        answer:
        'Tap the heart icon on any post to add it to your favourites. '
            'All posts you have liked will appear in the "My favourites" section '
            'of your profile.',
      ),
      _FaqItem(
        question: 'How do I edit or delete my post?',
        answer:
        'Open your profile and go to "My posts". From there, you can open any '
            'of your posts and use the edit or delete options if they are available.',
      ),
      _FaqItem(
        question: 'How do I contact the owner of a post?',
        answer:
        'Open the post and use the contact details shown (such as phone number '
            'or email) to reach out to the owner. Do not share sensitive personal '
            'information and always meet in safe, public places.',
      ),
      _FaqItem(
        question: 'Can I delete a post after it is resolved?',
        answer:
        'Yes. Go to your profile, open "My posts", select the post you want to remove, '
            'and use the delete option if it is available. Once deleted, the post will no longer '
            'be visible to other users.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/settings'),
        ),
        title: Text(
          'FAQ',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: AppDimensions.allXl,
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                    borderRadius: AppDimensions.borderRadiusL,
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceL),
                Text(
                  'How can we help you?',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceS),
                Text(
                  'Find answers to frequently asked questions',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: AppDimensions.allL,
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final item = faqs[index];
                return Container(
                  margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppDimensions.borderRadiusL,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: AppDimensions.allL,
                      childrenPadding: EdgeInsets.fromLTRB(
                        AppDimensions.spaceL,
                        0,
                        AppDimensions.spaceL,
                        AppDimensions.spaceL,
                      ),
                      iconColor: AppColors.primary,
                      collapsedIconColor: AppColors.textMuted,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppDimensions.borderRadiusM,
                        ),
                        child: Center(
                          child: Text(
                            'Q${index + 1}',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        item.question,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      children: [
                        Container(
                          padding: AppDimensions.allM,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundTertiary,
                            borderRadius: AppDimensions.borderRadiusM,
                          ),
                          child: Text(
                            item.answer,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ),
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

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });
}