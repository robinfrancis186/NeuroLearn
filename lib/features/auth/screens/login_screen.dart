import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailLogin = true;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signIn(_emailController.text, _passwordController.text);

    if (authProvider.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient container
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade200,
                  Colors.blue.shade100,
                ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width > 600 
                        ? 600 
                        : MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Row(
                        children: [
                          // Left side with image and welcome text
                          if (MediaQuery.of(context).size.width > 800)
                            Expanded(
                              flex: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: const AssetImage('assets/images/login_bg.jpg'),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.blue.withOpacity(0.7),
                                      BlendMode.overlay,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Welcome to the community',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Login to explore',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          5,
                                          (index) => Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _currentPage == index
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          
                          // Right side with login form
                          Expanded(
                            flex: MediaQuery.of(context).size.width > 800 ? 5 : 10,
                            child: Container(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Login header
                                  const Text(
                                    'Login your account!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Login type toggle
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => setState(() => _isEmailLogin = true),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: _isEmailLogin 
                                                      ? AppColors.primary 
                                                      : Colors.grey.shade300,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'E-mail',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: _isEmailLogin 
                                                    ? AppColors.primary 
                                                    : Colors.grey,
                                                fontWeight: _isEmailLogin 
                                                    ? FontWeight.bold 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => setState(() => _isEmailLogin = false),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: !_isEmailLogin 
                                                      ? AppColors.primary 
                                                      : Colors.grey.shade300,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'Mobile Number',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: !_isEmailLogin 
                                                    ? AppColors.primary 
                                                    : Colors.grey,
                                                fontWeight: !_isEmailLogin 
                                                    ? FontWeight.bold 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Email/Phone field
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: _isEmailLogin 
                                        ? TextInputType.emailAddress 
                                        : TextInputType.phone,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        _isEmailLogin ? Icons.email_outlined : Icons.phone_outlined,
                                        color: Colors.grey,
                                      ),
                                      hintText: _isEmailLogin ? 'Email' : 'Phone',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Password field
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: Colors.grey,
                                      ),
                                      hintText: 'Password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                  
                                  // Forgot password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Login button
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, _) {
                                      return ElevatedButton(
                                        onPressed: authProvider.isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: authProvider.isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text('Continue'),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Sign in with text
                                  const Row(
                                    children: [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Sign in With',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Social login buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _socialLoginButton(
                                        icon: 'assets/icons/facebook.png',
                                        onTap: () {},
                                        fallbackIcon: Icons.facebook,
                                      ),
                                      const SizedBox(width: 16),
                                      _socialLoginButton(
                                        icon: 'assets/icons/google.png',
                                        onTap: () {},
                                        fallbackIcon: Icons.g_mobiledata,
                                      ),
                                      const SizedBox(width: 16),
                                      _socialLoginButton(
                                        icon: 'assets/icons/apple.png',
                                        onTap: () {},
                                        fallbackIcon: Icons.apple,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Sign up link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Don't have an account? ",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // Navigate to sign up
                                        },
                                        child: const Text(
                                          "Sign up",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Mobile view background image
          if (MediaQuery.of(context).size.width <= 800)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/login_bg.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.blue.withOpacity(0.7),
                      BlendMode.overlay,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome to the community',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Login to explore',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _socialLoginButton({
    required String icon,
    required VoidCallback onTap,
    required IconData fallbackIcon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(fallbackIcon, size: 24, color: Colors.grey.shade700);
            },
          ),
        ),
      ),
    );
  }
} 