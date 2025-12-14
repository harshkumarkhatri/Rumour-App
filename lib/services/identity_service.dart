import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class Identity {
  final String displayName;
  final String handle;
  final String avatarUrl;

  Identity({
    required this.displayName,
    required this.handle,
    required this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'handle': handle,
      'avatarUrl': avatarUrl,
    };
  }

  factory Identity.fromMap(Map<String, dynamic> map) {
    return Identity(
      displayName: map['displayName'],
      handle: map['handle'],
      avatarUrl: map['avatarUrl'],
    );
  }
}

class IdentityService {
  static const String _boxName = 'identities';

  static const List<String> _adjectives = [
    'Brave',
    'Calm',
    'Eager',
    'Fancy',
    'Happy',
    'Jolly',
    'Lazy',
    'Proud',
    'Silly',
    'Witty',
    'Ancient',
    'Crimson',
    'Neon',
    'Rapid',
    'Silent',
    'Wise',
    'Lucky',
  ];

  static const List<String> _animals = [
    'Badger',
    'Bear',
    'Cat',
    'Dog',
    'Eagle',
    'Fox',
    'Hawk',
    'Lion',
    'Owl',
    'Panda',
    'Rabbit',
    'Shark',
    'Tiger',
    'Wolf',
    'Zebra',
    'Falcon',
    'Ghost',
  ];

  bool identityExists(String roomId) {
    final box = Hive.box(_boxName);
    return box.containsKey(roomId);
  }

  Future<Identity> getIdentityForRoom(String roomId) async {
    final box = Hive.box(_boxName);
    final storedMap = box.get(roomId);

    if (storedMap != null) {
      return Identity.fromMap(Map<String, dynamic>.from(storedMap));
    }

    final identity = await _generateNewIdentity();
    await box.put(roomId, identity.toMap());

    return identity;
  }

  Future<Identity> _generateNewIdentity() async {
    try {
      final response = await http.get(Uri.parse('https://randomuser.me/api/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['results'][0];

        final firstName = user['name']['first'];
        final lastName = user['name']['last'];
        final username = user['login']['username'];
        final largePic = user['picture']['large'];

        return Identity(
          displayName: "$firstName $lastName",
          handle: "@$username",
          avatarUrl: largePic,
        );
      }
    } catch (e) {
      // Ignore error and fall back to local generation
    }

    final adj = _adjectives[Random().nextInt(_adjectives.length)];
    final animal = _animals[Random().nextInt(_animals.length)];
    final displayName = "$adj $animal";
    final handle = "@$adj$animal";

    return Identity(
      displayName: displayName,
      handle: handle,
      avatarUrl: "https://api.dicebear.com/7.x/bottts/png?seed=$handle",
    );
  }
}
