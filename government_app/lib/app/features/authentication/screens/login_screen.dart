import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final employeeController = TextEditingController();
  final passwordController = TextEditingController();

  bool isOfficer = true;
  bool rememberMe = true;
  bool obscurePassword = true;

  @override
  void dispose() {
    employeeController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  void handleLogin() {
  if (employeeController.text.trim().isEmpty ||
      passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your login credentials'),
      ),
    );
    return;
  }

  if (isOfficer) {
  context.go('/dashboard');
} else {
  context.go('/worker-dashboard');
}
}
 
    

   

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF0F4F9),

    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 600;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 430 : double.infinity,
                minHeight: constraints.maxHeight,
              ),

              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(
                    isDesktop ? 24 : 0,
                  ),

                  boxShadow: isDesktop
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : [],
                ),

                clipBehavior: Clip.antiAlias,

                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      _buildHeader(),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          24,
                          18,
                          24,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            _buildBranding(),

                            const SizedBox(height: 25),

                            _buildSecurityLabel(),

                            const SizedBox(height: 26),

                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.w400,
                                color: AppColors.primary,
                                letterSpacing: -0.8,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Sign in with your registered credentials',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            const SizedBox(height: 25),

                            _buildRoleSelector(),

                            const SizedBox(height: 23),

                            _buildLabel(
                              'Employee ID or mobile number',
                            ),

                            const SizedBox(height: 8),

                            _buildEmployeeField(),

                            const SizedBox(height: 18),

                            _buildLabel('Password'),

                            const SizedBox(height: 8),

                            _buildPasswordField(),

                            const SizedBox(height: 8),

                            _buildRememberMe(),

                            const SizedBox(height: 14),

                            _buildLoginButton(),

                            const SizedBox(height: 16),

                            const Divider(
                              color: AppColors.border,
                            ),

                            const SizedBox(height: 15),

                            _buildPrivacyNotice(),

                            const SizedBox(height: 24),

                            _buildHelpText(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
  // HEADER

  Widget _buildHeader() {
    return SizedBox(
      height: 190,
      width: double.infinity,

      child: ClipRect(
        child: Stack(
          children: [
            Container(
              color: AppColors.primary,
            ),

            Positioned(
              top: -100,
              right: -85,

              child: Container(
                height: 380,
                width: 380,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.045),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              top: -75,
              right: -130,

              child: Container(
                height: 340,
                width: 340,

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              top: 12,
              right: 16,

              child: TextButton.icon(
                onPressed: () {},

                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 15,
                ),

                label: const Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const Positioned(
              left: 20,
              bottom: 36,

              child: Text(
                'Better decisions for\nhealthier districts.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BRANDING

  Widget _buildBranding() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,

          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),

          child: const Icon(
            Icons.health_and_safety_outlined,
            color: Colors.white,
            size: 29,
          ),
        ),

        const SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppConstants.appName,

              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              AppConstants.appTagline,

              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // SECURITY LABEL

  Widget _buildSecurityLabel() {
    return const Row(
      children: [
        Icon(
          Icons.shield_outlined,
          color: AppColors.secondary,
          size: 17,
        ),

        SizedBox(width: 7),

        Text(
          'Secure government service',

          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ROLE SELECTOR

  Widget _buildRoleSelector() {
    return Container(
      height: 46,

      padding: const EdgeInsets.all(4),

      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F8),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          _roleButton('Health Officer', true),
          _roleButton('Health Worker', false),
        ],
      ),
    );
  }

  Widget _roleButton(String title, bool officer) {
    final selected = isOfficer == officer;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isOfficer = officer;
          });
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          alignment: Alignment.center,

          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.transparent,

            borderRadius: BorderRadius.circular(9),

            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 5,
                    ),
                  ]
                : [],
          ),

          child: Text(
            title,

            style: TextStyle(
              fontSize: 12,

              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w400,

              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // LABEL

  Widget _buildLabel(String text) {
    return Text(
      text,

      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  // EMPLOYEE FIELD

  Widget _buildEmployeeField() {
    return TextField(
      controller: employeeController,

      style: const TextStyle(
        fontSize: 14,
        color: AppColors.primary,
      ),

      decoration: const InputDecoration(
        hintText: 'Enter Employee ID',

        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // PASSWORD FIELD

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,

      obscureText: obscurePassword,

      style: const TextStyle(
        fontSize: 14,
        color: AppColors.primary,
      ),

      decoration: InputDecoration(
        hintText: 'Enter password',

        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),

        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },

          icon: Icon(
            obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,

            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  // REMEMBER ME

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 25,
          height: 35,

          child: Checkbox(
            value: rememberMe,

            activeColor: AppColors.primaryBlue,

            onChanged: (value) {
              setState(() {
                rememberMe = value ?? false;
              });
            },
          ),
        ),

        const SizedBox(width: 5),

        const Text(
          'Remember me',

          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),

        const Spacer(),

        TextButton(
          onPressed: () {},

          child: const Text(
            'Forgot password?',

            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  // LOGIN BUTTON

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 49,

      child: ElevatedButton(
        onPressed: handleLogin,

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,

          elevation: 2,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),

        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              'Secure login',

              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(width: 10),

            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // PRIVACY NOTICE

  Widget _buildPrivacyNotice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Icon(
          Icons.shield_outlined,
          color: AppColors.secondary,
          size: 20,
        ),

        const SizedBox(width: 11),

        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: AppColors.textSecondary,
              ),

              children: [
                TextSpan(
                  text:
                      'Your information is protected under government health data privacy standards. ',
                ),

                TextSpan(
                  text: 'Read privacy notice',

                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // HELP TEXT

  Widget _buildHelpText() {
    return const Center(
      child: Text(
        'Need help? Call 104 · Available 24×7',

        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}