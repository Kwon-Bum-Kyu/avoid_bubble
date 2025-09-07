import 'package:flutter/material.dart';

class ResponsiveUtils {
  // 1440px 데스크톱 기준으로 반응형 기준점 설정
  static const double mobileMaxWidth = 480;    // 모바일 최대 너비
  static const double tabletMaxWidth = 768;    // 태블릿 최대 너비
  static const double desktopMinWidth = 1440;  // 데스크톱 기준 너비
  static const double compactHeight = 500;     // 컴팩트 높이 기준
  
  static bool isCompactHeight(BuildContext context) {
    return MediaQuery.of(context).size.height < compactHeight;
  }
  
  static bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileMaxWidth;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileMaxWidth && width < desktopMinWidth;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }
  
  // 모바일 세로 모드 감지 (너비 < 480px && 높이 > 너비)
  static bool isMobilePortrait(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width <= mobileMaxWidth && size.height > size.width;
  }
  
  // 모바일 가로 모드 감지 (높이 < 500px)
  static bool isMobileLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width <= tabletMaxWidth && size.height < compactHeight;
  }
  
  // 반응형 패딩 계산
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobilePortrait(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isMobileLandscape(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isDesktop(context)) {
      return const EdgeInsets.all(32.0);
    } else {
      return const EdgeInsets.all(20.0);
    }
  }
  
  // 반응형 폰트 크기 계산
  static double getResponsiveFontSize(BuildContext context, {
    required double mobile,
    double? mobilePortrait,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile * 1.3;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.15;
    } else if (isMobilePortrait(context)) {
      return mobilePortrait ?? mobile * 0.9;
    } else {
      return mobile;
    }
  }
  
  // 반응형 아이콘 크기 계산  
  static double getResponsiveIconSize(BuildContext context, {
    double mobile = 24.0,
    double? mobilePortrait,
    double? tablet,
    double? desktop,
  }) {
    if (isMobileLandscape(context)) {
      return mobile * 0.75;
    } else if (isMobilePortrait(context)) {
      return mobilePortrait ?? mobile * 0.85;
    } else if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile * 1.4;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return mobile;
    }
  }
  
  // 최대 컨텐츠 너비 계산 (와이드 스크린에서 중앙 정렬용)
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 900.0;
    } else if (isTablet(context)) {
      return 600.0;
    } else {
      return double.infinity;
    }
  }
  
  // 컨텐츠 간격 계산
  static double getResponsiveSpacing(BuildContext context, {
    required double base,
  }) {
    if (isMobilePortrait(context)) {
      return base * 0.7;
    } else if (isMobileLandscape(context)) {
      return base * 0.5;
    } else if (isDesktop(context)) {
      return base * 1.3;
    } else {
      return base;
    }
  }
}