class Constants {

  static const int BMI_UNDERWEIGHT = 2001;
  static const int BMI_NORMAL = 2002;
  static const int BMI_OVERWEIGHT = 2003;
  static const int BMI_OBESE = 2004;
}

enum FirebaseAuthState {
  AUTH_STATUS_SUCCESS,
  AUTH_STATUS_CANCELLED,
  AUTH_STATUS_ERROR
}
enum AuthState {
  AUTH_STATUS_LOGGED_IN,
  AUTH_STATUS_NOT_LOGGED_IN,
  AUTH_STATUS_FORCE_LOGOUT
}
