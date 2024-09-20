import 'package:get/get.dart';
import 'local_strings_ar.dart';
import 'local_strings_en.dart';
import 'local_strings_fa.dart';
import 'local_strings_da.dart';

class LocalStrings extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    ...LocalStringsEn().keys,
    ...LocalStringsFa().keys,
    ...LocalStringsAr().keys,
    ...LocalStringsDa().keys,
  };
}
