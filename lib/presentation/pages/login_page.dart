import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/theme_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();
  int _failedAttempts = 0;
  DateTime? _cooldownUntil;
  bool _obscurePassword = true;
  String? _previousError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    // Limpiar error cuando el usuario escribe
    _usernameController.addListener(_clearErrorOnType);
    _passwordController.addListener(_clearErrorOnType);
  }

  void _clearErrorOnType() {
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      ref.read(authProvider.notifier).clearError();
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearErrorOnType);
    _passwordController.removeListener(_clearErrorOnType);
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Ingrese usuario y contraseña');
      return;
    }

    if (_cooldownUntil != null && DateTime.now().isBefore(_cooldownUntil!)) {
      final seconds = _cooldownUntil!.difference(DateTime.now()).inSeconds;
      _showError('Demasiados intentos. Espera $seconds segundos.');
      return;
    }

    _focusNode.unfocus();
    ref.read(authProvider.notifier).login(username, password);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final authState = ref.read(authProvider);
    if (authState.error != null && !authState.isLoading && authState.error != _previousError) {
      _previousError = authState.error;
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        _cooldownUntil = DateTime.now().add(const Duration(seconds: 30));
        _failedAttempts = 0;
      }
    }
  }

  String _getFriendlyError(String? error) {
    if (error == null) return '';
    if (error.toLowerCase().contains('invalid') || 
        error.toLowerCase().contains('credentials') ||
        error.toLowerCase().contains('login')) {
      return 'Usuario o contraseña incorrectos';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDarkMode = ref.watch(themeProvider);
    final size = MediaQuery.of(context).size;
    
    // Usar la altura total de la pantalla, no la disponible (que cambia con el teclado)
    final screenHeight = size.height;
    final isCompact = screenHeight < 680;
    final isTall = screenHeight > 800;

    // Colores del fondo según el tema
    final bgGradient = isDarkMode
        ? const [
            Color(0xFF222D20),
            Color(0xFF1E2832),
            Color(0xFF16213E),
          ]
        : const [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
          ];

    final footerColor = isDarkMode
        ? Colors.white.withOpacity(0.5)
        : const Color(0xFF0F0F0F).withOpacity(0.5);

    // La card es blanca en ambos modos. La diferencia es el fondo exterior.
    final cardColor = const Color(0xFFF8F9FA);
    final cardTextColor = const Color(0xFF0F0F0F);
    final cardTextSecondary = const Color(0xFF0F0F0F).withOpacity(0.6);
    final cardDividerColor = const Color(0xFF0F0F0F).withOpacity(0.1);
    // Inputs blancos puros en ambos modos. El borde marca el recuadro.
    final fieldBgColor = Colors.white;
    final fieldBorderColor = isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFFD1D5DB);
    final fieldTextColor = const Color(0xFF0F0F0F);
    final fieldHintColor = const Color(0xFF0F0F0F).withOpacity(0.4);
    final fieldIconColor = const Color(0xFF0F0F0F).withOpacity(0.5);

    // Logo size responsive
    final logoSize = isCompact ? 56.0 : 72.0;
    final logoIconSize = isCompact ? 28.0 : 36.0;
    final titleFontSize = isCompact ? 24.0 : 28.0;
    final subtitleFontSize = isCompact ? 12.0 : 13.0;
    final cardPadding = isCompact ? 16.0 : 20.0;
    final cardSpacing = isCompact ? 8.0 : 12.0;
    final headerSpacing = isCompact ? 8.0 : 12.0;
    final dividerSpacing = isCompact ? 10.0 : 14.0;
    final topSpacing = isCompact ? 8.0 : (isTall ? 16.0 : 12.0);
    final bottomSpacing = isCompact ? 6.0 : 10.0;
    final buttonHeight = isCompact ? 46.0 : 52.0;
    final fieldPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 16);

    Widget buildLogo() {
      return Column(
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.storefront,
              size: logoIconSize,
              color: Colors.white,
            ),
          ),
          SizedBox(height: headerSpacing),
          Text(
            'GuardaYa',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF0F0F0F),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: isCompact ? 2.0 : 4.0),
          Text(
            'Gestión de Ventas con OCR',
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF0F0F0F).withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    Widget buildLoginButton() {
      return Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFF8C42)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: authState.isLoading ? null : _handleLogin,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: authState.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    Widget buildTextField({
      required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool isPassword = false,
      required VoidCallback onSubmitted,
    }) {
      return TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
        onSubmitted: (_) => onSubmitted(),
        style: TextStyle(
          color: fieldTextColor,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: fieldBgColor,
          hintText: hint,
          hintStyle: TextStyle(
            color: fieldHintColor,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: fieldIconColor,
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: fieldIconColor,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: fieldPadding,
        ),
      );
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topSpacing),
        // Logo Area
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: buildLogo(),
          ),
        ),
        SizedBox(height: isCompact ? 6.0 : 12.0),
        // Login Card
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.4)
                      : const Color(0xFF222D20).withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  'Bienvenido',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: cardTextColor,
                  ),
                ),
                SizedBox(height: isCompact ? 2.0 : 4.0),
                Text(
                  'Inicia sesión en tu cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: cardTextSecondary,
                  ),
                ),

                // Divider decorativo
                SizedBox(height: dividerSpacing),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.primary.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: dividerSpacing),

                // Username Field
                buildTextField(
                  controller: _usernameController,
                  hint: 'Usuario',
                  icon: Icons.person_outline,
                  onSubmitted: () => FocusScope.of(context).nextFocus(),
                ),
                SizedBox(height: cardSpacing),

                // Password Field
                buildTextField(
                  controller: _passwordController,
                  hint: 'Contraseña',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  onSubmitted: _handleLogin,
                ),
                SizedBox(height: cardSpacing),

                // Error Message
                if (authState.error != null) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getFriendlyError(authState.error),
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: cardSpacing),
                ],

                // Login Button
                buildLoginButton(),

                // Divider "o"
                SizedBox(height: isCompact ? 6.0 : 10.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: cardDividerColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'o',
                        style: TextStyle(
                          fontSize: 13,
                          color: cardTextSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: cardDividerColor,
                      ),
                    ),
                  ],
                ),

                // Botón de light mode
                SizedBox(height: isCompact ? 4.0 : 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDarkMode ? Icons.brightness_6_outlined : Icons.brightness_5_outlined,
                      size: 16,
                      color: cardTextSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDarkMode ? 'Light Mode' : 'Dark Mode',
                      style: TextStyle(
                        fontSize: 13,
                        color: cardTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: !isDarkMode,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).toggle();
                      },
                      activeColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withOpacity(0.3),
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: bottomSpacing),
        // Footer
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'GuardaYa v1.0',
            style: TextStyle(
              color: footerColor,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(height: isCompact ? 2.0 : 6.0),
      ],
    );

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: isDarkMode ? const Color(0xFF222D20) : Colors.white,
        body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgGradient,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
