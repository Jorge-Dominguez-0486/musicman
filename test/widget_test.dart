import 'package:flutter_test/flutter_test.dart';
import 'package:musicman/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MusicManApp());
    await tester.pump();
  });
}
