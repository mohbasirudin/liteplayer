import 'package:flutter_test/flutter_test.dart';

import 'package:liteplayer/main.dart';

void main() {
  testWidgets('LitePlayer app smoke test', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const LitePlayerApp());

    // Verify that the film list screen appears
    expect(find.text('LitePlayer'), findsOneWidget);
    expect(find.text('Open Folder'), findsOneWidget);
  });
}
