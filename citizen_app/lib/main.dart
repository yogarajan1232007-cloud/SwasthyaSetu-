import 'package:material_ui/material_ui.dart';
import 'app/features/authentication/screens/citizen_login_screen.dart';

void main() {
  runApp(const CitizenApp());
}

class CitizenApp extends StatelessWidget {
  const CitizenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwasthyaSetu Citizen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15385B),
          primary: const Color(0xFF2864ED),
        ),
      ),
      home: const CitizenLoginScreen(),
    );
  }
}