class Utils {
  static String getUserName(String email) {
    return "live:${email.split('@')[0]}";
  }

  static String getIntials(String displayName) {
    List<String> nameSplit = displayName.split(" ");
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[1][0];
    return firstNameInitial.toUpperCase()+lastNameInitial.toUpperCase();
  }
}