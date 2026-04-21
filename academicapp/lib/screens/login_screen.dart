import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  String? _selectedRole;
  String? _selectedBranch;
  String? _selectedSemester;
  String? _selectedSection;

  final List<String> _roles = ['Faculty', 'Student'];
  final List<String> _branches = ['CS', 'IT', 'EC', 'ME'];
  final List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> _sections = ['A', 'B', 'C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Icon(
                Icons.school,
                size: 64,
                color: Colors.blue[700],
              ),
              const SizedBox(height: 16),
              Text(
                'Academic Resource Sharing',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  items: _roles.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedRole = value),
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.security),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBranch,
                  items: _branches.map((branch) {
                    return DropdownMenuItem(value: branch, child: Text(branch));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedBranch = value),
                  decoration: InputDecoration(
                    labelText: 'Branch',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSemester,
                  items: _semesters.map((sem) {
                    return DropdownMenuItem(value: sem, child: Text('Semester $sem'));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedSemester = value),
                  decoration: InputDecoration(
                    labelText: 'Semester',
                    prefixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSection,
                  items: _sections.map((section) {
                    return DropdownMenuItem(value: section, child: Text('Section $section'));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedSection = value),
                  decoration: InputDecoration(
                    labelText: 'Section',
                    prefixIcon: const Icon(Icons.group),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              if (_isLogin) {
                                _handleLogin(context, authProvider);
                              } else {
                                _handleSignUp(context, authProvider);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_isLogin ? 'Login' : 'Sign Up'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign Up"
                      : 'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, AuthProvider authProvider) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    bool success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      _showSnackBar('Login successful', isError: false);
    } else {
      _showSnackBar('Login failed. Please check your credentials');
    }
  }

  void _handleSignUp(BuildContext context, AuthProvider authProvider) async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _selectedRole == null ||
        _selectedBranch == null ||
        _selectedSemester == null ||
        _selectedSection == null) {
      _showSnackBar('Please fill all fields');
      return;
    }

    bool success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text,
      role: _selectedRole!.toLowerCase(),
      branch: _selectedBranch!,
      semester: _selectedSemester!,
      section: _selectedSection!,
    );

    if (success) {
      _showSnackBar('Account created successfully', isError: false);
      setState(() => _isLogin = true);
      _clearFields();
    } else {
      _showSnackBar('Sign up failed. Please try again');
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _selectedRole = null;
    _selectedBranch = null;
    _selectedSemester = null;
    _selectedSection = null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}