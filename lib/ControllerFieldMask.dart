import 'dart:async';

import 'package:flutter/cupertino.dart';

class FieldMaskController {
  List<String> removeInsertPrefix = [];
  String allowedChars;
  TextEditingController controller = TextEditingController();
  String mask;
  String replaceChar;
  String text;
  int selection;
  int replaceCharsCount = 0;
  int firstReplaceCharIndex = 0;
  Timer selectionController;

  FieldMaskController(this.mask, this.replaceChar, this.allowedChars) {
    text = mask;
    //  Выставляем курсор на первый подстановочный символ
    firstReplaceCharIndex = mask.indexOf(replaceChar);
    if (firstReplaceCharIndex == -1) firstReplaceCharIndex = 0;
    selection = firstReplaceCharIndex;

    for (int i = 0; i < mask.length; i++)
      if (mask[i] == replaceChar) replaceCharsCount++;

    selectionController = new Timer.periodic(const Duration(milliseconds: 50), (Timer timer){
      if(controller.value.selection.start < firstReplaceCharIndex)
        controller.value = controller.value.copyWith(
          text: text,
          selection: TextSelection(baseOffset: firstReplaceCharIndex, extentOffset: firstReplaceCharIndex),
          composing: TextRange.empty,
        );

    });

    updateText();
  }

  void setText(String text){
    controller.value = controller.value.copyWith(
      text: text,
      selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
      composing: TextRange.empty,
    );
  }

  void updateText() {
    controller.value = controller.value.copyWith(
      text: text,
      selection: TextSelection(baseOffset: selection, extentOffset: selection),
      composing: TextRange.empty,
    );
  }

  void initState() {
    controller.addListener(() {
      //  Если текст не именился, то ничего делать не нужно
      if (controller.text == text){
        if(controller.text.contains("+7 (___)___-__-__")){
          selection = 4;
          updateText();
          return;
        }
        return;}

      InsertInfo insertInfo =
          getInsertedText(controller.text, text, controller.selection.start);

      int removeTile = text.length - controller.text.length;
      int insertStartIndex =
          controller.selection.start - insertInfo.insertedTextRaw.length;
      int insertIndex = 0;

      //  Уникальный случай. Пользователь вставил текст когда курсор был в конце маски
      //  Эта ситуация не обрабатывается на сайте, но мне кажется важно для мобильных приложений
      //  Например пользователю может быть удобно вставить номер телефона зажав любую точку в поле (курсор перепрыгнет в конец маски)
      if (insertStartIndex == mask.length) {
        //  Переводим курсор к первому подстановочному символу и продолжаем вставку текста как обычно
        for (int i = 0; i < text.length; i++)
          if (text[i] == replaceChar) {
            insertStartIndex = i;
            break;
          }
      }

      // Удаляем символы которые стер пользователь пропуская символы маски
      for (int i = controller.selection.start + (removeTile - 1);
          i > -1 && removeTile > 0;
          i--) {
        if (mask[i] != replaceChar) continue;
        text = text.replaceRange(i, i + 1, mask[i]);
        selection = i;
        removeTile--;
      }

      //  Добавляем вставленные сиволы в текст пропуская символы маски
      for (int i = insertStartIndex;
          i < mask.length && insertIndex < insertInfo.insertedText.length;
          i++) {
        if (mask[i] != replaceChar) continue;
        text = text.replaceRange(
            i, i + 1, "${insertInfo.insertedText[insertIndex]}");
        selection = i + 1;
        insertIndex++;
      }

      //  Если курсор уперся в символ маски, то перепрыгиваем его, но только если небыло удаления символов (при вводе).
      if (removeTile < 1) {
        while (selection < text.length &&
            selection < mask.length &&
            mask[selection] != replaceChar) selection++;
      }

      //  Обновляем текст и положение курсора в поле
      updateText();
    });
  }

  InsertInfo getInsertedText(
      String newText, String oldText, int currentSelection) {
    int skip = 0;
    for (int i = 0; i < newText.length && i < oldText.length; i++) {
      if (newText[i] != oldText[i]) break;
      if (skip >= currentSelection) break;
      skip++;
    }
    InsertInfo insertInfo = InsertInfo();
    if (currentSelection < skip) return insertInfo;
    //  Получаев весь вставленный текст
    insertInfo.insertedTextRaw = newText.substring(skip, currentSelection);
    //  Удаляем все не разрешенные сиволы
    insertInfo.insertedText = "";
    for (int i = 0; i < insertInfo.insertedTextRaw.length; i++)
      if (allowedChars.contains(insertInfo.insertedTextRaw[i]))
        insertInfo.insertedText += insertInfo.insertedTextRaw[i];

    //  Удаляем префиксы. Это нужно например есль пользователь вставит номер телефона не 9998887766 а +79998887766. +7 удалится, т.к. это часть маски.
    if (insertInfo.insertedText.length > replaceCharsCount) {
      int dif = insertInfo.insertedText.length - replaceCharsCount;
      for (String prefix in removeInsertPrefix)
        if (prefix.length == dif &&
            insertInfo.insertedText.startsWith(prefix)) {
          insertInfo.insertedText = insertInfo.insertedText.substring(dif);
          break;
        }
    }

    return insertInfo;
  }

  void addRemoveInsertPrefix(prefix) {
    removeInsertPrefix.add(prefix);
  }

  String getTextWithoutMask() {
    String result = "";
    for (int i = 0; i < text.length; i++) {
      if (mask[i] == replaceChar && text[i] != replaceChar) result += text[i];
    }
    return result;
  }

  void dispose() {
    controller.dispose();
    selectionController.cancel();
  }


}

//
//  Support
//

class InsertInfo {
  String insertedTextRaw = "";
  String insertedText = "";
}
