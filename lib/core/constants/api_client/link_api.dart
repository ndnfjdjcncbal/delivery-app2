class ApiConstants {
  static const String Api = "http://20.0.7.230/ecommerceapp";
  ////////////////////////auth//////////////////////////////
  static const String signupl = "$Api/Delivery_app/auth/signin.php";
  static const String verifiedcodesignup =
      "$Api/Delivery_app/auth/verfiecationcode.php";
  static const String resendcode =
      "$Api/Delivery_app/auth/forgetpassword/resendcode.php";
  static const String login = "$Api/Delivery_app/auth/login.php";
  ////////////////////////forgetpassword//////////////////////////////
  static const String forgetpasswordlink =
      "$Api/Delivery_app/auth/forgetpassword/forgetpassword.php";
  static const String checkcodelogin =
      "$Api/Delivery_app/auth/forgetpassword/checkcodelogin.php";
  static const String resetpass =
      "$Api/Delivery_app/auth/forgetpassword/resetpassword.php";
  ////////////////////////orders/////////////////////////

  static const String getavailableorders =
      "$Api/Delivery_app/orders/get_available_orders.php";
  static const String getmyorders =
      "$Api/Delivery_app/orders/get_my_orders.php";
  static const String updateorderstatus =
      "$Api/Delivery_app/orders/update_order_status.php";
  static const String deliverorder =
      "$Api/Delivery_app/orders/deliver_order.php";
  static const String getorderaddress =
      "$Api/Delivery_app/orders/get_order_address.php";
}
