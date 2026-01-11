import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/models/order_detail_model.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/services/signedurl.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  OrderDetailModel? _orderDetail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Api.post('getSpecificOrder', {
        'data': {'orderId': widget.orderId},
      });

      if (response['success'] == true && response['data'] != null) {
        final orderDetail = OrderDetailModel.fromJson(response['data']);

        // Generate signed URLs for product images
        for (var cartItem in orderDetail.cart.cartDetails) {
          for (var image in cartItem.product.images) {
            if (image.imageUrl.isNotEmpty) {
              try {
                image.signedUrl = await generateSignedUrl(image.imageUrl);
              } catch (e) {
                print('Error generating signed URL: $e');
              }
            }
          }
        }

        setState(() {
          _orderDetail = orderDetail;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load order details';
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
        title: 'Order Details',
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
                    onPressed: _fetchOrderDetail,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _orderDetail == null
          ? const Center(child: Text('No order details found'))
          : RefreshIndicator(
              onRefresh: _fetchOrderDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Status Card
                    _buildStatusCard(),
                    SizedBox(height: 16.h),

                    // Delivery Address Card
                    _buildAddressCard(),
                    SizedBox(height: 16.h),

                    // Products List
                    _buildProductsList(),
                    SizedBox(height: 16.h),

                    // Price Summary
                    _buildPriceSummary(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    'Order ID',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '#${_orderDetail!.id}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(_orderDetail!.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: _getStatusColor(_orderDetail!.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _orderDetail!.status,
                  style: TextStyle(
                    color: _getStatusTextColor(_orderDetail!.status),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade100),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(width: 8.w),
              Text(
                'Placed on: ${_formatDate(_orderDetail!.createdOn)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final address = _orderDetail!.address;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: AllColors.olivegreenColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: AllColors.olivegreenColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Delivery Address',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.fullAddress,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${address.city}, ${address.state} - ${address.postalCode}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          ...(_orderDetail!.cart.cartDetails
              .map((item) => _buildProductItem(item))
              .toList()),
        ],
      ),
    );
  }

  Widget _buildProductItem(CartDetailItem item) {
    final imageUrl = item.product.images.isNotEmpty
        ? (item.product.images.first.signedUrl ??
            item.product.images.first.imageUrl)
        : '';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey.shade400),
                    ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.productName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '${item.productVariants.quantityinml} ml',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'x ${item.quantity}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '₹${item.totalPrice}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AllColors.olivegreenColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final subtotal = double.tryParse(_orderDetail!.totalAmount) ?? 0.0;
    final discount = double.tryParse(_orderDetail!.discountAmount) ?? 0.0;
    final total = subtotal - discount;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          _buildPriceRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          if (discount > 0) ...[
            SizedBox(height: 12.h),
            _buildPriceRow(
              'Discount',
              '-₹${discount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          ],
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 16.h),
          _buildPriceRow(
            'Total Amount',
            '₹${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isDiscount
                ? Colors.green
                : isTotal
                ? AllColors.olivegreenColor
                : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return Colors.blue.shade50;
      case 'PENDING':
        return Colors.orange.shade50;
      case 'OUT FOR DELIVERY':
        return Colors.blue.shade50;
      case 'CANCELLED':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'OUT FOR DELIVERY':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString.split('T').first;
    }
  }
}
