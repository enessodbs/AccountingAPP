import '../widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'employee_list_screen.dart';

enum RightSideContent { welcome, about, contact }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;
  RightSideContent _currentContent = RightSideContent.welcome;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final creds = await _authService.getRememberedCredentials();
    if (mounted && creds['remember_me'] == true) {
      setState(() {
        _rememberMe = true;
        _usernameController.text = creds['username'] ?? '';
        _passwordController.text = creds['password'] ?? '';
      });
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Save or clear remembered credentials
        if (_rememberMe) {
          await _authService.saveRememberedCredentials(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          await _authService.clearRememberedCredentials();
        }

        final response = await _authService.login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );

        if (response != null && mounted) {
          // Role-based routing
          Widget destination;
          if (response.roles.contains('Admin') || response.roles.contains('Muhasebe')) {
            destination = const DashboardScreen();
          } else if (response.roles.contains('İK')) {
            destination = const EmployeeListScreen();
          } else {
            destination = const DashboardScreen();
          }

          Navigator.of(context).pushReplacement(
            _createSmoothRoute(destination),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Smooth page transition
  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions to adjust responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    // Core Colors based on requested design
    final Color bgColor = const Color(0xFF23315B); // Outer dark blue bg
    final Color primaryBlue = const Color(0xFF23315B); // Match bg for buttons
    const Color inputHintColor = Color(0xFFA0AAB5);
    const Color darkTextColor = Color(0xFF212529);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Container(
          width: isMobile ? double.infinity : 900,
          height: isMobile ? double.infinity : 550,
          margin: EdgeInsets.all(isMobile ? 0 : 24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 0 : 24),
            boxShadow: isMobile
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // LEFT SIDE - Login Form (White background)
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 32,
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top left Logo
                            Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: primaryBlue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.widgets,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Accounting\nSystem',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: darkTextColor,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),

                            // Center User Avatar Circle
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryBlue,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  size: 48,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Error Message Box
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            // Username Input
                            TextFormField(
                              controller: _usernameController,
                              style: TextStyle(
                                color: darkTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'USERNAME',
                                hintStyle: const TextStyle(
                                  color: inputHintColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: inputHintColor,
                                  size: 20,
                                ),
                                filled: false,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: inputHintColor,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Zorunlu' : null,
                            ),
                            const SizedBox(height: 16),

                            // Password Input
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: TextStyle(
                                color: darkTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: '********',
                                hintStyle: const TextStyle(
                                  color: inputHintColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: inputHintColor,
                                  size: 20,
                                ),
                                filled: false,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: inputHintColor,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Zorunlu' : null,
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'LOGIN',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Bottom Action Links
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => setState(
                                    () => _rememberMe = !_rememberMe,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _rememberMe
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: _rememberMe
                                            ? primaryBlue
                                            : inputHintColor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Remember me',
                                        style: TextStyle(
                                          color: inputHintColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _showForgotPasswordDialog(context);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Text(
                                    'Forgot your password?',
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            // Demo Info Bottom
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: darkTextColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: inputHintColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: inputHintColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // RIGHT SIDE - Gradient Artistic Area
              if (!isMobile)
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      // Imitating the wave background with a beautiful CSS-like gradient Mesh
                      gradient: RadialGradient(
                        center: const Alignment(-0.5, 0.5),
                        radius: 1.5,
                        colors: [
                          const Color(0xFFF3E7C9), // Light creamy orange
                          const Color(0xFF5BA6CA), // Light blue
                          primaryBlue, // Deep blue
                          const Color(0xFF0F1B3E), // Very dark blue
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Top Navigation placeholders
                        Positioned(
                          top: 40,
                          left: 40,
                          right: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _navItem('HOME', RightSideContent.welcome),
                              _navItem('ABOUT', RightSideContent.about),
                              _navItem('CONTACT', RightSideContent.contact),
                            ],
                          ),
                        ),

                        // Dynamic Central Content
                        Positioned.fill(
                          top: 100,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.05),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildRightSideContent(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF23315B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_reset, color: Color(0xFF23315B), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Şifremi Unuttum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lütfen sistemde kayıtlı e-posta adresinizi girin. Yeni geçici şifreniz bu adrese gönderilecektir.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !isSending,
                decoration: InputDecoration(
                  hintText: 'ornek@sirket.com',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF23315B), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx),
              child: const Text('İPTAL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23315B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (!email.contains('@')) {
                        CustomToast.showSuccess(context, 'Lütfen geçerli bir e-posta adresi girin.');
                        return;
                      }

                      setDialogState(() => isSending = true);
                      final message = await _authService.requestPasswordReset(email);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        CustomToast.showSuccess(context, message);
                      }
                    },
              child: isSending
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('GÖNDER', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSideContent() {
    switch (_currentContent) {
      case RightSideContent.about:
        return _buildAboutContent();
      case RightSideContent.contact:
        return _buildContactContent();
      case RightSideContent.welcome:
        return _buildWelcomeContent();
    }
  }

  Widget _buildWelcomeContent() {
    return Container(
      key: const ValueKey('Welcome'),
      padding: const EdgeInsets.only(right: 60, bottom: 120),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'Welcome.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 300,
            child: Text(
              'Muhasebe uygulamamıza hoş geldiniz.\nUygulama üzerinden gelir giderlerinizi hızlıca yönetebilirsiniz.',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAboutContent() {
    return Container(
      key: const ValueKey('About'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Icon(Icons.info_outline, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'Hakkımızda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 350,
            child: Text(
              'Bu uygulama, küçük ve orta ölçekli işletmelerin finansal işlemlerini (gelir, gider, fatura, personel vb.) kolayca yönetebilmesi için geliştirilmiş modern bir muhasebe çözümüdür.',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildFeature('Gelişmiş Fatura Yönetimi (Alış/Satış, Proforma)'),
          _buildFeature('Cari Hesap ve İş Ortağı Takibi'),
          _buildFeature('Personel ve Bordro İşlemleri'),
          _buildFeature('Canlı Döviz Kurları (TCMB)'),
          _buildFeature('Kâr/Zarar ve Yaşlandırma Raporları'),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
        ],
      ),
    );
  }

  Widget _buildContactContent() {
    return Container(
      key: const ValueKey('Contact'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Icon(
            Icons.contact_support_outlined,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'İletişim',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildContactRow(Icons.location_on, 'Bilişim Plaza Kat: 4, İstanbul'),
          _buildContactRow(Icons.phone, '+90 (850) 123 45 67'),
          _buildContactRow(Icons.language, 'www.muhasebesistemi.com'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF23315B),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.email, size: 18),
            label: const Text(
              'Bize E-Posta Gönderin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'destek@muhasebesistemi.com',
                query:
                    'subject=${Uri.encodeComponent('Muhasebe Sistemi İletişim')}',
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                if (context.mounted) {
                  CustomToast.showSuccess(
                    context,
                    'destek@muhasebesistemi.com adresine yazın.',
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(width: 12),
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        ],
      ),
    );
  }

  Widget _navItem(String text, RightSideContent contentTarget) {
    final bool isSelected = _currentContent == contentTarget;
    return InkWell(
      onTap: () {
        setState(() {
          _currentContent = contentTarget;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(isSelected ? 1.0 : 0.6),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
