import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../referrals/data/referral_mock_data.dart';

class HighRiskIndividualsScreen extends StatelessWidget {
  final String diseaseType;

  const HighRiskIndividualsScreen({
    super.key,
    required this.diseaseType,
  });

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);

  bool get isDiabetes => diseaseType.toLowerCase() == 'diabetes';

  List<Map<String, dynamic>> get people {
    return ReferralMockData.referrals.where((person) {
      final risk = isDiabetes
          ? (person['diabetesRisk'] ?? 'Low')
          : (person['cardiovascularRisk'] ?? 'Low');

      return risk.toString().toLowerCase() == 'high';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 52,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: navy,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${isDiabetes ? 'Diabetes' : 'Cardiovascular'} high-risk individuals',
                    style: const TextStyle(
                      color: navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // MAIN CONTENT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'PRIORITY REVIEW',
                    style: TextStyle(
                      color: blue,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'High-risk individuals',
                    style: TextStyle(
                      color: navy,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'People flagged for ${isDiabetes ? 'diabetes' : 'cardiovascular'} risk screening review.',
                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // CLINICAL NOTICE
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Screening risk is not a confirmed diagnosis. Arrange clinical assessment according to the approved protocol.',
                      style: TextStyle(
                        color: Color(0xFF805A1B),
                        fontSize: 9,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // EMPTY STATE
                  if (people.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: Text(
                          'No matching high-risk mock records found.',
                          style: TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )

                  // HIGH-RISK INDIVIDUAL CARDS
                  else
                    ...people.map((person) {
                      final id = person['id'].toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 11),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE5EBF3),
                          ),
                        ),

                        // MATERIAL WRAPPER FIX
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,

                          child: ListTile(
                            tileColor: Colors.white,

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),

                            // INITIALS
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE0ECFA),
                              child: Text(
                                person['initials'] ?? '',
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            // INDIVIDUAL NAME
                            title: Text(
                              person['name'] ?? '',
                              style: const TextStyle(
                                color: navy,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            // INDIVIDUAL DETAILS
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                '${person['individualId']} · ${person['age']} years · ${person['area']}',
                                style: const TextStyle(
                                  color: Color(0xFF718096),
                                  fontSize: 9,
                                ),
                              ),
                            ),

                            // NAVIGATION ICON
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: navy,
                            ),

                            // OPEN INDIVIDUAL RISK DETAILS
                            onTap: () {
                              context.pushNamed(
                                'individual-risk',
                                pathParameters: {
                                  'id': id,
                                },
                              );
                            },
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}