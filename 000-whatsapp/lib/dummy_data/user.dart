import 'package:uuid/uuid.dart';

import '../core/models/models.dart';
import 'whats_app_users.dart';

final user = User(
  id: const Uuid().v4(),
  name: 'John Doe',
  phNumber: '+0000',
  friends: whatsappUsers.sublist(5).map((e) => e.id).toList(),
);
