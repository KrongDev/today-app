import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FriendListScreen extends ConsumerStatefulWidget {
  const FriendListScreen({super.key});

  @override
  ConsumerState<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends ConsumerState<FriendListScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement friend list provider
    final friends = <FriendItem>[]; // Mock data for now

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                // TODO: Add badge if there are pending requests
              ],
            ),
            onPressed: () => context.push('/friends/requests'),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => context.push('/friends/search'),
          ),
        ],
      ),
      body: friends.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No friends yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add friends to see their availability',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/friends/search'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Friend'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        friend.name.isNotEmpty ? friend.name[0].toUpperCase() : 'F',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(friend.name),
                    subtitle: Text(friend.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // TODO: Show friend options menu
                      },
                    ),
                    onTap: () {
                      // TODO: Navigate to friend's schedule/availability
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/friends/search'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Friend'),
      ),
    );
  }
}

// Mock data class - will be replaced with actual domain entity
class FriendItem {
  final String id;
  final String name;
  final String email;

  FriendItem({
    required this.id,
    required this.name,
    required this.email,
  });
}

