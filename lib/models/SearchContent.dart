class SearchContent{
  String alpha;
  String number;
  String subAlpha;
  String name;

  SearchContent.empty() : alpha = "", number = "", subAlpha="", name="";

  @override
  String toString() {
    return "$alpha$number$subAlpha $name";
  }
}