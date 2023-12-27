import 'package:flutter/material.dart';

import '../enums/EntryType.dart';
import '../models/SearchContent.dart';
import '../custom_materials/theme.dart';
import 'EntryBox.dart';

class SearchArticleWindow extends StatefulWidget {
  const SearchArticleWindow({super.key, required this.onSearchChanged, required this.searchContent});


  final Function(SearchContent) onSearchChanged;
  final SearchContent searchContent;
  @override
  State<SearchArticleWindow> createState() => _SearchArticleWindowState();
}

class _SearchArticleWindowState extends State<SearchArticleWindow> {

  TextEditingController _nameSearchController = TextEditingController();
  TextEditingController _alphaSearchController = TextEditingController();
  TextEditingController _numberSearchController = TextEditingController();
  TextEditingController _subAlphaSearchController = TextEditingController();

  @override
  void initState() {
    _nameSearchController.addListener(() {
      widget.searchContent.name = _nameSearchController.text;
      widget.onSearchChanged(widget.searchContent);
    });
    _alphaSearchController.addListener(() {
      String alpha = _alphaSearchController.text.toUpperCase();
      if(RegExp(r"^[A-Za-z]?$").hasMatch(alpha)){
        _alphaSearchController.value = _alphaSearchController.value.copyWith(text: alpha);
        widget.searchContent.alpha = alpha;
      }else{
        _alphaSearchController.text = "";
        widget.searchContent.alpha = "";
      }
      widget.onSearchChanged(widget.searchContent);
    });
    _numberSearchController.addListener(() {
      String number = _numberSearchController.text;
      if(RegExp(r"^[0-9]*$").hasMatch(number)){
        widget.searchContent.number = number;
        _numberSearchController.value = _numberSearchController.value.copyWith(
            text: number, selection: TextSelection(baseOffset: number.length, extentOffset: number.length)
        );
      }else if (number.isNotEmpty){
        String previousValue = number.substring(0, number.length-1);
        _numberSearchController.value = _numberSearchController.value.copyWith(
            text: previousValue, selection: TextSelection(baseOffset: previousValue.length, extentOffset: previousValue.length)
        );
      }
      widget.onSearchChanged(widget.searchContent);
    });
    _subAlphaSearchController.addListener(() {
      String subAlpha = _subAlphaSearchController.text.toLowerCase();
      if(RegExp(r"^[A-Za-z]$").hasMatch(subAlpha)){
        _subAlphaSearchController.value = _subAlphaSearchController.value.copyWith(text: subAlpha);
        widget.searchContent.subAlpha = subAlpha;
      }else{
        _subAlphaSearchController.text = "";
        widget.searchContent.subAlpha = "";
      }
      widget.onSearchChanged(widget.searchContent);
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameSearchController.dispose();
    _alphaSearchController.dispose();
    _numberSearchController.dispose();
    _subAlphaSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(left:10, right: 10),
      child: Container(
        decoration: BoxDecoration(
            color: customColors.cardQuarterTransparency!,
            borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Recherche d'articles", textAlign: TextAlign.center,),
            Row(
              children: [
                EntryBox(orderEntryType: QuaiEntry.text, maxLength: 50, placeholder: "Nom d'un article", textEditingController: _nameSearchController, marginRight: 10, marginLeft: 5,),
              ],
            ),
            Row(
              children: ["Alphabet","Numéro","Sous-alpha"].map((headerText){
                return Expanded(child: Text(headerText,textAlign: TextAlign.center,));
              }).toList(),
            ),
            Row(
              children: [
                EntryBox(orderEntryType: QuaiEntry.alpha, maxLength: 1, placeholder: "A-Z", textEditingController: _alphaSearchController, marginLeft: 10,),
                EntryBox(orderEntryType: QuaiEntry.number, maxLength: 3, placeholder: "N°", textEditingController: _numberSearchController, marginLeft: 5, marginRight: 5,),
                EntryBox(orderEntryType: QuaiEntry.subAlpha, maxLength: 1, placeholder: "a-z", textEditingController: _subAlphaSearchController, marginRight: 10,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}