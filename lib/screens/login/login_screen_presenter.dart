import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/models/admin.dart';
import 'package:nooranidairyfarm_deliveryboy/models/user.dart';

abstract class LoginScreenContract {
  void onLoginSuccess(Admin user);
  void onLoginError(String errorTxt);
}

class LoginScreenPresenter {
  LoginScreenContract _view;
  RestDatasource api = new RestDatasource();
  LoginScreenPresenter(this._view);

  doLogin(String last_id,String user_id, String _otpcode) {
    api.login(last_id,user_id,_otpcode).then((Admin user) {
      _view.onLoginSuccess(user);
    }).catchError((Object error) => _view.onLoginError(error.toString()));
  }
}