import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, String>> notifications = [
    {
      'title': 'Issue Resolved',
      'message': 'Your reported issue near Main Street has been resolved.',
      'time': '2 hours ago'
    },
    {
      'title': 'New Feature',
      'message': 'Dark mode is now available in settings!',
      'time': 'Yesterday'
    },
    {
      'title': 'Support Reply',
      'message': 'Support team replied to your recent inquiry.',
      'time': '2 days ago'
    },
  ];

  Set<int> readIndexes = {};

  void markAllAsRead() {
    setState(() {
      readIndexes = Set.from(List.generate(notifications.length, (i) => i));
    });
  }

  void toggleRead(int index) {
    setState(() {
      if (readIndexes.contains(index)) {
        readIndexes.remove(index);
      } else {
        readIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Mark all as read',
                onPressed: markAllAsRead,
              )
            ],
          ),
        ),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isRead = readIndexes.contains(index);

          return GestureDetector(
            onTap: () => toggleRead(index),
            child: Container(
              color: isRead ? Colors.grey[200] : Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: isRead ? Colors.grey : Colors.orange,
                ),
                title: Text(
                  notification['title']!,
                  style: TextStyle(
                    fontWeight:
                    isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(notification['message']!),
                trailing: Text(
                  notification['time']!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
