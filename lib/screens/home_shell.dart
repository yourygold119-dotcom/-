import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'shorts_screen.dart';
import 'chat_screen.dart';
import 'camera_screen.dart';
import 'admin_login_screen.dart';

/// الهيكل الرئيسي: التنقل السفلي بين أقسام التطبيق
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    ShortsScreen(),
    CameraScreen(),
    ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      appBar: AppBar(
        title: const Text("يوراء Yuraa ✨"),
        backgroundColor: Colors.black87,
        actions: [
          // بوابة غرفة الحكم
          IconButton(
            tooltip: "غرفة الحكم",
            icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "الرئيسية"),
          NavigationDestination(
              icon: Icon(Icons.play_circle_outline), label: "شورتس"),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: "كاميرا"),
          NavigationDestination(icon: Icon(Icons.chat), label: "محادثات"),
        ],
      ),
    );
  }
}
