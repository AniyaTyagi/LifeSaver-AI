import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/theme_helper.dart';

// Screen imports for dynamic switching
import 'task_manager_screen.dart';
import 'calendar_view_screen.dart';
import 'ai_chat_screen.dart';
import 'goal_tracker_screen.dart';
import 'habit_tracker_screen.dart';
import 'focus_mode_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentTab = 'Dashboard';
  bool _showRightAssistant = true;

  // Task checklist state
  final List<Map<String, dynamic>> _todayTasks = [
    {"title": "Complete DBMS Assignment", "checked": false},
    {"title": "Finish PPT for Seminar", "checked": true},
    {"title": "Send HR Networking Mail", "checked": false},
    {"title": "Gym Workout", "checked": false},
  ];

  // AI Assistant Chat Messages state (mocking the dialogue in the screenshot)
  final List<Map<String, dynamic>> _chatMessages = [
    {
      "sender": "bot",
      "text": "Hello Rahul! How can I help you today?",
      "time": "09:30 AM"
    },
    {
      "sender": "user",
      "text": "Write a study plan for my exams next week.",
      "time": "09:31 AM"
    },
    {
      "sender": "bot",
      "text": "Here is your optimized study plan based on your subjects and free slots:",
      "time": "09:31 AM",
      "attachment": "Study Plan (Next Week) PDF Document"
    }
  ];

  final TextEditingController _chatInputController = TextEditingController();

  void _sendChatMessage() {
    if (_chatInputController.text.trim().isEmpty) return;
    setState(() {
      _chatMessages.add({
        "sender": "user",
        "text": _chatInputController.text,
        "time": "Now"
      });
      // Simulate quick auto response
      _chatMessages.add({
        "sender": "bot",
        "text": "I'm on it! I will process that request based on your calendar constraints.",
        "time": "Now"
      });
    });
    _chatInputController.clear();
  }

  void _addNewTask(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _todayTasks.add({"title": title, "checked": false});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isDesktop = width >= 1100;
        final bool isTablet = width >= 700 && width < 1100;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // Off-white slate background
          drawer: (!isDesktop && !isTablet) ? _buildDrawer() : null,
          appBar: (!isDesktop && !isTablet)
              ? AppBar(
                  title: Text(
                    'LifeSaver AI',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 1,
                  iconTheme: const IconThemeData(color: Color(0xFF4F46E5)),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.forum_outlined, color: Color(0xFF4F46E5)),
                      onPressed: () {
                        // Open chat in full screen or show a bottom sheet
                        setState(() {
                          _currentTab = 'AI Assistant';
                        });
                      },
                    ),
                  ],
                )
              : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Sidebar Panel (Persistent on desktop & tablet)
              if (isDesktop || isTablet) _buildSidebar(),

              // 2. Middle Main Pane (Dynamic routing content)
              Expanded(
                child: ClipRect(
                  child: Navigator(
                    key: ValueKey(_currentTab),
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) {
                          switch (_currentTab) {
                            case 'Dashboard':
                              return _buildDashboardContent(context, isDesktop);
                            case 'Tasks':
                              return const TaskManagerScreen();
                            case 'Calendar':
                              return const CalendarViewScreen();
                            case 'Goals':
                              return const GoalTrackerScreen();
                            case 'Habits':
                              return const HabitTrackerScreen();
                            case 'Focus':
                              return const FocusModeScreen();
                            case 'Analytics':
                              return const AnalyticsScreen();
                            case 'Settings':
                              return const SettingsScreen();
                            case 'AI Assistant':
                              return const AiChatScreen();
                            default:
                              return _buildDashboardContent(context, isDesktop);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),

              // 3. Right AI Assistant Panel (Desktop persistent, or toggleable)
              if (isDesktop && _showRightAssistant) _buildRightAssistantPanel(),
            ],
          ),
          bottomNavigationBar: (!isDesktop && !isTablet) ? _buildBottomNavBar() : null,
          floatingActionButton: (!isDesktop)
              ? FloatingActionButton(
                  onPressed: () {
                    // Open AI Assistant directly
                    setState(() {
                      _currentTab = 'AI Assistant';
                    });
                  },
                  backgroundColor: const Color(0xFF4F46E5),
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  // ==========================================
  // Sidebar Widget
  // ==========================================
  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Branding Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Color(0xFF4F46E5), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'LifeSaver AI',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Text(
                    'Search anything...',
                    style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Ctrl+K',
                      style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Navigation Links
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildSidebarItem('Dashboard', Icons.grid_view_outlined),
                  _buildSidebarItem('Tasks', Icons.task_alt_outlined),
                  _buildSidebarItem('Calendar', Icons.calendar_today_outlined),
                  _buildSidebarItem('Study Planner', Icons.auto_stories_outlined),
                  _buildSidebarItem('Goals', Icons.flag_outlined),
                  _buildSidebarItem('AI Assistant', Icons.forum_outlined),
                  _buildSidebarItem('Notes', Icons.note_alt_outlined),
                  _buildSidebarItem('Analytics', Icons.analytics_outlined),
                  _buildSidebarItem('Settings', Icons.settings_outlined),
                ],
              ),
            ),
          ),

          // Focus Mode Card inside sidebar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEEF2F6), Color(0xFFE0E7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.headphones_outlined, color: Color(0xFF4F46E5), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Focus Mode',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => _currentTab = 'Focus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text('Start Focus', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // User Profile Card at bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF4F46E5),
                  radius: 18,
                  child: Text('RV', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rahul Verma',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF0F172A)),
                      ),
                      Text(
                        'Student',
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon) {
    final bool isSelected = _currentTab == title;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentTab = title;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEEF2F6) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Mobile / Tablet Drawer Widget
  // ==========================================
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF4F46E5), size: 28),
                const SizedBox(width: 12),
                Text(
                  'LifeSaver AI',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildSidebarItem('Dashboard', Icons.grid_view_outlined),
                _buildSidebarItem('Tasks', Icons.task_alt_outlined),
                _buildSidebarItem('Calendar', Icons.calendar_today_outlined),
                _buildSidebarItem('Goals', Icons.flag_outlined),
                _buildSidebarItem('Habits', Icons.local_fire_department_outlined),
                _buildSidebarItem('Focus', Icons.timer_outlined),
                _buildSidebarItem('Analytics', Icons.analytics_outlined),
                _buildSidebarItem('Settings', Icons.settings_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Mobile Bottom Nav Bar
  // ==========================================
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentTab == 'Dashboard' ? 0 : (_currentTab == 'Tasks' ? 1 : (_currentTab == 'Calendar' ? 2 : 3)),
      selectedItemColor: const Color(0xFF4F46E5),
      unselectedItemColor: const Color(0xFF64748B),
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          if (index == 0) _currentTab = 'Dashboard';
          if (index == 1) _currentTab = 'Tasks';
          if (index == 2) _currentTab = 'Calendar';
          if (index == 3) _currentTab = 'Settings';
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  // ==========================================
  // Dashboard Core Content
  // ==========================================
  Widget _buildDashboardContent(BuildContext context, bool isDesktop) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Search icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning, Rahul! 👋',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You've got 3 important deadlines today.",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  if (isDesktop)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: Color(0xFF64748B)),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE2E8F0),
                          radius: 18,
                          child: Icon(Icons.person_outline, color: Color(0xFF4F46E5), size: 18),
                        )
                      ],
                    )
                ],
              ),
              const SizedBox(height: 24),

              // AI Prompt search box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F4F46E5),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF4F46E5), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Ask me anything or type / for actions...',
                          hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Action Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildActionPill(Icons.add, 'Add Task', () => _showAddTaskDialog(context)),
                    _buildActionPill(Icons.calendar_today, 'Create Schedule', () => setState(() => _currentTab = 'Calendar')),
                    _buildActionPill(Icons.mail_outline, 'Scan Inbox', () {}),
                    _buildActionPill(Icons.headphones_outlined, 'Focus Mode', () => setState(() => _currentTab = 'Focus')),
                    _buildActionPill(Icons.flash_on_outlined, 'Emergency Focus', () {}, isHighRisk: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main grid layout of cards
              isDesktop
                  ? Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildProductivityScoreCard()),
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: _buildTodaySummaryCard()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _buildTodayTasksCard()),
                            const SizedBox(width: 16),
                            Expanded(flex: 3, child: _buildTodayScheduleCard()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildAIRecommendationCard()),
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: _buildStudyProgressCard()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _buildWeeklyProductivityCard()),
                            const SizedBox(width: 16),
                            Expanded(flex: 3, child: _buildAIInsightsCard()),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildProductivityScoreCard(),
                        const SizedBox(height: 16),
                        _buildTodaySummaryCard(),
                        const SizedBox(height: 16),
                        _buildTodayTasksCard(),
                        const SizedBox(height: 16),
                        _buildTodayScheduleCard(),
                        const SizedBox(height: 16),
                        _buildAIRecommendationCard(),
                        const SizedBox(height: 16),
                        _buildStudyProgressCard(),
                        const SizedBox(height: 16),
                        _buildWeeklyProductivityCard(),
                        const SizedBox(height: 16),
                        _buildAIInsightsCard(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Helper Widget Builders
  // ==========================================
  Widget _buildActionPill(IconData icon, String label, VoidCallback onTap, {bool isHighRisk = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        onPressed: onTap,
        avatar: Icon(
          icon,
          size: 14,
          color: isHighRisk ? Colors.white : const Color(0xFF4F46E5),
        ),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isHighRisk ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: isHighRisk ? const Color(0xFFEF4444) : Colors.white,
        side: BorderSide(color: isHighRisk ? Colors.transparent : const Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }

  // Card 1: Productivity Score
  Widget _buildProductivityScoreCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productivity Score',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Better than yesterday (+5%)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'MTM builds productivity after 9 PM',
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Radial score gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  value: 0.82,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  color: Colors.white,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '82',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '/100',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  // Card 2: Today's Summary
  Widget _buildTodaySummaryCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Summary",
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(Icons.task_alt, '5 Tasks', const Color(0xFF10B981)),
              _buildSummaryItem(Icons.groups_outlined, '2 Meetings', const Color(0xFF3B82F6)),
              _buildSummaryItem(Icons.timer_outlined, '2h 30m Focus', const Color(0xFFF59E0B)),
              _buildSummaryItem(Icons.trending_up, '82% Productivity', const Color(0xFF8B5CF6)),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        )
      ],
    );
  }

  // Card 3: Today's Tasks Checklist
  Widget _buildTodayTasksCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Tasks",
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF4F46E5), size: 20),
                onPressed: () => _showAddTaskDialog(context),
              )
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayTasks.length,
            itemBuilder: (context, index) {
              final task = _todayTasks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: task["checked"],
                      activeColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          task["checked"] = val;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        task["title"],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: task["checked"] ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                          decoration: task["checked"] ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showAddTaskDialog(context),
            icon: const Icon(Icons.add, size: 14, color: Color(0xFF4F46E5)),
            label: Text(
              'Add New Task',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5)),
            ),
          )
        ],
      ),
    );
  }

  // Card 4: Today's Schedule Timeline
  Widget _buildTodayScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Schedule",
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          _buildScheduleRow('10:00 AM - 11:30 AM', 'Team Meeting', const Color(0xFF8B5CF6)),
          const SizedBox(height: 12),
          _buildScheduleRow('12:00 PM - 01:00 PM', 'Doctor Appointment', const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _buildScheduleRow('03:00 PM - 05:00 PM', 'Gym Workout', const Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _currentTab = 'Calendar'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View Full Calendar', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 12, color: Color(0xFF4F46E5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String time, String title, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 5: AI Recommendation Box
  Widget _buildAIRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF8B5CF6), size: 18),
              const SizedBox(width: 8),
              Text(
                'AI Recommendation',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Based on your schedule and deadlines, we recommend allocating these two focus blocks today:',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 14),
          _buildRecommendationItem('Study Operating Systems', '2 hours • read docs'),
          const SizedBox(height: 8),
          _buildRecommendationItem('Finish DBMS Assignment', '1 hour • complete schema'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recommendations auto-scheduled in Google Calendar!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 40),
            ),
            child: Text('Apply Recommendation', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String task, String duration) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF4F46E5)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
              Text(duration, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
            ],
          ),
        )
      ],
    );
  }

  // Card 6: Study Progress Bars
  Widget _buildStudyProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Study Progress",
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const Icon(Icons.bar_chart_outlined, color: Color(0xFF64748B), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressRow('DBMS', '3.5 hrs', 0.75, const Color(0xFF4F46E5)),
          const SizedBox(height: 10),
          _buildProgressRow('Operating Systems', '2 hrs', 0.50, const Color(0xFF8B5CF6)),
          const SizedBox(height: 10),
          _buildProgressRow('Computer Networks', '1.5 hrs', 0.35, const Color(0xFF3B82F6)),
          const SizedBox(height: 10),
          _buildProgressRow('DSA', '0.5 hrs', 0.15, const Color(0xFFEC4899)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 14, color: Color(0xFF4F46E5)),
            label: Text('Add New Subject', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
          )
        ],
      ),
    );
  }

  Widget _buildProgressRow(String subject, String hours, double progress, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
            Text(hours, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF1F5F9),
            color: barColor,
            minHeight: 6,
          ),
        )
      ],
    );
  }

  // Card 7: Weekly Productivity Bar Chart
  Widget _buildWeeklyProductivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Productivity",
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Mon', 40),
                _buildChartBar('Tue', 60),
                _buildChartBar('Wed', 95, isActive: true),
                _buildChartBar('Thu', 70),
                _buildChartBar('Fri', 85),
                _buildChartBar('Sat', 30),
                _buildChartBar('Sun', 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, int percentHeight, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: percentHeight.toDouble(),
          width: 14,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [const Color(0xFF4F46E5), const Color(0xFF8B5CF6)]
                  : [const Color(0xFFCBD5E1), const Color(0xFFE2E8F0)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // Card 8: AI Insights Box
  Widget _buildAIInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI Insights",
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          _buildInsightBullet('🟢 Most Productive Time: 10:00 AM - 12:00 PM'),
          const SizedBox(height: 8),
          _buildInsightBullet('🔴 Least Productive Time: 02:00 PM - 04:00 PM'),
          const SizedBox(height: 8),
          _buildInsightBullet('🏠 Focus Zone: Home Studio'),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _currentTab = 'Analytics'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View Detailed Insights', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 12, color: Color(0xFF4F46E5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsightBullet(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF334155)),
    );
  }

  // ==========================================
  // Right AI Assistant Chat Sidebar
  // ==========================================
  Widget _buildRightAssistantPanel() {
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Assistant',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF64748B)),
                  onPressed: () => setState(() => _showRightAssistant = false),
                )
              ],
            ),
          ),

          // Message Stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final msg = _chatMessages[index];
                final isUser = msg["sender"] == "user";
                final hasAttachment = msg["attachment"] != null;

                return Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFFEEF2F6) : const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(isUser ? 12 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg["text"],
                            style: GoogleFonts.inter(
                              color: const Color(0xFF0F172A),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          if (hasAttachment) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444), size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      msg["attachment"],
                                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, left: 4, right: 4),
                      child: Text(
                        msg["time"],
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Utility shortcuts for chat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChatChip('Add to Calendar'),
                _buildChatChip('Convert to Tasks'),
                _buildChatChip('Share'),
              ],
            ),
          ),

          // Message input block
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic_none, color: Color(0xFF64748B), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _chatInputController,
                            onSubmitted: (_) => _sendChatMessage(),
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF4F46E5)),
                  onPressed: _sendChatMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChatChip(String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _chatMessages.add({
            "sender": "user",
            "text": label,
            "time": "Now"
          });
          _chatMessages.add({
            "sender": "bot",
            "text": "Sure! I am performing: '$label'. Done successfully.",
            "time": "Now"
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5)),
        ),
      ),
    );
  }

  // Dialog window to add new task
  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController taskTitleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New Task', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: taskTitleController,
            decoration: const InputDecoration(labelText: 'Task Title'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addNewTask(taskTitleController.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
