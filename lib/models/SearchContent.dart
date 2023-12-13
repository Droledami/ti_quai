class SearchContent {
  String alpha;
  String number;
  String subAlpha;
  String name;

  SearchContent.empty()
      : alpha = "",
        number = "",
        subAlpha = "",
        name = "";

  @override
  String toString() {
    return "$alpha$number$subAlpha $name";
  }

  bool isEmpty() {
    if (alpha.replaceAll(" ", "") == "" &&
        number.replaceAll(" ", "") == "" &&
        subAlpha.replaceAll(" ", "") == "" &&
        name.replaceAll(" ", "") == "") {
      return true;
    } else {
      return false;
    }
  }
}
