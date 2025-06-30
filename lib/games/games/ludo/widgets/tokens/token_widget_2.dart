import 'package:flutter/material.dart';


class LudoToken2 extends StatefulWidget {
  final Color color;
  final LudoTokenStyle style;
  final double size;
  final bool isSelected;
  final bool isHome;
  final VoidCallback? onTap;

  const LudoToken2({
    super.key,
    required this.color,
    this.style = LudoTokenStyle.modern,
    this.size = 40.0,
    this.isSelected = false,
    this.isHome = false,
    this.onTap,
  });

  @override
  State<LudoToken2> createState() => _LudoTokenState();
}

class _LudoTokenState extends State<LudoToken2> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60.0,
      ),
    ]).animate(_animationController);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticInOut,
      ),
    );

    if (widget.isSelected) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LudoToken2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animate() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _animate();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? _bounceAnimation.value : 1.0,
            child: Transform.rotate(
              angle: widget.isSelected ? _rotationAnimation.value : 0.0,
              child: _buildTokenByStyle(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTokenByStyle() {
    switch (widget.style) {
      case LudoTokenStyle.modern:
        return _buildModernToken();
      case LudoTokenStyle.classic:
        return _buildClassicToken();
      case LudoTokenStyle.minimalist:
        return _buildMinimalistToken();
      case LudoTokenStyle.glass:
        return _buildGlassToken();
    }
  }

  Widget _buildModernToken() {
    final Color shadowColor = widget.color.withValues(alpha: 0.5);

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: widget.size * 0.6,
          height: widget.size * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.35,
              height: widget.size * 0.35,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassicToken() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color,
        border: Border.all(
          color: Colors.black54,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistToken() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: widget.color,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassToken() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withValues(alpha: 0.7),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: widget.size * 0.15,
            left: widget.size * 0.2,
            child: Container(
              width: widget.size * 0.2,
              height: widget.size * 0.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Available token styles for the Ludo game
enum LudoTokenStyle {
  modern,
  classic,
  minimalist,
  glass,
}

/// Example usage in a simple Ludo board
class LudoGameExample extends StatefulWidget {
  const LudoGameExample({super.key});

  @override
  State<LudoGameExample> createState() => _LudoGameExampleState();
}

class _LudoGameExampleState extends State<LudoGameExample> {
  LudoTokenStyle _selectedStyle = LudoTokenStyle.modern;
  int _selectedTokenIndex = -1;

  final List<Color> playerColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludo Game'),
        actions: [
          PopupMenuButton<LudoTokenStyle>(
            onSelected: (LudoTokenStyle style) {
              setState(() {
                _selectedStyle = style;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<LudoTokenStyle>>[
              const PopupMenuItem<LudoTokenStyle>(
                value: LudoTokenStyle.modern,
                child: Text('Modern Style'),
              ),
              const PopupMenuItem<LudoTokenStyle>(
                value: LudoTokenStyle.classic,
                child: Text('Classic Style'),
              ),
              const PopupMenuItem<LudoTokenStyle>(
                value: LudoTokenStyle.minimalist,
                child: Text('Minimalist Style'),
              ),
              const PopupMenuItem<LudoTokenStyle>(
                value: LudoTokenStyle.glass,
                child: Text('Glass Style'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select a token style from the menu',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(
                8,
                    (index) {
                  final playerIndex = index % playerColors.length;
                  return LudoToken2(
                    color: playerColors[playerIndex],
                    style: _selectedStyle,
                    size: 50,
                    isSelected: _selectedTokenIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedTokenIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
