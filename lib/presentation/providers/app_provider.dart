import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/models.dart';
import '../../data/repositories/api_repository.dart';

enum LoadingState { initial, loading, loaded, error }

class AppProvider extends ChangeNotifier {
  final ApiRepository _repository;

  AppProvider({ApiRepository? repository})
      : _repository = repository ?? ApiRepository(baseUrl: AppConstants.baseUrl);

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Stats _stats = Stats();
  Stats get stats => _stats;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  List<Product> _products = [];
  List<Product> get products => _products;

  List<Feedback> _feedbacks = [];
  List<Feedback> get feedbacks => _feedbacks;

  List<String> _logs = [];
  List<String> get logs => _logs;

  LoadingState _state = LoadingState.initial;
  LoadingState get state => _state;

  String _error = '';
  String get error => _error;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  void setTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  Future<void> loadAllData() async {
    _state = LoadingState.loading;
    _error = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.checkHealth(),
        _repository.getStats(),
        _repository.getLogs(),
        _repository.getOrders().catchError((_) => <Order>[]),
        _repository.getProducts().catchError((_) => <Product>[]),
        _repository.getFeedbacks().catchError((_) => <Feedback>[]),
      ]);

      _isOnline = results[0] as bool;
      _stats = results[1] as Stats;
      _logs = results[2] as List<String>;
      _orders = results[3] as List<Order>;
      _products = results[4] as List<Product>;
      _feedbacks = results[5] as List<Feedback>;

      _state = LoadingState.loaded;
    } catch (e) {
      _state = LoadingState.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> refreshData() => loadAllData();

  Future<bool> confirmOrder(String orderId) async {
    try {
      await _repository.confirmPayment(orderId);
      await loadAllData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId, String reason) async {
    try {
      await _repository.rejectPayment(orderId, reason);
      await loadAllData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> setTracking(String orderId, String code) async {
    try {
      await _repository.setTrackingCode(orderId, code);
      await loadAllData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> restartBot() async {
    try {
      await _repository.restartBot();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  int get pendingOrdersCount => _orders.where((o) => o.status == 'pending_payment').length;
  int get paidOrdersCount => _orders.where((o) => o.status == 'paid').length;
  int get shippedOrdersCount => _orders.where((o) => o.status == 'shipped').length;
  int get unreadFeedbacksCount => _feedbacks.where((f) => !f.isRead).length;
}