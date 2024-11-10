import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../app_constants/app_constants.dart';
import '../../../app_functions/app_functions.dart';
import '../../sign_in/user_info/models/user_model.dart';
import '../models/statistics/statistics_model.dart';
import 'widgets.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  List<String>? dropdownOptions = [];

  int? _periodFilter = 0;
  String? _selectedAccountName;
  String? _selectedSortBy = 'Sort by categories';
  Account? _selectedAccount;
  late List<_ChartData> data;
  DateTime? _dateHolder;
  final Box<AppUser> _userBox = Hive.box(AppBoxes.user);
  Map<dynamic, int> serviceTypeCounts = {0: 5};

  bool _inIncomeView = true;

  @override
  void initState() {
    super.initState();
    _selectedAccount = _userBox.values.first.accounts?.first;
    _selectedAccountName = _selectedAccount?.name;
    data = [
      _ChartData('CHN', 12),
      _ChartData('GER', 15),
      _ChartData('RUS', 30),
      _ChartData('BRZ', 6.4),
      _ChartData('IND', 14)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.horizontalPaddingSmall),
      child: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                alignment: Alignment.center,
                isExpanded: true,
                hint: const AppText(
                  text: 'Accounts',

                  // isFetching ? 'Please wait...' : "Select...",

                  overflow: TextOverflow.ellipsis,
                ),
                iconStyleData: const IconStyleData(
                  icon: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    color: AppColors.neutral900,
                  ),
                  iconSize: 12.0,
                ),
                items: _userBox.values.first.accounts!
                    .map(
                      (e) => e.name,
                    )
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: GoogleFonts.manrope(
                              fontSize: AppSizes.bodySmaller,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ))
                    .toList(),
                value: _selectedAccountName,
                onChanged: (value) {},
                buttonStyleData: ButtonStyleData(
                  height: AppSizes.dropDownBoxHeight,
                  padding: const EdgeInsets.only(right: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    // border: Border.all(
                    //   width: 1.0,
                    //   color: AppColors.neutral300,
                    // ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 350,
                  elevation: 1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40.0,
                ),
              ),
            ),
            const Gap(10),
            Row(
              children: [
                Expanded(
                  child: CupertinoSlidingSegmentedControl(
                    backgroundColor: Colors.grey.shade100,
                    thumbColor: AppColors.primary,
                    children: {
                      0: AppText(
                        text: 'All',
                        isWhite: _periodFilter == 0 ? true : false,
                      ),
                      1: AppText(
                        text: 'Day',
                        isWhite: _periodFilter == 1 ? true : false,
                      ),
                      2: AppText(
                        text: 'Week',
                        isWhite: _periodFilter == 2 ? true : false,
                      ),
                      3: AppText(
                        text: 'Month',
                        isWhite: _periodFilter == 3 ? true : false,
                      ),
                      4: AppText(
                        text: 'Year',
                        isWhite: _periodFilter == 4 ? true : false,
                      ),
                    },
                    groupValue: _periodFilter,
                    onValueChanged: (value) {
                      setState(() {
                        _periodFilter = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Gap(10),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: _inIncomeView
                                      ? AppColors.primary
                                      : AppColors.neutral100),
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () {
                        if (!_inIncomeView) {
                          setState(() {
                            _inIncomeView = true;
                          });
                        }
                      },
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.arrow_down,
                                color: AppColors.neutral500,
                                size: 15,
                              ),
                              AppText(
                                text: 'Income',
                                color: AppColors.neutral500,
                              )
                            ],
                          ),
                          AppText(
                            text: '+ 2 215.10 GHc',
                            size: AppSizes.heading5,
                            color: Colors.green,
                            weight: FontWeight.w500,
                          )
                        ],
                      )),
                ),
                const Gap(10),
                Expanded(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: !_inIncomeView
                                      ? AppColors.primary
                                      : AppColors.neutral100),
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () {
                        if (_inIncomeView) {
                          setState(() {
                            _inIncomeView = false;
                          });
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Iconsax.arrow_up_3,
                                size: 15,
                                color: AppColors.neutral500,
                              ),
                              AppText(
                                text: 'Expenses',
                                color: AppColors.neutral500,
                              )
                            ],
                          ),
                          AppText(
                            text: '+ 2 215.10 GHc',
                            size: AppSizes.heading5,
                            color: Colors.red.shade300,
                            weight: FontWeight.w500,
                          )
                        ],
                      )),
                ),
              ],
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 170,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      alignment: Alignment.centerRight,
                      hint: const AppText(
                        text: 'Sort by',
                        color: AppColors.primary,

                        // isFetching ? 'Please wait...' : "Select...",

                        overflow: TextOverflow.ellipsis,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: FaIcon(
                          FontAwesomeIcons.chevronDown,
                          color: AppColors.primary,
                        ),
                        iconSize: 12.0,
                      ),
                      items: [
                        'Sort by date',
                        'Sort by categories',
                      ]
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: GoogleFonts.manrope(
                                    fontSize: AppSizes.bodySmaller,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ))
                          .toList(),
                      value: _selectedSortBy,
                      onChanged: (value) {
                        setState(() {
                          _selectedSortBy = value;
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        height: AppSizes.dropDownBoxHeight,
                        padding: const EdgeInsets.only(right: 10.0),
                        decoration: BoxDecoration(
                          // color: Colors.grey.shade100,
                          // border: Border.all(
                          //   width: 1.0,
                          //   color: AppColors.neutral300,
                          // ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 350,
                        elevation: 1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white,
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
            _selectedSortBy == 'Sort by categories'
                ? SfCircularChart(
                    // annotations: <CircularChartAnnotation>[
                    //   const CircularChartAnnotation(
                    //       angle: 200,
                    //       radius: '80%',
                    //       widget: Text('Circular Chart')),
                    //   const CircularChartAnnotation(
                    //       angle: 60,
                    //       radius: '80%',
                    //       widget: Text('Circular Chart')),
                    //   const CircularChartAnnotation(
                    //       angle: 100,
                    //       radius: '80%',
                    //       widget: Text('Circular Chart')),
                    // ],
                    // backgroundColor: Colors.green,
                    legend: const Legend(isVisible: true, isResponsive: true),
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        // explodeAll: true,
                        groupMode: CircularChartGroupMode.point,
                        groupTo: 3, explode: true, explodeAll: true,
                        explodeOffset: '3%',
                        dataSource:
                            // List.generate(serviceTypeCounts.length,
                            //               (index) {
                            //             String type =
                            //                 serviceTypeCounts.keys.elementAt(index);
                            //             Map<String, dynamic> data =
                            //                 serviceTypeCounts[type]!;
                            //             int count = data['count'] as int;
                            //             Color color = data['color'] as Color;

                            //             return ChartData(type, count, color);
                            //           }),
                            [
                          ChartData('Jan', 50, Colors.brown),
                          ChartData('Feb', 10, Colors.blue),
                          ChartData('March', 70, Colors.red),
                        ],
                        xValueMapper: (ChartData data, _) => data.month,
                        yValueMapper: (ChartData data, _) => data.amount,
                        pointColorMapper: (ChartData data, _) => data.color,
                        innerRadius: '40%',
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  )
                : SfCartesianChart(
                    // borderWidth: 0,
                    primaryXAxis: const CategoryAxis(
                      majorGridLines: MajorGridLines(width: 0),
                    ),
                    primaryYAxis: const NumericAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        minimum: 0,
                        maximum: 40,
                        interval: 10),
                    series: <CartesianSeries<_ChartData, String>>[
                      ColumnSeries<_ChartData, String>(
                          dataSource: data,
                          xValueMapper: (_ChartData data, _) => data.x,
                          yValueMapper: (_ChartData data, _) => data.y,
                          borderRadius: BorderRadius.circular(10),
                          // name: 'Gold',
                          color: AppColors.primary)
                    ],
                  ),
            (_selectedAccount != null)
                ? SizedBox(
                    height: Adaptive.h(40),
                    child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.horizontalPaddingSmall),
                        itemBuilder: (context, index) {
                          final transaction =
                              _selectedAccount!.transactions![index];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            tileColor: Colors.grey.shade100,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: 50,
                                color: AppColors.primary.withOpacity(0.1),
                                child: Icon(
                                  getIcon(transaction),
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            title: AppText(text: transaction.description),
                            subtitle: AppText(
                              text: transaction.description,
                              color: Colors.grey,
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AppText(
                                    text:
                                        '-${transaction.amount.toString()}GHc'),
                                AppText(
                                  text: AppFunctions.formatDate(
                                      transaction.date.toString(),
                                      format: r'g:i A'),
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          if (_selectedAccount!.transactions![index].date !=
                              _dateHolder) {
                            _dateHolder =
                                _selectedAccount!.transactions![index].date;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(5),
                                AppText(
                                    text: AppFunctions.formatDate(
                                        _selectedAccount!
                                            .transactions![index].date
                                            .toString(),
                                        format: r'j M Y')),
                                const Gap(5),
                              ],
                            );
                          } else {
                            return const Gap(10);
                          }
                        },
                        itemCount: _selectedAccount!.transactions!.length),
                  )
                : Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Lottie.asset(AppAssets.emptyList, height: 200),
                    ],
                  ))
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
