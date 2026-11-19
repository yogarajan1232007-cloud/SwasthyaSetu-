import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'citizen_otp_screen.dart';

class CitizenLoginScreen extends StatefulWidget {
  const CitizenLoginScreen({super.key});

  @override
  State<CitizenLoginScreen> createState() => _CitizenLoginScreenState();
}

class _CitizenLoginScreenState extends State<CitizenLoginScreen> {
  final TextEditingController mobileController = TextEditingController();

  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color teal = Color(0xFF009D91);
  

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  void sendOtp() {
    final mobile = mobileController.text.trim();

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CitizenOtpScreen(
          mobileNumber: mobile,
        ),
      ),
    );
  }

  void showHealthIdDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final healthIdController = TextEditingController();

        return AlertDialog(
          title: const Text('Individual Health ID'),
          content: TextField(
            controller: healthIdController,
            decoration: const InputDecoration(
              labelText: 'Enter your Health ID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                healthIdController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                healthIdController.dispose();
                Navigator.pop(context);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Health ID login will be connected later.',
                    ),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 26),

                    _buildBrand(),

                    const SizedBox(height: 25),

                    const Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: teal,
                          size: 17,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Secure government service',
                          style: TextStyle(
                            color: teal,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 27),

                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: navy,
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 9),

                    const Text(
                      'Sign in to view your health records',
                      style: TextStyle(
                        color: Color(0xFF72829B),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 29),

                    const Text(
                      'Mobile number',
                      style: TextStyle(
                        color: navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    _buildMobileField(),

                    const SizedBox(height: 7),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
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
                              'Send OTP',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.chevron_right,
                              size: 21,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    Center(
                      child: TextButton(
                        onPressed: showHealthIdDialog,
                        child: const Text(
                          'Use Individual Health ID instead',
                          style: TextStyle(
                            color: blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    const Divider(
                      color: Color(0xFFE7ECF3),
                    ),

                    const SizedBox(height: 18),

                    _buildPrivacyNotice(),

                    const SizedBox(height: 28),

                    const Center(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: Color(0xFF8492A8),
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(text: 'Need help? Call '),
                            TextSpan(
                              text: '104',
                              style: TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(text: ' · Available 24×7'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      height: 163,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(2),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -85,
            top: -105,
            child: Container(
              height: 360,
              width: 360,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                shape: BoxShape.circle,
              ),
            ),
          ),

          const Positioned(
            left: 22,
            bottom: 35,
            child: Text(
              'Your health. Your future.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Row(
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.16),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.health_and_safety_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(width: 12),

        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SwasthyaSetu',
              style: TextStyle(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'COMMUNITY HEALTH MISSION',
              style: TextStyle(
                color: Color(0xFF71829B),
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFF),
        border: Border.all(
          color: const Color(0xFFDCE5F0),
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 13),
            child: Text(
              '+91',
              style: TextStyle(
                color: Color(0xFF72829B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Container(
            height: 23,
            width: 1,
            color: const Color(0xFFDCE5F0),
          ),

          Expanded(
            child: TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(
                color: navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter mobile number',
                hintStyle: TextStyle(
                  color: Color(0xFFAAB5C4),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.shield_outlined,
          color: teal,
          size: 18,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                color: Color(0xFF8290A5),
                fontSize: 10,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text:
                      'Your information is protected under government health data privacy standards. ',
                ),
                TextSpan(
                  text: 'Read privacy notice',
                  style: TextStyle(
                    color: blue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}