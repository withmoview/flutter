import 'package:get/get.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthController extends GetxController{
  final _api = Get.find<ApiService>();

  final Rx<User?> user = Rx<User?>(null);

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get isLoggedIn => user.value != null;

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async{
    isLoading.value =true;
    error.value = '';

    try{
      final res = await _api.register(email: email, password: password, name: name, username: username,);
      isLoading.value = false;

      if(res.statusCode == 201){
        return true;
      }else{
        error.value = res.body['detail'] ?? res.body['message'] ?? '회원가입 실패';
        return false;
      }
    }catch(e){
      isLoading.value = false;
      error.value = '네트워크 오류';
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async{
    isLoading.value = true;
    error.value = '';

    try{
      final userDate = await _api.login(email: email, password: password);
      isLoading.value = false;

      if(userDate != null){
        user.value = User.fromJson(userDate);
        return true;
      } else{
        error.value = '이메일 또는 비밀번호가 올바르지 않습니다';
        return false;
      }
    } catch (e, s) {
      isLoading.value = false;
      print('LOGIN ERROR: $e');
      print(s);
      error.value = e.toString(); // 일단 진짜 원인 보이게
      return false;
    }
  }

  void logout(){
    user.value = null;
    _api.clearToken();
    Get.offAllNamed('/');
  }

  // 서버에서 최신 프로필 정보 가져오기
  Future<void> loadProfile() async {
  try {
    final data = await _api.getMyProfile();
    if (data != null) {
      user.value = User.fromJson(data);
    }
  } catch (e) {
    Get.snackbar('오류', '프로필을 불러올 수 없습니다');
  }
  }
}