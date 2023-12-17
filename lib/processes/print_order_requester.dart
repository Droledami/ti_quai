import 'package:http/http.dart';
import 'dart:convert';
import '../models/Article.dart';
import '../models/OrderElement.dart';
import 'functions.dart';
import '../models/CustomerOrder.dart';

String addressLAN = "192.168.1.128:65139";
String addressWiFi = "192.168.1.129:65139";
String localhost = "localhost:65139";

class PrintOrderRequester {
  var url = Uri.http(localhost, '/print-order');

  Future<bool> sendPrintRequest(CustomerOrder order) async {
    var response = await post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          CustomerOrder.keyTableNumber: order.tableNumber,
          CustomerOrder.keyPaymentMethod: order.paymentMethod.name,
          CustomerOrder.keyDate: getFullDate(order.date),
          CustomerOrder.keyOrderElements: order.orderElements.map((oe) => convertOrderElementToMaps(oe)).toList(),
          CustomerOrder.keyUnlinkedPromotions: order.unlinkedPromotions.map((ulProm) => convertPromotionToMap(ulProm)).toList(),
        }));
    print("Response from server ${response.statusCode}");
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
