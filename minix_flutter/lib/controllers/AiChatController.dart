
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiChatController extends GetxController {
  // 메시지 리스트 (화면에 보여줄 데이터)
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  // 🔑 API 키 (실제 앱에선 .env 파일 등에 숨겨야 합니다)
  final String _apiKey = 'AIzaSyA9iFhaOaN17Ox3qTu06h6snG0j4f4t0q8';

  // 🧠 [핵심] Gemini에게 미리 주입할 우리 앱만의 정보 (System Instruction)
  final String _systemInstruction = '''
    당신은 'withmovie' 영화 예매 앱의 똑똑하고 친절한 AI 시네마 매니저입니다.
    사용자와 친구처럼 영화에 대해 대화하되, 항상 정중하고 명확한 존댓말(한국어)을 사용하세요.
    
    [핵심 역할]
    1. 영화 전문가 모드: 사용자가 영화관 위치, 최신 개봉작 정보, 배우, 감독 등에 대해 물어보면 당신이 알고 있는 최신 정보를 바탕으로 충실히 답변해 주세요.
    2. 영화 추천: 사용자가 추천을 원하면 장르, 기분, 선호하는 스타일을 물어보고 그에 맞는 작품을 추천해 주세요.
    
    [★ 스포일러 및 줄거리 가이드라인 (매우 중요)]
    1. 스포일러 절대 금지: 영화의 결말, 반전, 핵심 범인 등 관람의 재미를 해칠 수 있는 내용은 절대 발설하지 마세요.
    2. 시놉시스 요약: 영화의 줄거리는 '공식 예고편'이나 '시놉시스'에 공개된 수준으로만 소개하세요. 초반 설정이나 흥미로운 갈등 요소까지만 이야기하여 관람 욕구를 자극해야 합니다. (예: "이 영화는 ~한 위기에 처한 주인공이 ~를 해결해 나가는 과정을 그립니다.")
    
    [앱 이용 규정 (고정 정보)]
    - 환불 규정: 상영 시작 20분 전까지 100% 환불 가능 (이후 불가).
    - 예매 방법: 홈 화면 > 영화 선택 > '예매하기' 버튼 클릭.
    - 휴무일: 매월 셋째 주 월요일 (전체 극장 정기 점검).
    - 할인 정보: 조조 영화(오전 10시 이전) 30% 할인.
    
    [대화 예외 처리]
    - 영화나 앱과 전혀 관련 없는 주제(정치, 주식, 연애 상담 등)는 "죄송합니다. 저는 영화 이야기만 할 수 있는 AI예요. 🎬"라고 정중히 거절하세요.
    - 규정에 없는 시스템 오류나 복잡한 환불 문제는 "해당 내용은 고객센터(1544-0000)로 문의 부탁드립니다."라고 안내하세요.
  ''';

  @override
  void onInit() {
    super.onInit();
    _initGemini();
  }

  void _initGemini() {
    try {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
      );

      // 대화 세션 시작 (여기서 미리 역할을 부여합니다)
      _chatSession = _model.startChat(
        history: [
          Content.text(_systemInstruction), // 첫 메시지로 규정을 가르침
          Content.model([TextPart('네, 알겠습니다. withmovie 상담원으로서 친절하게 안내하겠습니다.')]),
        ],
      );
      
      // 초기 환영 메시지
      messages.add(ChatMessage(
        text: "안녕하세요! withmovie AI 상담원입니다.\n예매 규정, 환불, 영화 추천 등 무엇이든 물어보세요! 🍿",
        isUser: false,
      ));
    } catch (e) {
      print("Gemini Init Error: $e");
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // 1. 사용자 메시지 화면에 추가
    messages.add(ChatMessage(text: text, isUser: true));
    textController.clear();
    isLoading.value = true;
    _scrollToBottom();

    try {
      // 2. Gemini에게 전송
      final response = await _chatSession.sendMessage(Content.text(text));
      final answer = (response.text ?? "").trim();

      // 3. AI 응답 화면에 추가
      if (answer.isNotEmpty) {
        messages.add(ChatMessage(text: answer, isUser: false));
      }
    } catch (e) {
      messages.add(ChatMessage(text: "오류가 발생했습니다: $e", isUser: false));
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0, 
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

// 간단한 메시지 모델 클래스
class ChatMessage {
  final String text;
  final bool isUser; // true: 나, false: AI

  ChatMessage({required this.text, required this.isUser});
}
