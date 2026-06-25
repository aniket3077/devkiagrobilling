import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'shared/theme/app_theme.dart';
import 'presentation/pages/admin_shell.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/report/report_bloc.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/bloc/category/category_bloc.dart';
import 'presentation/bloc/customer/customer_bloc.dart';
import 'presentation/bloc/inventory/inventory_bloc.dart';
import 'presentation/bloc/user_management/user_management_bloc.dart';
import 'presentation/bloc/expense/expense_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<ReportBloc>()),
        BlocProvider(create: (context) => di.sl<ProductBloc>()),
        BlocProvider(create: (context) => di.sl<CategoryBloc>()),
        BlocProvider(create: (context) => di.sl<CustomerBloc>()),
        BlocProvider(create: (context) => di.sl<InventoryBloc>()),
        BlocProvider(create: (context) => di.sl<UserManagementBloc>()),
        BlocProvider(create: (context) => di.sl<ExpenseBloc>()),
      ],
      child: MaterialApp(
        title: 'Devki Agro Billing',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AdminShell(),
      ),
    );
  }
}
