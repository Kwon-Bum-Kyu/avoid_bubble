import 'package:flutter/material.dart';
import '../services/nickname_service.dart';
import '../utils/responsive_utils.dart';
import '../services/localization_service.dart';

class NicknameRegistrationScreen extends StatefulWidget {
  final VoidCallback onNicknameRegistered;
  final VoidCallback? onCancel;

  const NicknameRegistrationScreen({
    super.key,
    required this.onNicknameRegistered,
    this.onCancel,
  });

  @override
  State<NicknameRegistrationScreen> createState() =>
      _NicknameRegistrationScreenState();
}

class _NicknameRegistrationScreenState
    extends State<NicknameRegistrationScreen> {
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
        _errorMessage = LocalizationService.getText('nickname_network_error');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompactHeight = ResponsiveUtils.isCompactHeight(context);

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
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 타이틀
                      Container(
                        padding: EdgeInsets.all(isCompactHeight ? 15 : 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_add,
                              size: ResponsiveUtils.getResponsiveIconSize(
                                  context,
                                  mobile: 64,
                                  tablet: 72,
                                  desktop: 80),
                              color: Colors.orange,
                            ),
                            SizedBox(height: isCompactHeight ? 12 : 16),
                            Text(
                              LocalizationService.getText('nickname_title'),
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context,
                                    mobile: 28,
                                    tablet: 32,
                                    desktop: 36),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: isCompactHeight ? 6 : 8),
                            Text(
                              LocalizationService.getText('nickname_subtitle'),
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context,
                                    mobile: 16,
                                    tablet: 18),
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isCompactHeight ? 18 : 24),

                            // 닉네임 입력 필드
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _errorMessage != null
                                      ? Colors.red
                                      : Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _nicknameController,
                                focusNode: _focusNode,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                          context,
                                          mobile: 18),
                                ),
                                decoration: InputDecoration(
                                  hintText: LocalizationService.getText('nickname_hint'),
                                  hintStyle:
                                      const TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.all(isCompactHeight ? 14 : 16),
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
                            Text(
                              LocalizationService.getText('nickname_rules'),
                              style: const TextStyle(
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
                                      onPressed:
                                          _isLoading ? null : widget.onCancel,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[700],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        LocalizationService.getText('nickname_later'),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _registerNickname,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Text(
                                            LocalizationService.getText('nickname_register'),
                                            style: const TextStyle(
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
        ));
  }
}
