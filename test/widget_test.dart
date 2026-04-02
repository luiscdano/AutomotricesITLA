import 'package:flutter_test/flutter_test.dart';

import 'package:automotrices_itla/features/auth/domain/entities/app_user.dart';

void main() {
  test('AppUser mapping smoke test', () {
    final user = AppUser.fromMap(const {
      'id': 25,
      'nombre': 'Rafael',
      'apellido': 'Silfa',
      'correo': 'rafael@example.com',
    });

    expect(user.id, 25);
    expect(user.displayName, 'Rafael Silfa');
  });
}
