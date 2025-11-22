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
                'Order #${_orderDetail!.id}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(_orderDetail!.status),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _orderDetail!.status,
                  style: TextStyle(
                    color: _getStatusTextColor(_orderDetail!.status),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Placed on: ${_formatDate(_orderDetail!.createdOn)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final address = _orderDetail!.address;
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
                Icons.location_on,
                color: AllColors.olivegreenColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Delivery Address',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            address.fullAddress,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
          SizedBox(height: 4.h),
          Text(
            '${address.city}, ${address.state} - ${address.postalCode}',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
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
            'Order Items',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
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
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 60.w,
                    height: 60.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60.w,
                      height: 60.h,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 60.w,
                    height: 60.h,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.productName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${item.productVariants.quantityinml} ml',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.totalPrice}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
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
            'Price Details',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _buildPriceRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          if (discount > 0) ...[
            SizedBox(height: 8.h),
            _buildPriceRow(
              'Discount',
              '-₹${discount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          ],
          Divider(height: 24.h),
          _buildPriceRow(
            'Total',
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
