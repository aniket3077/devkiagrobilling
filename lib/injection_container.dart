import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Services
import 'services/notification_service.dart';
import 'services/printer_service.dart';
import 'services/sync_service.dart';

// Core
import 'core/network/network_info.dart';

// Data sources
import 'data/datasources/local/product_local_data_source.dart';
import 'data/datasources/remote/auth_remote_data_source.dart';
import 'data/datasources/remote/customer_remote_data_source.dart';
import 'data/datasources/remote/expense_remote_data_source.dart';
import 'data/datasources/remote/inventory_remote_data_source.dart';
import 'data/datasources/remote/product_remote_data_source.dart';
import 'data/datasources/remote/user_remote_data_source.dart';

// Repositories
import 'domain/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/customer_repository.dart';
import 'data/repositories/customer_repository_impl.dart';
import 'domain/repositories/employee_repository.dart';
import 'data/repositories/employee_repository_impl.dart';
import 'domain/repositories/expense_repository.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'domain/repositories/inventory_repository.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/report_repository.dart';
import 'data/repositories/report_repository_impl.dart';
import 'domain/repositories/user_repository.dart';
import 'data/repositories/user_repository_impl.dart';

// Blocs
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/billing/billing_bloc.dart';
import 'presentation/bloc/category/category_bloc.dart';
import 'presentation/bloc/customer/customer_bloc.dart';
import 'presentation/bloc/employee/employee_bloc.dart';
import 'presentation/bloc/expense/expense_bloc.dart';
import 'presentation/bloc/inventory/inventory_bloc.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/bloc/report/report_bloc.dart';
import 'presentation/bloc/user_management/user_management_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Hive initialization
  await Hive.initFlutter();
  final productBox = await Hive.openBox<Map>('products_box');

  // External dependencies
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<Box<Map>>(() => productBox);

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Services
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => PrinterService());
  sl.registerLazySingleton(() => SyncService(
    networkInfo: sl(),
    localDataSource: sl(),
    remoteDataSource: sl(),
  ));

  // Data Sources
  sl.registerLazySingleton<ProductLocalDataSource>(() => ProductLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl(), sl(), sl()));
  sl.registerLazySingleton<CustomerRemoteDataSource>(() => CustomerRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ExpenseRemoteDataSource>(() => ExpenseRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<InventoryRemoteDataSource>(() => InventoryRemoteDataSourceImpl(sl(), notificationService: sl()));
  sl.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(sl(), sl()));
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl(sl()));
  sl.registerLazySingleton<EmployeeRepository>(() => EmployeeRepositoryImpl(sl()));
  sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(sl()));
  sl.registerLazySingleton<InventoryRepository>(() => InventoryRepositoryImpl(sl()));
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl(sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  // Blocs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => BillingBloc(productRepository: sl()));
  sl.registerFactory(() => CategoryBloc(productRepository: sl()));
  sl.registerFactory(() => CustomerBloc(customerRepository: sl()));
  sl.registerFactory(() => EmployeeBloc(employeeRepository: sl()));
  sl.registerFactory(() => ExpenseBloc(expenseRepository: sl()));
  sl.registerFactory(() => InventoryBloc(inventoryRepository: sl()));
  sl.registerFactory(() => ProductBloc(productRepository: sl()));
  sl.registerFactory(() => ReportBloc(reportRepository: sl()));
  sl.registerFactory(() => UserManagementBloc(userRepository: sl()));
}
