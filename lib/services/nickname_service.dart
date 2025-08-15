import 'package:shared_preferences/shared_preferences.dart';
import 'ranking_service.dart';

/// 닉네임 관리 서비스
class NicknameService {
  static const String _nicknameKey = 'player_nickname';
  
  /// 저장된 닉네임 조회
  static Future<String?> getSavedNickname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_nicknameKey);
    } catch (e) {
      return null;
    }
  }
  
  /// 닉네임 저장
  static Future<bool> saveNickname(String nickname) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_nicknameKey, nickname);
    } catch (e) {
      return false;
    }
  }
  
  /// 닉네임 삭제 (초기화)
  static Future<bool> clearNickname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_nicknameKey);
    } catch (e) {
      return false;
    }
  }
  
  /// 닉네임 유효성 검사
  static String? validateNickname(String nickname) {
    if (nickname.isEmpty) {
      return '닉네임을 입력해주세요.';
    }
    
    if (nickname.length < 2) {
      return '닉네임은 2자 이상이어야 합니다.';
    }
    
    if (nickname.length > 12) {
      return '닉네임은 12자 이하여야 합니다.';
    }
    
    // 특수문자 및 공백 검사
    final regex = RegExp(r'^[a-zA-Z0-9가-힣]+$');
    if (!regex.hasMatch(nickname)) {
      return '닉네임은 한글, 영문, 숫자만 사용 가능합니다.';
    }
    
    // 금지어 검사
    final bannedWords = ['관리자', 'admin', 'test', '테스트', 'null', 'undefined'];
    final lowercaseNickname = nickname.toLowerCase();
    for (final word in bannedWords) {
      if (lowercaseNickname.contains(word.toLowerCase())) {
        return '사용할 수 없는 닉네임입니다.';
      }
    }
    
    return null; // 유효함
  }
  
  /// 닉네임 중복 검사 (온라인)
  static Future<bool> isNicknameAvailable(String nickname) async {
    try {
      return await RankingService.isNicknameAvailable(nickname);
    } catch (e) {
      return false;
    }
  }
  
  /// 닉네임 등록 (유효성 검사 + 중복 검사 포함)
  static Future<String?> registerNickname(String nickname) async {
    // 1. 유효성 검사
    final validationError = validateNickname(nickname);
    if (validationError != null) {
      return validationError;
    }
    
    // 2. 중복 검사
    final isAvailable = await isNicknameAvailable(nickname);
    if (!isAvailable) {
      return '이미 사용 중인 닉네임입니다.';
    }
    
    // 3. 로컬 저장
    final saved = await saveNickname(nickname);
    if (!saved) {
      return '닉네임 저장에 실패했습니다.';
    }
    
    return null; // 성공
  }
  
  /// 닉네임이 설정되어 있는지 확인
  static Future<bool> hasNickname() async {
    final nickname = await getSavedNickname();
    return nickname != null && nickname.isNotEmpty;
  }
}