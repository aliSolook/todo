import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';

class WhereFinder extends MatchFinder {
  final bool Function(Element candidate) test;

  WhereFinder(this.test);

  @override
  String get description => 'matches test';

  @override
  bool matches(Element candidate) => test(candidate);
}
