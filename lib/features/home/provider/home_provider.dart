import 'package:flutter/foundation.dart';
import '../model/home_model.dart';

class HomeProvider with ChangeNotifier {
  HomeModel? _homeData;

  HomeModel? get homeData => _homeData;

  void updateHomeData(HomeModel newData) {
    _homeData = newData;
    notifyListeners();
  }

  void toggleSpace(int index) {
    if (_homeData != null) {
      // Implementation for toggling space status
      notifyListeners();
    }
  }
}
