import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../dashboard/screens/citizen_dashboard_screen.dart';

class CitizenOtpScreen extends StatefulWidget {
  final String mobileNumber;

  const CitizenOtpScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<CitizenOtpScreen> createState() => _CitizenOtpScreenState();
}

class _CitizenOtpScreenState extends State<CitizenOtpScreen> {
  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color teal = Color(0xFF009D91);

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  String get otp => controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void verifyOtp() {
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit OTP.'),
        ),
      );
      return;
    }

    // Demo OTP only. Replace with backend verification later.
    if (otp != '482619') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid demo OTP. Please try again.'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const CitizenDashboardScreen(),
  ),
);

    // Citizen dashboard navigation will be connected next.
  }

  String get maskedNumber {
    return '****** ${widget.mobileNumber.substring(6)}';
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
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 27),

                    const Text(
                      'Enter verification code',
                      style: TextStyle(
                        color: navy,
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'We sent a 6-digit code to $maskedNumber',
                      style: const TextStyle(
                        color: Color(0xFF72829B),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Verification code',
                      style: TextStyle(
                        color: navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildOtpFields(),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Verify & continue',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          for (final controller in controllers) {
                            controller.clear();
                          }
                          focusNodes.first.requestFocus();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Demo OTP is 482619. Real resend will be connected later.',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: blue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const Divider(
                      color: Color(0xFFE7ECF3),
                    ),

                    const SizedBox(height: 18),

                    _buildPrivacyNotice(),

                    const SizedBox(height: 28),

                    const Center(
                      child: Text(
                        'Need help? Call 104 · Available 24×7',
                        style: TextStyle(
                          color: Color(0xFF8492A8),
                          fontSize: 12,
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

  Widget _buildOtpFields() {
    return Row(
      children: List.generate(6, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == 5 ? 0 : 7,
            ),
            child: SizedBox(
              height: 49,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  color: navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFDCE5F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFDCE5F0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: blue,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    focusNodes[index - 1].requestFocus();
                  }

                  setState(() {});
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHero() {
    return Container(
      height: 163,
      width: double.infinity,
      color: navy,
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.fromLTRB(22, 0, 10, 35),
      child: const Text(
        'Your health. Your future.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          letterSpacing: -0.8,
        ),
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
          child: Text(
            'Your information is protected under government health data privacy standards. Read privacy notice',
            style: TextStyle(
              color: Color(0xFF8290A5),
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}