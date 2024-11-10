import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';

import '../../../app_constants/app_sizes.dart';
import '../../../app_widgets/app_text.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
  });

  final Account account;

  @override
  Widget build(BuildContext context) {
    double availableBalance = account.income - account.expenses;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color.fromARGB(255, 224, 130, 186),
          Color.fromARGB(255, 156, 117, 233)
        ]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              AppText(
                text: account.name,
                isWhite: true,
                weight: FontWeight.bold,
                size: AppSizes.heading6,
              ),
              const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const Gap(5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                text: 'Available Balance',
                isWhite: true,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'GHc $availableBalance',
                    isWhite: true,
                  ),
                  Row(
                    children: [
                      const Gap(10),
                      if (availableBalance > 0)
                        InkWell(
                          onTap: () {},
                          child: Ink(
                            child: AppText(
                              text: 'Save 💰',
                              color: Colors.green[200],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      if (availableBalance < 0)
                        InkWell(
                          onTap: () {},
                          child: Ink(
                            child: AppText(
                              text: 'TODO',
                              color: Colors.red[200],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              )
            ],
          ),
          const Gap(25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey.withOpacity(0.35),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            color: Colors.green,
                            child: const FaIcon(
                              Icons.file_download_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Gap(5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              text: 'Income',
                              isWhite: true,
                            ),
                            AppText(
                              text: 'GHc ${account.income.toString()}',
                              isWhite: true,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey.withOpacity(0.35),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            color: Colors.red,
                            child: const FaIcon(
                              Icons.file_upload_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Gap(5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              text: 'Expenses',
                              isWhite: true,
                            ),
                            AppText(
                              text: 'GHc ${account.expenses.toString()}',
                              isWhite: true,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

IconData getIcon(AccountTransaction transaction) {
  switch (transaction.category) {
    case 'Gifts':
      return Iconsax.gift;

    case 'Health':
      return FontAwesomeIcons.stethoscope;
    case 'Car':
      return FontAwesomeIcons.car;
    case 'Game':
      return FontAwesomeIcons.chess;
    case 'Cafe':
      return FontAwesomeIcons.utensils;

    case 'Travel':
      return Iconsax.airplane;
    case 'Utility':
      return FontAwesomeIcons.lightbulb;
    case 'Care':
      return Icons.face_2;
    case 'Devices':
      return FontAwesomeIcons.tv;
    case 'Food':
      return FontAwesomeIcons.bowlFood;
    case 'Shopping':
      return FontAwesomeIcons.cartShopping;
    case 'Transport':
      return Iconsax.truck;

    default:
      return FontAwesomeIcons.coins;
  }
}
