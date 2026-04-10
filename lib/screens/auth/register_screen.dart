import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  String _step = 'register'; // 'register' | 'verify'
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Semua kolom wajib diisi.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.register(name, email, password);

      setState(() {
        _step = 'verify';
        _info = 'Kode OTP 6 angka telah dikirim ke $email';
        _otpController.clear();
      });
    } catch (e) {
      setState(() => _error = extractDioError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyRegisterOtp(
        _emailController.text.trim(),
        otp,
        name: _nameController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() => _error = extractDioError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword ? _obscurePassword : false,
      textCapitalization: isPassword || type == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: FGColors.bg,
        prefixIcon: Icon(icon, color: FGColors.textTertiary),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: FGColors.textTertiary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FGColors.primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Animating the form transition
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO HEADER
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Curved Gradient Background
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: FGTheme.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_step == 'verify') {
                                setState(() {
                                  _step = 'register';
                                });
                              } else {
                                context.pop();
                              }
                            },
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _step == 'register'
                                    ? Icons.person_add_alt_1
                                    : Icons.mark_email_unread_outlined,
                                size: 36,
                                color: FGColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _step == 'register' ? 'Buat Akun' : 'Verifikasi OTP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _step == 'register'
                                ? 'Bergabunglah untuk membantu melaporkan keadaan darurat.'
                                : 'Silakan cek email Anda untuk kode unik 6 angka.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // FLOATING FORM CARD
                Container(
                  margin: const EdgeInsets.only(top: 260, left: 24, right: 24, bottom: 40),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _step == 'register' ? _buildRegisterForm() : _buildVerifyForm(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Baru',
          style: TextStyle(
            color: FGColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        _buildTextField(
          controller: _nameController,
          label: 'Nama Lengkap',
          hint: 'john doe',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'contoh@email.com',
          icon: Icons.alternate_email,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'minimal 6 karakter',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        
        if (_error != null) _buildAlert(_error!, isError: true),
        
        SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: FGTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: FGColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Daftar & Lanjut kIrim OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sudah punya akun? ',
              style: TextStyle(color: FGColors.textSecondary, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: const Text(
                'Masuk',
                style: TextStyle(
                  color: FGColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerifyForm() {
    return Column(
      key: const ValueKey('verify'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _step = 'register';
            _error = null;
            _info = null;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: FGColors.bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_back, size: 16, color: FGColors.textSecondary),
                SizedBox(width: 6),
                Text('Ubah Data', style: TextStyle(color: FGColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Kode Keamanan',
          style: TextStyle(
            color: FGColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Memverifikasi ${_emailController.text}',
          style: const TextStyle(color: FGColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        
        if (_info != null) _buildAlert(_info!, isError: false),
        
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 16,
            color: FGColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            counterText: '',
            hintStyle: const TextStyle(letterSpacing: 8, color: FGColors.textTertiary),
            filled: true,
            fillColor: FGColors.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: FGColors.primary, width: 2),
            ),
          ),
          onChanged: (v) {
            if (v.length == 6) _handleVerifyOtp();
          },
        ),
        const SizedBox(height: 24),
        
        if (_error != null) _buildAlert(_error!, isError: true),
        
        SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: _otpController.text.length == 6 
                  ? FGTheme.primaryGradient 
                  : const LinearGradient(colors: [Color(0xFFE5E7EB), Color(0xFFE5E7EB)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _otpController.text.length == 6 
                  ? [
                      BoxShadow(
                        color: FGColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: _otpController.text.length == 6 && !_isLoading ? _handleVerifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Selesai & Masuk',
                      style: TextStyle(
                        color: _otpController.text.length == 6 ? Colors.white : FGColors.textTertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _handleRegister,
            child: const Text(
              'Kirim ulang Kode',
              style: TextStyle(
                color: FGColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlert(String message, {required bool isError}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError 
              ? FGColors.primary.withValues(alpha: 0.3) 
              : const Color(0xFF22C55E).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? FGColors.primary : const Color(0xFF16A34A),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? FGColors.primary : const Color(0xFF16A34A),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
