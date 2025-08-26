import 'package:flutter/material.dart';
import '../services/nickname_service.dart';

class NicknameRegistrationScreen extends StatefulWidget {
  final VoidCallback onNicknameRegistered;
  final VoidCallback? onCancel;

  const NicknameRegistrationScreen({
    super.key,
    required this.onNicknameRegistered,
    this.onCancel,
  });

  @override
  State<NicknameRegistrationScreen> createState() => _NicknameRegistrationScreenState();
}

class _NicknameRegistrationScreenState extends State<NicknameRegistrationScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // 화면이 로드되면 자동으로 텍스트 필드에 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _registerNickname() async {
    final nickname = _nicknameController.text.trim();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final error = await NicknameService.registerNickname(nickname);
      
      if (error != null) {
        setState(() {
          _errorMessage = error;
        });
      } else {
        // 성공
        widget.onNicknameRegistered();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '네트워크 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 타이틀
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person_add,
                          size: 64,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '닉네임 등록',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '랭킹 등록을 위해 닉네임을 설정해주세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // 닉네임 입력 필드
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _errorMessage != null ? Colors.red : Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _nicknameController,
                            focusNode: _focusNode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            decoration: const InputDecoration(
                              hintText: '닉네임 입력 (2-12자)',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            maxLength: 12,
                            onSubmitted: (_) => _registerNickname(),
                          ),
                        ),
                        
                        // 에러 메시지
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // 안내 텍스트
                        const Text(
                          '• 한글, 영문, 숫자만 사용 가능\n• 2-12자로 입력해주세요\n• 중복된 닉네임은 사용할 수 없습니다',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 버튼들
                        Row(
                          children: [
                            if (widget.onCancel != null) ...[
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : widget.onCancel,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    '나중에',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _registerNickname,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        '등록하기',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}