import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/common/add_button_widget.dart';
import '../../../../routes/route_names.dart';
import 'sales_replacement_mobile_view.dart';
import 'sales_replacement_tab_view.dart';

class SalesReplacementScreen extends StatelessWidget {
  const SalesReplacementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: SalesReplacementMobileView(),
        tablet: SalesReplacementTabView(),
      ),
      floatingActionButton: AddButtonWidget(
        onTap: (){
          context.push(RouteNames.salesReplacementAdd);
        }
      ),
    );
  }
}