import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:go_router/go_router.dart';
import 'package:playbazaar/config/routes/notification_route.dart';
import 'package:playbazaar/config/routes/static_app_routes.dart';
import 'package:playbazaar/languages/early_stage_strings.dart';
import 'app_initializer.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final NotificationRouteService _notificationRouteService;


  String _languageCode = "";
  String _status = 'Starting app...';
  bool _isNavigating = false;

  static const int _maxRetries = 3;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationRouteService = NotificationRouteService();
    _setupAnimation();
    _startInitialization();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  Future<void> _startInitialization() async {
    if (!mounted) return;

    try {
      final initializer = AppInitializer();
      _languageCode = await initializer.getLanguageCode();

      if (!mounted) return;

      // Initialize app with status callbacks
      final initializerWithCallback = AppInitializer(
        onStatusUpdate: _updateStatus,
      );

      await initializerWithCallback.initialize();
      await _navigateToAppRoutes();

    } catch (e, stackTrace) {
      debugPrint('Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (!mounted) return;

      _retryCount++;

      if (_retryCount <= _maxRetries) {
        _updateStatus('error_retry');
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          _startInitialization();
        }
      } else {
        _updateStatus('error_fatal');
      }
    }
  }

  void _updateStatus(String status) {
    if (!mounted) return;

    setState(() {
      _status = _getProcessString(status);
    });
  }

  String _getProcessString(String processCode) {
    return EarlyStageStrings.getTranslation(processCode, _languageCode);
  }

  Future<void> _navigateToAppRoutes() async{
    if (_isNavigating || !mounted) return;

    _isNavigating = true;
    final notificationRoute = await _notificationRouteService.getInitialNotificationRoute();

    if(!mounted) return;
    if (notificationRoute != null) {
      context.go(
        notificationRoute,
        extra: {'fromNotification': true},
      );
    } else {
      context.go(AppRoutes.profile);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedLogo(),
                const SizedBox(height: 40),
                _buildProgressIndicator(),
                const SizedBox(height: 30),
                _buildAppTitle(),
                const SizedBox(height: 10),
                _buildStatusText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icons/splash_screen_960x960.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 40),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      strokeWidth: 3,
    );
  }

  Widget _buildAppTitle() {
    return Text(
      "app_name".tr,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _status,
        key: ValueKey(_status),
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}