import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/network/network_info.dart';
import '../data/datasources/local/product_local_data_source.dart';
import '../data/datasources/remote/product_remote_data_source.dart';

class SyncService {
  final NetworkInfo networkInfo;
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;
  
  StreamSubscription? _connectivitySubscription;

  SyncService({
    required this.networkInfo,
    required this.localDataSource,
    required this.remoteDataSource,
  });

  void init() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((results) {
      final isConnected = !results.contains(ConnectivityResult.none);
      if (isConnected) {
        syncPendingData();
      }
    });
  }

  Future<void> syncPendingData() async {
    // 1. Fetch data from local that hasn't been synced yet
    // In a real app, you would have an 'isSynced' flag or a 'pending_sync' box
    print('Checking for pending data to sync...');
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
