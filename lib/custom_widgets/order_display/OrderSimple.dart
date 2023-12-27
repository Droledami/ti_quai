import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ti_quai/extensions/string_extensions.dart';

import '../../custom_materials/theme.dart';
import '../../models/CustomerOrder.dart';
import '../../processes/functions.dart';

class OrderSimple extends StatelessWidget {
  const OrderSimple({super.key, required this.order, required this.changeSelection, required this.orderBoxId});

  final CustomerOrder order;
  final int orderBoxId;
  final Function changeSelection;

  @override
  Widget build(BuildContext context) {
    final numberOfArticles = order.orderElements.length;
    String orderTime = getHourAndMinuteString(order.date);
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
      child: GestureDetector(
        onTap: (){
          changeSelection(orderBoxId);
        },
        child: Container(
          decoration: BoxDecoration(
            color: customColors.cardQuarterTransparency!,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(
                      left: 10, right: 10, top: 0, bottom: 0),
                  leading: Text(
                    'Table ${order.tableNumber}',
                    style: TextStyle(
                      height: 1,
                      fontSize: 30,
                    ),
                  ),
                  title: Text(
                    numberOfArticles > 1
                        ? "$numberOfArticles articles"
                        : "$numberOfArticles article",
                    style: TextStyle(
                      height: 1,
                      fontSize: 24,
                    ),
                  ),
                  trailing: Text(
                    orderTime,
                    style: TextStyle(
                      height: 1,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(
                      left: 10, right: 10, top: 0, bottom: 0),
                  title: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: customColors.special!,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      "${kIsWeb? "Règlement par ": ""}${ kIsWeb? order.paymentMethod.name : order.paymentMethod.name.capitalize()}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: customColors.special!,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      "${order.totalPrice.toStringAsFixed(2)}€",
                      style: TextStyle(
                        height: 1,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}