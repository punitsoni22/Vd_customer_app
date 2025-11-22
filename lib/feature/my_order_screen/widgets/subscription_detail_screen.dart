import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/models/subscription_detail_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final int subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  bool _isLoading = true;
  SubscriptionDetailModel? _subscriptionDetail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionDetail();
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

        setState(() {
          _subscriptionDetail = subscriptionDetail;
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
                    // Subscription Info Card
                    _buildSubscriptionInfoCard(),
                    SizedBox(height: 16.h),

                    // Customer Info Card
                    _buildCustomerInfoCard(),
                    SizedBox(height: 16.h),

                    // Delivery Schedule Card
                    _buildDeliveryScheduleCard(),
                    SizedBox(height: 16.h),

                    // Products List
                    _buildProductsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSubscriptionInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subscription #${_subscriptionDetail!.id}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _subscriptionDetail!.status == 1
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _subscriptionDetail!.status == 1 ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    color: _subscriptionDetail!.status == 1
                        ? Colors.green
                        : Colors.grey,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.category,
            'Type',
            _formatSubscriptionType(_subscriptionDetail!.subscriptionType),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            Icons.calendar_today,
            'Start Date',
            _formatDate(_subscriptionDetail!.startDate),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            Icons.event,
            'End Date',
            _formatDate(_subscriptionDetail!.endDate),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: AllColors.olivegreenColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Customer Information',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _subscriptionDetail!.customerName,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryScheduleCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AllColors.olivegreenColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Delivery Schedule',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12.h),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Products',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
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
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product ID: ${product.productId}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Variant ID: ${product.variantId}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AllColors.olivegreenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Qty: ${product.quantity}',
              style: TextStyle(
                fontSize: 13.sp,
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
        Icon(icon, size: 16.sp, color: Colors.grey.shade600),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFrequency(String frequency) {
    return frequency.replaceAll('_', ' ').toUpperCase();
  }

  String _formatSubscriptionType(String type) {
    return type.replaceAll('_', ' ').toUpperCase();
  }
}
