class FieldValidator {
  static String? validateEmail(String ?value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter email address";
    }
    if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$").hasMatch(value)) {
      return "Invalid email address";
    }
    return null;
  }

  static String? validatePassword(String ?value) {
    if (value == null || value.trim().length < 6) {
      return "Password must be atleast 6 charecters long";
    }
    return null;
  }

  static String? validateConfirmPassword(String ?value, String ?value1) {
    if (value == null || value.trim().length < 6) {
      return "Confirm Password must be atleast 6 charecters long";
    }
    if (value != value1) {
      return "Password does not match";
    }
    return null;
  }


  static String? validateFullname(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your full name";
    }
    return null;
  }

}