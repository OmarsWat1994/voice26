import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const AhlAldiraApp());
}

class AhlAldiraApp extends StatefulWidget {
  const AhlAldiraApp({super.key});

  @override
  State<AhlAldiraApp> createState() => _AhlAldiraAppState();
}

class _AhlAldiraAppState extends State<AhlAldiraApp> {
  int userDiamonds = 5000;
  int userCoins = 150000;
  int userLevel = 100;
  String equippedFrame = 'manager_omar';
  String profileImage = 'https://via.placeholder.com/150';
  bool isGoogleLinked = false;
  List<String> ownedFrames = [
    'manager_omar',
    'jannah',
    'admin',
    'vip1',
    'vip2',
    'vip3',
    'vip4',
    'vip5',
    'vip6'
  ];

  void updateDiamonds(int amount) => setState(() => userDiamonds += amount);
  void updateCoins(int amount) => setState(() => userCoins += amount);
  void equipFrame(String frameId) => setState(() => equippedFrame = frameId);

  void buyFrame(String frameId, int price, BuildContext context) {
    if (userDiamonds >= price && !ownedFrames.contains(frameId)) {
      setState(() {
        userDiamonds -= price;
        ownedFrames.add(frameId);
        equippedFrame = frameId;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم شراء وتجهيز الإطار بنجاح! 🎉')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الماس غير كافٍ! ❌')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'أهل الديرة',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF181818), centerTitle: true),
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MainPage(
          userDiamonds: userDiamonds,
          userCoins: userCoins,
          userLevel: userLevel,
          equippedFrame: equippedFrame,
          ownedFrames: ownedFrames,
          profileImage: profileImage,
          isGoogleLinked: isGoogleLinked,
          onEquip: equipFrame,
          onBuy: (frameId, price) => buyFrame(frameId, price, context),
          onUpdateDiamonds: updateDiamonds,
          onUpdateCoins: updateCoins,
          onImageChanged: (newImg) => setState(() => profileImage = newImg),
          onLinkGoogle: () => setState(() => isGoogleLinked = true),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final int userDiamonds;
  final int userCoins;
  final int userLevel;
  final String equippedFrame;
  final List<String> ownedFrames;
  final String profileImage;
  final bool isGoogleLinked;
  final Function(String) onEquip;
  final Function(String, int) onBuy;
  final Function(int) onUpdateDiamonds;
  final Function(int) onUpdateCoins;
  final Function(String) onImageChanged;
  final VoidCallback onLinkGoogle;

  const MainPage({
    super.key,
    required this.userDiamonds,
    required this.userCoins,
    required this.userLevel,
    required this.equippedFrame,
    required this.ownedFrames,
    required this.profileImage,
    required this.isGoogleLinked,
    required this.onEquip,
    required this.onBuy,
    required this.onUpdateDiamonds,
    required this.onUpdateCoins,
    required this.onImageChanged,
    required this.onLinkGoogle,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      RoomsPage(
          equippedFrame: widget.equippedFrame,
          userDiamonds: widget.userDiamonds,
          onUpdateDiamonds: widget.onUpdateDiamonds),
      const PrivateMessagesPage(),
      StorePage(
          userDiamonds: widget.userDiamonds,
          equippedFrame: widget.equippedFrame,
          ownedFrames: widget.ownedFrames,
          onEquip: widget.onEquip,
          onBuy: widget.onBuy),
      ProfilePage(
        userDiamonds: widget.userDiamonds,
        userCoins: widget.userCoins,
        userLevel: widget.userLevel,
        equippedFrame: widget.equippedFrame,
        ownedFrames: widget.ownedFrames,
        profileImage: widget.profileImage,
        isGoogleLinked: widget.isGoogleLinked,
        onEquip: widget.onEquip,
        onUpdateCoins: widget.onUpdateCoins,
        onImageChanged: widget.onImageChanged,
        onLinkGoogle: widget.onLinkGoogle,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFFF69B4),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF181818),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room), label: 'الغرف'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'الرسائل'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'المتجر'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

// ---------------- 1️⃣ صفحة الغرف الصوتية ----------------
class RoomsPage extends StatefulWidget {
  final String equippedFrame;
  final int userDiamonds;
  final Function(int) onUpdateDiamonds;

  const RoomsPage(
      {super.key,
      required this.equippedFrame,
      required this.userDiamonds,
      required this.onUpdateDiamonds});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final Map<String, dynamic> adminRoom = {
    'name': 'روم الإدارة العامة 🛡️⚡',
    'users': '5/9',
    'tag': 'خاص بالإدارة',
    'icon': '👑',
    'bgGradient': const [Color(0xFF2A1B08), Color(0xFF121212)],
  };

  List<Map<String, dynamic>> rooms = [
    {
      'name': 'روم جنة وديرتنا 🌸',
      'users': '7/9',
      'tag': 'شات عام',
      'icon': '🌸',
      'bgGradient': [const Color(0xFF2C102B), const Color(0xFF121212)]
    },
    {
      'name': 'جلسة طرب ووناسة 🎤',
      'users': '4/9',
      'tag': 'موسيقى',
      'icon': '🎵',
      'bgGradient': [const Color(0xFF1E1E1E), const Color(0xFF121212)]
    },
  ];

  void _showCreateRoomDialog() {
    final TextEditingController nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('إنشاء غرفة صوتية جديدة 🎙️',
              style: TextStyle(color: Colors.amber, fontSize: 16)),
          content: TextField(
            controller: nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'ادخل اسم الغرفة...',
              hintStyle: const TextStyle(color: Colors.white38),
              fillColor: Colors.white10,
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء',
                    style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1493)),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    rooms.add({
                      'name': nameCtrl.text.trim(),
                      'users': '1/9',
                      'tag': 'غرفة جديدة',
                      'icon': '🔥',
                      'bgGradient': [
                        const Color(0xFF2C102B),
                        const Color(0xFF121212)
                      ],
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('تم إنشاء الغرفة بنجاح! 🎉')));
                }
              },
              child: const Text('إنشاء', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أهل الديرة 🏠✨'),
        actions: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text('💎 ${widget.userDiamonds}',
                  style: const TextStyle(
                      color: Colors.cyanAccent, fontWeight: FontWeight.bold)))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRoomDialog,
        backgroundColor: const Color(0xFFFF1493),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إنشاء غرفة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: const Color(0xFF2A1B08),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.amber, width: 2)),
            child: ListTile(
              leading: Text(adminRoom['icon'] as String,
                  style: const TextStyle(fontSize: 32)),
              title: Text(adminRoom['name'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.amber)),
              subtitle: Text(
                  '${adminRoom['tag']} | المقاعد: ${adminRoom['users']}',
                  style: const TextStyle(color: Colors.amberAccent)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: VoiceRoomScreen(
                                  roomData: adminRoom,
                                  equippedFrame: widget.equippedFrame))));
                },
                child: const Text('دخول',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
            child: Text('الغرف المتاحة 💬',
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          ...rooms.map((r) {
            return Card(
              color: const Color(0xFF1E1E1E),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Text(r['icon'] as String,
                    style: const TextStyle(fontSize: 28)),
                title: Text(r['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${r['tag']} | المقاعد: ${r['users']}'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1493)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: VoiceRoomScreen(
                                    roomData: r,
                                    equippedFrame: widget.equippedFrame))));
                  },
                  child: const Text('دخول',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------- 🎤 واجهة الغرفة الصوتية مع الصوت الحقيقي (Agora) ----------------
class VoiceRoomScreen extends StatefulWidget {
  final Map<String, dynamic> roomData;
  final String equippedFrame;

  const VoiceRoomScreen(
      {super.key, required this.roomData, required this.equippedFrame});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
  // 🔑 ضع هنا الـ App ID الخاص بك من موقع Agora.io
  final String appId = "YOUR_AGORA_APP_ID";
  final String token = "";
  final String channelName = "ahl_aldira_room";

  late RtcEngine _engine;
  bool _isJoined = false;
  bool _isMuted = false;

  final TextEditingController _msgController = TextEditingController();
  List<Map<String, String>> chatMessages = [
    {
      'user': 'المدير عمر 👑',
      'msg': 'أهلاً وسهلاً بالجميع في الغرفة الصوتية المباشرة! 🎙️'
    },
  ];

  final List<String> roomStickers = [
    '🌹',
    '👑',
    '🔥',
    '🚀',
    '💎',
    '💣',
    '❤️',
    '🏆',
    '🎆',
    '⚜️'
  ];

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    await _engine.enableAudio();
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _isJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {},
      ),
    );

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _engine.muteLocalAudioStream(_isMuted);
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  void _sendMessage({String? customMsg}) {
    String textToSend = customMsg ?? _msgController.text.trim();
    if (textToSend.isNotEmpty) {
      setState(() {
        chatMessages.add({'user': 'أنت (عمر)', 'msg': textToSend});
      });
      if (customMsg == null) _msgController.clear();
    }
  }

  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            children: [
              const Text('إرسال ملصق تفاعلي 🎭',
                  style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  itemCount: roomStickers.length,
                  itemBuilder: (context, idx) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _sendMessage(
                            customMsg: '[ملصق تفاعلي: ${roomStickers[idx]}]');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                            child: Text(roomStickers[idx],
                                style: const TextStyle(fontSize: 28))),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Color> bgGradients =
        List<Color>.from(widget.roomData['bgGradient'] as List);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: bgGradients),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                    Text(widget.roomData['name'] as String,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Row(
                      children: [
                        Icon(Icons.fiber_manual_record,
                            color: _isJoined ? Colors.greenAccent : Colors.red,
                            size: 14),
                        const SizedBox(width: 4),
                        Text(_isJoined ? 'متصل صوتياً 🟢' : 'جاري الاتصال...',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        RenderCustomFrame(
                            frameId: widget.equippedFrame,
                            size: 75,
                            title: 'عمر'),
                        if (!_isMuted)
                          const Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(Icons.mic,
                                  color: Colors.greenAccent, size: 16)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('المدير عمر (متحدث) 🎙️',
                        style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.1),
                      itemCount: 8,
                      itemBuilder: (context, idx) {
                        return Column(
                          children: [
                            const CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white12,
                                child: Icon(Icons.mic_off,
                                    color: Colors.white38, size: 18)),
                            const SizedBox(height: 2),
                            Text('مقعد ${idx + 2}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 10)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    itemCount: chatMessages.length,
                    itemBuilder: (context, idx) {
                      final m = chatMessages[idx];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10)),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: '${m['user']}: ',
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              TextSpan(
                                  text: m['msg'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black45,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic,
                          color:
                              _isMuted ? Colors.redAccent : Colors.greenAccent,
                          size: 28),
                      onPressed: _toggleMute,
                    ),
                    IconButton(
                        icon: const Icon(Icons.emoji_emotions,
                            color: Colors.amber),
                        onPressed: _showStickerPicker),
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة في الروم...',
                          hintStyle: const TextStyle(
                              color: Colors.white38, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          fillColor: Colors.white10,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.send, color: Colors.pinkAccent),
                        onPressed: () => _sendMessage()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- 📩 الرسائل الخاصة ----------------
class PrivateMessagesPage extends StatelessWidget {
  const PrivateMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {
        'name': 'أحمد العراقي 🇮🇶',
        'lastMsg': 'هلا عمر، شوكت نفتح الروم الصوتية؟',
        'time': '10:30 ص'
      },
      {
        'name': 'سارة 🌸',
        'lastMsg': 'شكراً على الإطار المميز! 💕',
        'time': 'أمس'
      },
      {
        'name': 'علي الملك 👑',
        'lastMsg': 'تم ترقية الـ VIP للدرجة 3 🔥',
        'time': 'أمس'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل الخاصة 💬')),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, idx) {
          final c = chats[idx];
          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(Icons.person, color: Colors.white)),
              title: Text(c['name']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(c['lastMsg']!,
                  style: const TextStyle(color: Colors.white60, fontSize: 12)),
              trailing: Text(c['time']!,
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('فتح محادثة خاصة مع: ${c['name']}')));
              },
            ),
          );
        },
      ),
    );
  }
}

// ---------------- 2️⃣ صفحة المتجر ----------------
class StorePage extends StatefulWidget {
  final int userDiamonds;
  final String equippedFrame;
  final List<String> ownedFrames;
  final Function(String) onEquip;
  final Function(String, int) onBuy;

  const StorePage({
    super.key,
    required this.userDiamonds,
    required this.equippedFrame,
    required this.ownedFrames,
    required this.onEquip,
    required this.onBuy,
  });

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> storeFrames = [
      {
        'id': 'manager_omar',
        'name': 'إطار المدير عمر 👑',
        'price': 0,
        'desc': 'الإطار الملكي الذهبي الخاص بالمدير'
      },
      {
        'id': 'jannah',
        'name': 'إطار جنة 🌸',
        'price': 500,
        'desc': 'إطار الورود والزهور الساحر'
      },
      {
        'id': 'vip1',
        'name': 'إطار VIP 1 الناري الأزرق ⚡',
        'price': 1000,
        'desc': 'تأثير ناري أزرق متوهج'
      },
      {
        'id': 'vip2',
        'name': 'إطار VIP 2 الناري الأرجواني 🔮',
        'price': 2000,
        'desc': 'تأثير ناري بنفسجي ساطع'
      },
      {
        'id': 'vip3',
        'name': 'إطار VIP 3 الناري الذهبي 🔱',
        'price': 3000,
        'desc': 'تأثير ناري ذهبي ملكي'
      },
      {
        'id': 'vip4',
        'name': 'إطار VIP 4 الناري الماسي 💎',
        'price': 4000,
        'desc': 'تأثير ناري كريستالي'
      },
      {
        'id': 'vip5',
        'name': 'إطار VIP 5 الناري الوردي 🦅',
        'price': 5000,
        'desc': 'تأثير ناري أسطوري'
      },
      {
        'id': 'vip6',
        'name': 'إطار VIP 6 الناري الإمبراطوري 🔥',
        'price': 10000,
        'desc': 'تأثير ناري أحمر ساطع للغاية'
      },
    ];

    final List<Map<String, dynamic>> stickerPacks = [
      {'name': 'حزمة الملوك 👑', 'icon': '👑⚜️🏆', 'price': 300},
      {'name': 'حزمة التفاعلات السريعة 🔥', 'icon': '🔥🚀💣', 'price': 200},
      {'name': 'حزمة القلوب والزهور 🌹', 'icon': '🌹❤️🌸', 'price': 150},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المتجر 🛍️'),
        actions: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text('💎 ${widget.userDiamonds}',
                  style: const TextStyle(
                      color: Colors.cyanAccent, fontWeight: FontWeight.bold)))
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الإطارات 🖼️'),
            Tab(text: 'الملصقات 🎭'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: storeFrames.length,
            itemBuilder: (context, idx) {
              final f = storeFrames[idx];
              bool isOwned = widget.ownedFrames.contains(f['id']);
              bool isEquipped = widget.equippedFrame == f['id'];

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      RenderCustomFrame(
                          frameId: f['id'] as String,
                          size: 65,
                          title: 'معاينة'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f['name'] as String,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber)),
                            const SizedBox(height: 4),
                            Text(f['desc'] as String,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white60)),
                            const SizedBox(height: 8),
                            if (isEquipped)
                              const Text('مُجهز حالياً ✅',
                                  style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold))
                            else if (isOwned)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent),
                                onPressed: () =>
                                    widget.onEquip(f['id'] as String),
                                child: const Text('تجهيز الإطار',
                                    style: TextStyle(color: Colors.white)),
                              )
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF1493)),
                                onPressed: () => widget.onBuy(
                                    f['id'] as String, f['price'] as int),
                                child: Text('شراء 💎 ${f['price']}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stickerPacks.length,
            itemBuilder: (context, idx) {
              final st = stickerPacks[idx];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Text(st['icon'] as String,
                      style: const TextStyle(fontSize: 28)),
                  title: Text(st['name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.amber)),
                  subtitle: const Text('حزمة تفاعلية حصرياً للرومات الصوتية'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تم شراء حزمة الملصقات بنجاح! 🎭')));
                    },
                    child: Text('شراء 💎 ${st['price']}'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------- 👑 محرك رسم الإطارات النارية المتوهجة ----------------
class RenderCustomFrame extends StatelessWidget {
  final String frameId;
  final double size;
  final String title;

  const RenderCustomFrame(
      {super.key,
      required this.frameId,
      required this.size,
      required this.title});

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.amber;
    String topEmoji = '✨';

    switch (frameId) {
      case 'manager_omar':
        borderColor = const Color(0xFFFFD700);
        topEmoji = '👑⚜️';
        break;
      case 'jannah':
        borderColor = const Color(0xFFFF69B4);
        topEmoji = '🌸🌸';
        break;
      case 'vip1':
        borderColor = Colors.blueAccent;
        topEmoji = '⚡🔥';
        break;
      case 'vip2':
        borderColor = Colors.purpleAccent;
        topEmoji = '🔮🔥';
        break;
      case 'vip3':
        borderColor = Colors.amber;
        topEmoji = '🔱🔥';
        break;
      case 'vip4':
        borderColor = Colors.cyanAccent;
        topEmoji = '💎🔥';
        break;
      case 'vip5':
        borderColor = const Color(0xFFFF1493);
        topEmoji = '🦅🔥';
        break;
      case 'vip6':
        borderColor = Colors.redAccent;
        topEmoji = '👑🔥';
        break;
      default:
        borderColor = Colors.amber;
        topEmoji = '✨';
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 3.5),
            boxShadow: [
              BoxShadow(
                  color: borderColor.withOpacity(0.8),
                  blurRadius: 12,
                  spreadRadius: 3),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF222222),
              child: Text(title,
                  style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.2)),
            ),
          ),
        ),
        Positioned(
            top: -8,
            child: Text(topEmoji, style: TextStyle(fontSize: size * 0.26))),
      ],
    );
  }
}

// ---------------- 3️⃣ الملف الشخصي وتغيير الصورة من الاستوديو ----------------
class ProfilePage extends StatefulWidget {
  final int userDiamonds;
  final int userCoins;
  final int userLevel;
  final String equippedFrame;
  final List<String> ownedFrames;
  final String profileImage;
  final bool isGoogleLinked;
  final Function(String) onEquip;
  final Function(int) onUpdateCoins;
  final Function(String) onImageChanged;
  final VoidCallback onLinkGoogle;

  const ProfilePage({
    super.key,
    required this.userDiamonds,
    required this.userCoins,
    required this.userLevel,
    required this.equippedFrame,
    required this.ownedFrames,
    required this.profileImage,
    required this.isGoogleLinked,
    required this.onEquip,
    required this.onUpdateCoins,
    required this.onImageChanged,
    required this.onLinkGoogle,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int currentVipLevel = 1;

  final List<Map<String, dynamic>> vipLevels = [
    {
      'level': 1,
      'name': 'VIP 1 - الأزرق الناري ⚡',
      'price': 10000,
      'color': Colors.blueAccent,
      'frameId': 'vip1'
    },
    {
      'level': 2,
      'name': 'VIP 2 - الأرجواني الناري 🔮',
      'price': 25000,
      'color': Colors.purpleAccent,
      'frameId': 'vip2'
    },
    {
      'level': 3,
      'name': 'VIP 3 - الذهبي الناري 🔱',
      'price': 50000,
      'color': Colors.amber,
      'frameId': 'vip3'
    },
    {
      'level': 4,
      'name': 'VIP 4 - الماسي الناري 💎',
      'price': 100000,
      'color': Colors.cyanAccent,
      'frameId': 'vip4'
    },
    {
      'level': 5,
      'name': 'VIP 5 - الوردي الأسطوري 🦅',
      'price': 200000,
      'color': const Color(0xFFFF1493),
      'frameId': 'vip5'
    },
    {
      'level': 6,
      'name': 'VIP 6 - الإمبراطوري المتوهج 🔥',
      'price': 500000,
      'color': Colors.redAccent,
      'frameId': 'vip6'
    },
  ];

  void _pickImageFromGallery() {
    widget.onImageChanged(
        'https://via.placeholder.com/150/0000FF/808080?text=Updated');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم رفع واختيار الصورة من الاستوديو بنجاح! 📸')));
  }

  void _showFrameSelectorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('اختر وتغيير الإطار 🖼️',
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: widget.ownedFrames.map((fId) {
                  bool isEquipped = widget.equippedFrame == fId;
                  return GestureDetector(
                    onTap: () {
                      widget.onEquip(fId);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تم تغيير الإطار بنجاح! 🎉')));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isEquipped
                                ? Colors.greenAccent
                                : Colors.transparent,
                            width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RenderCustomFrame(
                          frameId: fId, size: 60, title: 'عمر'),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي 👤')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                RenderCustomFrame(
                    frameId: widget.equippedFrame, size: 110, title: 'عمر'),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.pinkAccent,
                      child:
                          Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('المدير عمر 👑',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber)),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('معلومات وإعدادات البروفايل ⚙️',
                        style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const Divider(color: Colors.white24, height: 20),
                    ListTile(
                      leading: const Icon(Icons.photo_library,
                          color: Colors.pinkAccent),
                      title: const Text('تغيير الصورة الشخصية من الاستوديو'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent),
                        onPressed: _pickImageFromGallery,
                        child: const Text('اختيار صورة',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.filter_vintage, color: Colors.amber),
                      title: const Text('تغيير إطار الملف الشخصي'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber),
                        onPressed: _showFrameSelectorModal,
                        child: const Text('تغيير الإطار',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.g_mobiledata,
                          color: Colors.redAccent, size: 30),
                      title: const Text('ربط الحساب بـ Google'),
                      trailing: widget.isGoogleLinked
                          ? const Text('مرتبط بـ Google ✅',
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent),
                              onPressed: widget.onLinkGoogle,
                              child: const Text('ربط Google',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11)),
                            ),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.star, color: Colors.amberAccent),
                      title: const Text('مستوى الحساب (Level)'),
                      trailing: Text('Lv. ${widget.userLevel} / 100',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.amberAccent)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.monetization_on,
                          color: Colors.amber),
                      title: const Text('عدد الكوينزات (Coins)'),
                      trailing: Text('🪙 ${widget.userCoins}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.amber)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('مستويات VIP النارية 👑🔥',
                        style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vipLevels.length,
                      itemBuilder: (context, idx) {
                        final v = vipLevels[idx];
                        bool isOwned = currentVipLevel >= (v['level'] as int);
                        Color col = v['color'] as Color;

                        return ListTile(
                          title: Text(v['name'] as String,
                              style: TextStyle(
                                  color: col,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          trailing: isOwned
                              ? const Text('مُفعل 🟢',
                                  style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold))
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF1493)),
                                  onPressed: () {
                                    if (widget.userCoins >=
                                        (v['price'] as int)) {
                                      widget
                                          .onUpdateCoins(-(v['price'] as int));
                                      setState(() =>
                                          currentVipLevel = v['level'] as int);
                                      widget.onEquip(v['frameId'] as String);
                                    }
                                  },
                                  child: Text('🪙 ${v['price']}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
