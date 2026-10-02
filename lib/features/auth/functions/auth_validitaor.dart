validinput(String val, int min, int max, String type) {
  if (type == 'username') {
    if (val.isEmpty) {
      return "cant be Empty";
    }
  }
  if (type == 'email') {
    if (val.isEmpty) {
      return "Email can't be empty";
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val)) {
      return "Enter a valid email";
    }
  }
  if (type == 'password') {
    if (val.isEmpty) {
      return "Not valid password";
    }
  }
  if (val.length < min) {
    return "can't be less than $min";
  }
  if (val.length > max) {
    return "can't be larger than $max";
  }
  if (val.isEmpty) {
    return "can't be Empty";
  } else {
    return null;
  }
}
