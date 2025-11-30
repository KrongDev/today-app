import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchFriend() {
    if (_searchController.text.isEmpty) {
      return;
    }
    
    setState(() {
      _isSearching = true;
    });
    
    // TODO: Implement friend search logic
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        // TODO: Show search results
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search for friends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter email or user ID to find and add friends',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 24),
            
            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Email or User ID',
                hintText: 'friend@example.com',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() {}),
              onSubmitted: (_) => _searchFriend(),
            ),
            
            const SizedBox(height: 24),
            
            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchController.text.isEmpty || _isSearching
                    ? null
                    : _searchFriend,
                child: _isSearching
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Search'),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Search Results Section
            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_searchController.text.isNotEmpty && !_isSearching)
              _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // TODO: Implement actual search results
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('John Doe'),
              subtitle: const Text('john@example.com'),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Send friend request
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Friend request sent')),
                  );
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

