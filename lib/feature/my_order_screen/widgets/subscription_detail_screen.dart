import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/models/subscription_detail_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/services/signedurl.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/validators/date_validator.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

import '../../../core/utils/formatters.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final int subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  SubscriptionDetailModel? _subscriptionDetail;
  String? _errorMessage;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionDetail();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchSubscriptionDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Api.post('getSpecificSubscription', {
        'data': {'id': widget.subscriptionId},
      });

      if (response['success'] == true && response['data'] != null) {
        final subscriptionDetail = SubscriptionDetailModel.fromJson(
          response['data'],
        );

        // Generate signed URLs for product images (if any)
        final List<SubscriptionProductDetail> updated = [];
        for (var p in subscriptionDetail.products) {
          if (p.imageUrl != null && p.imageUrl!.isNotEmpty) {
            String signed = '';
            try {
              signed = await generateSignedUrl(p.imageUrl!);
            } catch (_) {
              signed = '';
            }
            if (signed.isNotEmpty) {
              updated.add(p.copyWith(signedUrl: signed));
            } else {
              updated.add(p);
            }
          } else {
            updated.add(p);
          }
        }

        final updatedSubscription = subscriptionDetail.copyWith(
          products: updated,
        );

        setState(() {
          _subscriptionDetail = updatedSubscription;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Failed to load subscription details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSubscriptionStatus(int statusValue) async {
    if (_subscriptionDetail == null) return;

    setState(() {
      _isUpdatingStatus = true;
      _errorMessage = null;
    });

    try {
      final reason = _reasonController.text.trim();
      if ((statusValue == 0 || statusValue == 2) && reason.isEmpty) {
        if (mounted) {
          MySnackBar.showSnackBar(
            context,
            'Please enter reason for status change',
          );
        }
        return;
      }

      final response = await Api.post('updateSubscriptionStatus', {
        'data': {
          'id': _subscriptionDetail!.id,
          'status': statusValue,
          if (reason.isNotEmpty) 'reasonForStatus': reason,
        },
      });

      if (response['success'] == true) {
        MySnackBar.showSnackBar(context, 'Subscription updated');
        _reasonController.clear();
        await _fetchSubscriptionDetail();
      } else {
        MySnackBar.showSnackBar(
          context,
          response['message'] ?? 'Failed to update status',
        );
      }
    } catch (e) {
      MySnackBar.showSnackBar(context, 'Error updating subscription: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  String _statusLabel(int status) {
    switch (status) {
      case 1:
        return 'ACTIVE';
      case 0:
        return 'PAUSED';
      case 2:
        return 'CANCELLED';
      case 3:
        return 'EXPIRED';
      default:
        return 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Subscription Details',
        showBack: true,
        titleAlignment: BarTitleAlignment.center,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AllColors.olivegreenColor,
                ),
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _fetchSubscriptionDetail,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _subscriptionDetail == null
          ? const Center(child: Text('No subscription details found'))
          : RefreshIndicator(
              onRefresh: _fetchSubscriptionDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubscriptionInfoCard(),
                    SizedBox(height: 16.h),

                    _buildSubscriptionActionsCard(),
                    SizedBox(height: 16.h),

                    _buildCustomerInfoCard(),
                    SizedBox(height: 16.h),

                    _buildDeliveryScheduleCard(),
                    SizedBox(height: 16.h),

                    _buildProductsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSubscriptionActionsCard() {
    final sub = _subscriptionDetail;
    if (sub == null) return const SizedBox();

    final canPause = sub.status == 1;
    final canResume = sub.status == 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Subscription',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Note / reason for status change',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AllColors.olivegreenColor),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: (!canPause || _isUpdatingStatus)
                      ? null
                      : () => _updateSubscriptionStatus(0),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: canPause
                            ? AllColors.olivegreenColor
                            : Colors.grey.shade300,
                      ),
                      color: canPause
                          ? AllColors.olivegreenColor.withValues(alpha: 0.08)
                          : Colors.grey.shade100,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pause_circle_filled,
                          size: 18.sp,
                          color: canPause
                              ? AllColors.olivegreenColor
                              : Colors.grey.shade500,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _isUpdatingStatus && canPause ? 'Pausing...' : 'Pause',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: canPause
                                ? AllColors.olivegreenColor
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: InkWell(
                  onTap: (!canResume || _isUpdatingStatus)
                      ? null
                      : () => _updateSubscriptionStatus(1),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: canResume
                            ? AllColors.olivegreenColor
                            : Colors.grey.shade300,
                      ),
                      color: canResume
                          ? AllColors.olivegreenColor.withValues(alpha: 0.08)
                          : Colors.grey.shade100,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          size: 18.sp,
                          color: canResume
                              ? AllColors.olivegreenColor
                              : Colors.grey.shade500,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _isUpdatingStatus && canResume
                              ? 'Resuming...'
                              : 'Resume',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: canResume
                                ? AllColors.olivegreenColor
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription ID',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '#${_subscriptionDetail!.id}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _subscriptionDetail!.status == 1
                      ? Colors.green.shade50
                      : _subscriptionDetail!.status == 0
                      ? Colors.orange.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: _subscriptionDetail!.status == 1
                        ? Colors.green.shade200
                        : _subscriptionDetail!.status == 0
                        ? Colors.orange.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  _statusLabel(_subscriptionDetail!.status),
                  style: TextStyle(
                    color: _subscriptionDetail!.status == 1
                        ? Colors.green.shade700
                        : _subscriptionDetail!.status == 0
                        ? Colors.orange.shade800
                        : Colors.red.shade700,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Divider(color: Colors.grey[400]),
          SizedBox(height: 6.h),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Start Date',
            DateValidator.formatDate(_subscriptionDetail!.startDate.toString()),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.event_outlined,
            'End Date',
            DateValidator.formatDate(_subscriptionDetail!.endDate.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AllColors.olivegreenColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AllColors.olivegreenColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Customer Information',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            _subscriptionDetail!.customerName,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryScheduleCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AllColors.olivegreenColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule,
                  color: AllColors.olivegreenColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Delivery Schedule',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildInfoRow(
            Icons.repeat,
            'Frequency',
            _formatFrequency(_subscriptionDetail!.deliveryFrequencyType),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Products',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          ...(_subscriptionDetail!.products
              .map((product) => _buildProductItem(product))
              .toList()),
        ],
      ),
    );
  }

  Widget _buildProductItem(SubscriptionProductDetail product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 80.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.white,
                    image: (product.signedUrl ?? product.imageUrl) != null
                        ? DecorationImage(
                            image: NetworkImage(
                              product.signedUrl ?? product.imageUrl!,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName ?? 'Product ${product.productId}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        product.price != null
                            ? 'Price: \u20B9${product.price}'
                            : 'Variant: ${product.variantId}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AllColors.olivegreenColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              product.quantityInMl != null
                  ? '${formatVolume(product.quantityInMl!).toUpperCase()} x ${product.quantity}'
                  : 'Qty: ${product.quantity}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AllColors.olivegreenColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey),
        SizedBox(width: 12.w),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _formatFrequency(String frequency) {
    return frequency.replaceAll('_', ' ').toUpperCase();
  }
}
