import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thread_flow/modules/auth/presentation/widgets/custom_test_field.dart';
import 'package:thread_flow/modules/auth/presentation/providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. Separate controllers for every data point
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Form key to run validation across all fields simultaneously
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUpSubmit(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Sanitize input (remove spaces from handles/emails)
      final name = _nameController.text.trim();
      final username = _usernameController.text.trim().replaceAll('@', '');
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await authProvider.signUp(
        name: name,
        username: username,
        email: email,
        password: password,
      );

      if (success && mounted) {
        // Direct the newly registered user to the main feed setup
        // Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome to the flow, @$username!")),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Registration failed. Username or email might be taken.",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.watch<AuthProvider>().isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Create your account",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Display Name (e.g., John Doe)
                  CustomTextField(
                    labelText: "Name",
                    hintText: "What should we call you?",
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Twitter Handle (e.g., @johndoe)
                  CustomTextField(
                    labelText: "Username",
                    hintText: "Pick a unique @handle",
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Username handle is required";
                      }
                      if (value.trim().contains(' ')) {
                        return "Usernames cannot contain spaces";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email
                  CustomTextField(
                    labelText: "Email address",
                    hintText: "Enter your email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is required";
                      }
                      // Simple regex check for industrial standard format validation
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value.trim())) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  CustomTextField(
                    labelText: "Password",
                    hintText: "Create a strong password",
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) =>
                        isLoading ? null : _onSignUpSubmit(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters long";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => _onSignUpSubmit(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          24,
                        ), // Rounded social-style buttons
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Create account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
