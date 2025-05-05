import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:become_an_ai_agent/features/auth/auth_provider.dart';
import 'package:become_an_ai_agent/features/profile/profile_screen.dart';
import 'dart:math' as math;

class ProfileAvatar extends StatefulWidget {
  final double size;
  final bool showBorder;
  final bool navigateToProfile;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Widget? badge;
  final BoxBorder? border;
  final bool showAnimation;

  const ProfileAvatar({
    super.key,
    this.size = 40,
    this.showBorder = true,
    this.navigateToProfile = true,
    this.backgroundColor,
    this.onTap,
    this.badge,
    this.border,
    this.showAnimation = false,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.showAnimation) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MouseRegion(
          onEnter: (_) => setState(() {
            _isHovered = true;
            if (!widget.showAnimation) {
              _controller.forward();
            }
          }),
          onExit: (_) => setState(() {
            _isHovered = false;
            if (!widget.showAnimation) {
              _controller.reverse();
            }
          }),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _isHovered || widget.showAnimation ? _scaleAnimation.value : 1.0,
                child: Transform.rotate(
                  angle: _isHovered || widget.showAnimation 
                      ? _rotationAnimation.value * math.pi 
                      : 0.0,
                  child: child,
                ),
              );
            },
            child: Stack(
              children: [
                Material(
                  color: Colors.transparent,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.onTap ?? (widget.navigateToProfile
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            )
                        : null),
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    splashColor: theme.colorScheme.primary.withOpacity(0.3),
                    highlightColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.backgroundColor ?? theme.colorScheme.primary,
                        border: widget.border ?? (widget.showBorder 
                          ? Border.all(
                              color: theme.colorScheme.primaryContainer,
                              width: 2,
                            )
                          : null),
                        boxShadow: widget.showBorder 
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(_isHovered ? 0.3 : 0.1),
                                blurRadius: _isHovered ? 8 : 4,
                                spreadRadius: _isHovered ? 1 : 0,
                                offset: const Offset(0, 2),
                              ),
                            ] 
                          : null,
                      ),
                      child: ClipOval(
                        child: authProvider.profileImage != null
                            ? Hero(
                                tag: 'profile-avatar-${widget.size}',
                                child: Image.memory(
                                  authProvider.profileImage!,
                                  width: widget.size,
                                  height: widget.size,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: theme.colorScheme.onPrimary,
                                size: widget.size * 0.6,
                              ),
                      ),
                    ),
                  ),
                ),
                if (widget.badge != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: widget.badge!,
                  ),
                // Plus icon shown while hovering
                if (_isHovered && widget.navigateToProfile && widget.size > 30)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: widget.size * 0.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
} 