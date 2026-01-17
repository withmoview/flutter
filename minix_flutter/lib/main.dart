import 'package:flutter/material.dart';
import 'package:minix_flutter/controllers/AiChatController.dart';
import 'package:minix_flutter/controllers/TweetController.dart';
import 'package:minix_flutter/controllers/auth_controller.dart';
import 'package:minix_flutter/controllers/main_controller.dart';
import 'package:minix_flutter/controllers/meeting_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get/get.dart';
import './app.dart';
import 'services/api_service.dart';
import 'package:minix_flutter/services/tmdb_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  await GetStorage.init();
  await initializeDateFormatting();

    //의존성 주입
  Get.put(ApiService());
  Get.put(AuthController());
  Get.lazyPut(() => TweetController(),fenix: true);
  Get.put(AiChatController());
  Get.put(MeetingController(), permanent: true);
  Get.put(MainController(), permanent: true);
  Get.put(TmdbService('eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhYWZjYTRjNGQzYjgwOTBiMDRiZGJjNjg0YmY3MDYzNiIsIm5iZiI6MTc2ODM3NjQ5Mi4zMzcsInN1YiI6IjY5Njc0OGFjNGFlNzJhMmViNDcwMzVjNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.PbfdVqZAv18x3lSuk6ePI-jDTPTKB2YPk2SaRq8Gqw0'));

  timeago.setLocaleMessages('ko', timeago.KoMessages());

  runApp(const MyApp());
}