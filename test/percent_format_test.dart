import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/utils/percent_format.dart';

bool _signFollowsDigits(String text) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: const TextStyle(fontSize: 20)),
    textDirection: TextDirection.rtl,
  )..layout();
  TextBox box(int index) => painter
      .getBoxesForSelection(
        TextSelection(baseOffset: index, extentOffset: index + 1),
      )
      .first;

  final sign = text.indexOf('%');
  return box(sign).left > box(sign - 1).left;
}

void main() {
  test('a bare percent inside Arabic text flips to the wrong side', () {
    expect(_signFollowsDigits('قيد المشاهدة · 57%'), isFalse);
  });

  test('percentLabel keeps the sign after the digits inside Arabic text', () {
    expect(_signFollowsDigits('قيد المشاهدة · ${57.percentLabel}'), isTrue);
    expect(_signFollowsDigits(40.percentLabel), isTrue);
  });

  test('percentLabel rounds', () {
    expect(57.4.percentLabel, contains('57%'));
    expect(56.6.percentLabel, contains('57%'));
  });
}
