import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/address.model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/provider/subscription_provider.dart'
    as subscription;
import 'package:vd_customer_app/feature/subscription_date_screen/widgets/address_bottom_sheet.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<subscription.SubscriptionProvider>().getAllAddresses(
        context,
      );
    });
  }

  Future<void> _addNewAddress() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddressBottomSheet(),
    );
    if (updated == true) {
      if (!mounted) return;
      await context.read<subscription.SubscriptionProvider>().getAllAddresses(
        context,
      );
    }
  }

  Future<void> _editAddress(AddressModel address) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddressBottomSheet(editAddress: address),
    );
    if (updated == true) {
      if (!mounted) return;
      await context.read<subscription.SubscriptionProvider>().getAllAddresses(
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<subscription.SubscriptionProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(
        title: 'Address Book',
        titleAlignment: BarTitleAlignment.center,
        showBack: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context
              .read<subscription.SubscriptionProvider>()
              .getAllAddresses(context);
        },
        child: provider.isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : provider.addresses.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                children: [
                  SizedBox(height: 60.h),
                  Icon(
                    Icons.location_off_outlined,
                    size: 72.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: Text(
                      'No saved addresses found',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  OutlinedButton.icon(
                    onPressed: _addNewAddress,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: AllColors.iconColor),
                      foregroundColor: AllColors.iconColor,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                itemCount: provider.addresses.length + 1,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (index == provider.addresses.length) {
                    return OutlinedButton.icon(
                      onPressed: _addNewAddress,
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Address'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: AllColors.iconColor),
                        foregroundColor: AllColors.iconColor,
                      ),
                    );
                  }

                  final address = provider.addresses[index];
                  return Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AllColors.iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: AllColors.iconColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Address',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (address.isDefault) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        'Default',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                address.fullAddress,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[800],
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${address.city}, ${address.state} - ${address.postalCode}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _editAddress(address),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
