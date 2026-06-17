import 'package:flutter_test/flutter_test.dart';
import 'package:skillsphere/main.dart';

void main() {
  testWidgets('renders SkillSphere auth screen', (tester) async {
    await tester.pumpWidget(const SkillSphereApp());
    expect(find.text('SkillSphere'), findsOneWidget);
  });
}
