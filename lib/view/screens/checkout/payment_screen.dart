import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/screens/checkout/widget/payment_failed_dialog.dart';
import 'package:sixam_mart/view/screens/wallet/widget/fund_payment_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  const PaymentScreen({
    Key? key,
    required this.orderModel,
    required this.isCashOnDelivery,
    this.addFundUrl,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
  }) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  final String _baseUrl = '${AppConstants.baseUrl}/payment-mobile';
  double value = 0.0;
  double? _maximumCodOrderAmount;

  @override
  void initState() {
    super.initState();

    _initData();
  }

  void _initData() async {
    if (widget.addFundUrl == null || widget.addFundUrl!.isEmpty) {
      _maximumCodOrderAmount = await _getMaximumCodOrderAmount();
    }
  }

  Future<double?> _getMaximumCodOrderAmount() async {
    for (ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
      for (Modules m in zData.modules!) {
        if (m.id == Get.find<SplashController>().module!.id) {
          return m.pivot!.maximumCodOrderAmount;
        }
      }
    }
    return null; // Return null if not found
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url),mode: LaunchMode.externalNonBrowserApplication);
    } else {

      // Handle error gracefully (e.g., display error message)
      Get.snackbar('Error', 'Could not launch URL');
      //await launchUrl(Uri.parse(url),mode: LaunchMode.inAppWebView);
    }
  }
void handleUrlRedirection(String url) {
 // if (url.contains(RouteHelper.getProfileRoute())) {
    Navigator.pushNamed(context, RouteHelper.getProfileRoute());
 // }
}
  @override
  Widget build(BuildContext context) {
    _maximumCodOrderAmount ??= 0.0; // Set a default value if not retrieved

    String paymentUrl;
    if (widget.addFundUrl == null || widget.addFundUrl!.isEmpty) {
      paymentUrl ='${AppConstants.baseUrl}/payment-mobile?customer_id=${widget.orderModel.userId == 0 ? widget.guestId : widget.orderModel.userId}&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
    } else {
      paymentUrl = widget.addFundUrl!;
    }

    return WillPopScope(
      onWillPop: () => _exitApp().then((value) => value!),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBar(title: 'payment'.tr, onBackPressed: () => _exitApp()),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              _launchUrl(paymentUrl);
              // Navigator.pushNamed(context, RouteHelper.getInitialRoute());
               //RouteHelper.getOrderTrackingRoute(widget.orderModel.id, widget.contactNumber)
            },
            child: Text('proceed_to_checkout'.tr),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    if (widget.addFundUrl == null || widget.addFundUrl!.isEmpty) {
      return Get.dialog(PaymentFailedDialog(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: _maximumCodOrderAmount,
        orderType: widget.orderModel.orderType,
        isCashOnDelivery: widget.isCashOnDelivery,
      ));
    } else {
      return Get.dialog(const FundPaymentDialog());
    }
  }
}

