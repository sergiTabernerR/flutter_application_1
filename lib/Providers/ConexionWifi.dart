import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> chcekInternetConnectionv2() async {
  var connectivyResult = await (Connectivity().checkConnectivity());
  if (connectivyResult == ConnectivityResult.mobile ||
      connectivyResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}
