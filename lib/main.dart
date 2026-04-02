import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bws_chat/bws_chat.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BwsChatExampleApp());
}

// =============================================================================
// App
// =============================================================================

class BwsChatExampleApp extends StatelessWidget {
  const BwsChatExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BWS Chat Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F86F7)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// =============================================================================
// Auth Gate – routes to login or home based on auth state
// =============================================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return HomeScreen(user: snapshot.data!);
        }
        return const LoginScreen();
      },
    );
  }
}

// =============================================================================
// Login Screen – anonymous auth with nickname
// =============================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nicknameController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      final uid = credential.user!.uid;

      // Save nickname to Firestore for other users to discover
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'displayName': nickname,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await credential.user!.updateDisplayName(nickname);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat_rounded,
                  size: 72,
                  color: Color(0xFF4F86F7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'BWS Chat',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '테스트를 위해 닉네임을 입력하세요',
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nicknameController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    hintText: '닉네임',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _loading ? null : _signIn,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4F86F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '시작하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Home Screen – wraps bws_chat with ProviderScope
// =============================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue(user.uid),
        chatConfigProvider.overrideWithValue(
          const ChatConfig(
            primaryColor: Color(0xFF4F86F7),
            bubbleColors: BubbleColors.kakao,
            dateLocale: 'ko',
            typingIndicatorsEnabled: true,
            readReceiptsEnabled: true,
            pushNotificationsEnabled: false,
          ),
        ),
      ],
      child: _HomeBody(user: user),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '채팅',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: Color(0xFF1A1A1A)),
            tooltip: '새 채팅',
            onPressed: () => _showUserPicker(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1A1A1A)),
            tooltip: '로그아웃',
            onPressed: () => _signOut(context),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E5E5)),
        ),
      ),
      body: const ChatListBody(),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _showUserPicker(BuildContext context, WidgetRef ref) async {
    final currentUid = user.uid;

    // Fetch all registered users from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    final users = snapshot.docs
        .where((doc) => doc.id != currentUid)
        .map((doc) => doc.data())
        .toList();

    if (!context.mounted) return;

    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아직 다른 사용자가 없습니다. 친구에게 앱을 공유하세요!')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '대화 상대 선택',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 1),
              ...users.map((u) {
                final name = u['displayName'] as String? ?? '이름 없음';
                final uid = u['uid'] as String? ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _colorForName(name),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  title: Text(name),
                  subtitle: Text(uid.substring(0, uid.length.clamp(0, 8)),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                  onTap: () {
                    Navigator.pop(ctx);
                    _startChat(context, ref, uid, name);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startChat(
    BuildContext context,
    WidgetRef ref,
    String otherUid,
    String otherName,
  ) async {
    final chatService = ref.read(chatServiceProvider);
    final currentUid = user.uid;
    final currentName = user.displayName ?? '나';

    // Create or get existing 1:1 room
    final room = await chatService.getOrCreateOneToOneRoom(
      currentUserId: currentUid,
      otherUserId: otherUid,
    );

    // Update participant profiles so names display correctly
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(room.id)
        .update({
      'participantProfiles.$currentUid': ChatUser(
        uid: currentUid,
        displayName: currentName,
      ).toMap(),
      'participantProfiles.$otherUid': ChatUser(
        uid: otherUid,
        displayName: otherName,
      ).toMap(),
    });

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue(currentUid),
            chatConfigProvider.overrideWithValue(
              const ChatConfig(
                primaryColor: Color(0xFF4F86F7),
                bubbleColors: BubbleColors.kakao,
                dateLocale: 'ko',
              ),
            ),
          ],
          child: ChatRoomScreen(
            roomId: room.id,
            roomName: otherName,
          ),
        ),
      ),
    );
  }

  Color _colorForName(String s) {
    const colors = [
      Color(0xFF5C6BC0),
      Color(0xFF26A69A),
      Color(0xFFEC407A),
      Color(0xFFFF7043),
      Color(0xFF8D6E63),
      Color(0xFF42A5F5),
    ];
    if (s.isEmpty) return colors[0];
    return colors[s.codeUnitAt(0) % colors.length];
  }
}

// =============================================================================
// Chat List Body – reuses bws_chat's room stream but with custom tile
// =============================================================================

class ChatListBody extends ConsumerWidget {
  const ChatListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomsProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final config = ref.watch(chatConfigProvider);

    return roomsAsync.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 72, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '아직 채팅방이 없어요',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Text(
                  '오른쪽 위 + 버튼을 눌러 대화를 시작해보세요',
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: rooms.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 76),
          itemBuilder: (context, index) {
            final room = rooms[index];
            final unread = room.unreadCount[currentUserId] ?? 0;
            final name = room.displayName(currentUserId);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _colorForName(name),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                room.lastMessage ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
              ),
              trailing: unread > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: config.unreadBadgeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unread',
                        style: TextStyle(
                          color: config.unreadBadgeTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProviderScope(
                      overrides: [
                        currentUserIdProvider.overrideWithValue(currentUserId),
                        chatConfigProvider.overrideWithValue(config),
                      ],
                      child: ChatRoomScreen(
                        roomId: room.id,
                        roomName: name,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('오류: $err')),
    );
  }

  Color _colorForName(String s) {
    const colors = [
      Color(0xFF5C6BC0),
      Color(0xFF26A69A),
      Color(0xFFEC407A),
      Color(0xFFFF7043),
      Color(0xFF8D6E63),
      Color(0xFF42A5F5),
    ];
    if (s.isEmpty) return colors[0];
    return colors[s.codeUnitAt(0) % colors.length];
  }
}
