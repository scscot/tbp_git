// FINAL PATCHED — downline_team_screen.dart (routes Firestore access through getDownlineUsers Cloud Function)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/session_manager.dart';
import 'profile_screen.dart';

class DownlineTeamScreen extends StatefulWidget {
  const DownlineTeamScreen({super.key});

  @override
  State<DownlineTeamScreen> createState() => _DownlineTeamScreenState();
}

class _DownlineTeamScreenState extends State<DownlineTeamScreen> {
  bool isLoading = false;
  List<UserModel> allDownlineUsers = [];
  Map<int, List<UserModel>> groupedDownline = {};

  final session = SessionManager.instance;
  List<UserModel> fullTeam = [];
  List<UserModel> visibleTeam = [];
  Map<int, int> levelCounts = {};
  int selectedLevel = -1;
  String selectedFilter = 'All';
  final filters = ['All', 'Last 7 Days', 'Last 30 Days'];

  @override
  void initState() {
    super.initState();
    fetchDownlineFromFunction();
  }

  Future<void> fetchDownlineFromFunction() async {
    setState(() => isLoading = true);
    try {
      final email = SessionManager.instance.currentUser?.email;
      if (email == null || email.trim().isEmpty) {
        throw Exception('User email not available');
      }

      final url = Uri.parse('https://us-central1-teambuilder-plus-fe74d.cloudfunctions.net/getDownlineUsers');
      final response = await http.get(
        Uri.parse('https://us-central1-teambuilder-plus-fe74d.cloudfunctions.net/getDownlineUsers'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-email': email,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<UserModel> allUsers = data.map((json) => UserModel.fromJson(json)).toList();

        final filtered = allUsers.where((u) =>
            (u.referredBy ?? '').trim().toLowerCase() == email.trim().toLowerCase()).toList();

        setState(() {
          allDownlineUsers = filtered;
          groupedDownline = groupByLevel(filtered);
          fullTeam = filtered;
          visibleTeam = _applyFilter(filtered);
          levelCounts = _calculateLevelCounts(groupedDownline);
          isLoading = false;
        });
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching downline: $e');
      setState(() => isLoading = false);
    }
  }

  Map<int, List<UserModel>> groupByLevel(List<UserModel> users) {
    final Map<int, List<UserModel>> levels = {};
    for (var user in users) {
      final level = (user.level is int) ? user.level as int : int.tryParse('${user.level}') ?? 1;
      levels.putIfAbsent(level, () => []).add(user);
    }
    return levels;
  }

  Map<int, int> _calculateLevelCounts(Map<int, List<UserModel>> levels) {
    final Map<int, int> counts = {};
    levels.forEach((key, value) {
      counts[key] = value.length;
    });
    return counts;
  }

  List<UserModel> _applyFilter(List<UserModel> input) {
    if (selectedFilter == 'All') return input;
    final now = DateTime.now();
    final cutoff = selectedFilter == 'Last 7 Days'
        ? now.subtract(const Duration(days: 7))
        : now.subtract(const Duration(days: 30));

    return input.where((u) {
      final dt = DateTime.tryParse(u.createdAt);
      return dt != null && dt.isAfter(cutoff);
    }).toList();
  }

  void _updateFilter(String? value) {
    if (value != null) {
      setState(() {
        selectedFilter = value;
        visibleTeam = _applyFilter(fullTeam);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downline Team')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    items: filters.map((f) {
                      return DropdownMenuItem(
                        value: f,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(f),
                        ),
                      );
                    }).toList(),
                    onChanged: _updateFilter,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: selectedLevel,
                  hint: const Text('All Levels'),
                  items: [
                    const DropdownMenuItem<int>(
                      value: -1,
                      child: Text('All Levels'),
                    ),
                    ...levelCounts.keys.map((level) => DropdownMenuItem<int>(
                          value: level,
                          child: Text('Level $level (${levelCounts[level]})'),
                        )),
                  ],
                  onChanged: (level) {
                    setState(() {
                      selectedLevel = level ?? -1;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: visibleTeam.isEmpty
                  ? const Center(child: Text('No team members'))
                  : ListView.builder(
                      itemCount: visibleTeam.length,
                      itemBuilder: (context, index) {
                        final user = visibleTeam[index];
                        if (selectedLevel > -1) {
                          final level = _getUserLevel(user);
                          if (level != selectedLevel) return const SizedBox();
                        }
                        return Card(
                          child: ListTile(
                            title: Text(user.fullName ?? 'Unnamed User'),
                            subtitle: Text('${user.email}\nJoined: ${user.createdAt}'),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  int _getUserLevel(UserModel user) {
    for (var entry in groupedDownline.entries) {
      if (entry.value.contains(user)) return entry.key;
    }
    return -1;
  }
}