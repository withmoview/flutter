import 'package:flutter/material.dart';
import '../models/bottom_nav_item.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    required this.onAiTap,
    this.aiIcon = Icons.auto_awesome_rounded,
  });

  final List<BottomNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onAiTap;
  final IconData aiIcon;

  @override
  Widget build(BuildContext context) {
    const double aiSize = 56;
    const double aiGap = 12;
    const double bottom = 20;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, bottom),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. 네비게이션 Pill (왼쪽 영역)
          Padding(
            padding: const EdgeInsets.only(right: aiSize + aiGap),
            child: _PillNav(
              items: items,
              index: index,
              onChanged: onChanged,
            ),
          ),

          // 2. AI 버튼 (오른쪽 독립 버튼)
          Positioned(
            right: 0,
            bottom: 4, // Pill과 시각적 높이 중심 맞춤
            child: _AiButton(
              icon: aiIcon,
              onTap: onAiTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---- 내부 구현 (글씨 포함 버전) ----

class _PillNav extends StatelessWidget {
  const _PillNav({
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final List<BottomNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32);

    return Container(
      height: 64, // 높이는 그대로 유지
      decoration: BoxDecoration(
        color: Colors.white, // 배경: 완전 흰색
        borderRadius: borderRadius,
        // 그림자: 또렷하게
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == index;
            final item = items[i];

            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onChanged(i),
                  splashColor: Colors.grey.withOpacity(0.1),
                  highlightColor: Colors.grey.withOpacity(0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. 아이콘
                      Icon(
                        item.icon,
                        size: 24,
                        // 선택되면 검정, 아니면 회색
                        color: selected ? Color(0xFF4E73DF) : const Color(0xFF9E9E9E),
                      ),
                      
                      const SizedBox(height: 4), // 아이콘과 글씨 사이 간격
                      
                      // 2. 글씨 (라벨)
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11, // 작고 깔끔하게
                          // 선택되면 굵게(Bold), 아니면 보통(Medium)
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          // 선택되면 검정, 아니면 회색
                          color: selected ? Color(0xFF4E73DF) : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AiButton extends StatelessWidget {
  const _AiButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Icon(
            icon, 
            size: 26, 
            color: Color(0xFF4E73DF),
          ),
        ),
      ),
    );
  }
}