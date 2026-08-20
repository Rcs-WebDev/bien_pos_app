import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'main_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'Staff';
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);

    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShellScreen()),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: Stack(
        children: [
          // Language Switcher Top Right
          Positioned(
            top: 20,
            right: 20,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.language, size: 18, color: Colors.white),
              label: Text(
                langProvider.isEnglish ? 'EN 🇬🇧' : 'ID 🇮🇩',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              onPressed: () {
                langProvider.toggleLanguage();
              },
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Icon / Logo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.point_of_sale,
                          size: 48,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'BIEN POS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.indigo,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        langProvider.tr('login_subtitle'),
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Role Selection Toggle
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              avatar: const Icon(Icons.person, size: 18),
                              label: const Text('Staff'),
                              selected: _selectedRole == 'Staff',
                              onSelected: (selected) {
                                if (selected)
                                  setState(() => _selectedRole = 'Staff');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              avatar:
                                  const Icon(Icons.admin_panel_settings, size: 18),
                              label: const Text('Manager'),
                              selected: _selectedRole == 'Manager',
                              onSelected: (selected) {
                                if (selected)
                                  setState(() => _selectedRole = 'Manager');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // PIN Password Input
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Password / PIN $_selectedRole',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedRole == 'Manager'
                            ? 'Default PIN Manager: manager123'
                            : 'Default PIN Staff: staff123',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),

                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            setState(() => _errorMessage = '');
                            final result = await authProvider.login(
                                _selectedRole, _passwordController.text.trim());
                            if (result['success']) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MainShellScreen()),
                              );
                            } else {
                              setState(() => _errorMessage =
                                  langProvider.tr('login_error'));
                            }
                          },
                          child: Text(langProvider.tr('login_btn'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
