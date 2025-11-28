import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'FAQ',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small header / description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Frequently asked questions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final item = faqs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  color: Colors.white,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Theme(
                    // Remove default ExpansionTile divider color
                    data: theme.copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        12,
                      ),
                      iconColor: theme.colorScheme.primary,
                      collapsedIconColor: Colors.grey.shade500,
                      title: Text(
                        item.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.answer,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.5,
                              fontSize: 14,
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