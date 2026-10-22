import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/user_tile.dart';

class FollowListScreen extends StatefulWidget {
  final AppState state;
  final bool showFollowingOnly;
  const FollowListScreen({super.key, required this.state, required this.showFollowingOnly});
  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  bool loading = true;
  String? error;
  List<dynamic> list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final raw = widget.showFollowingOnly
          ? await widget.state.api.following(widget.state.username)
          : await widget.state.api.followers(widget.state.username);
      setState(() => list = raw);
    } catch (e) {
      setState(() => error = "Couldn't load this list. Check the backend is running.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StingTopBar(title: widget.showFollowingOnly ? "Following" : "Followers"),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: T.flash))
          : error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!, style: const TextStyle(color: T.coral, fontSize: 13))))
              : list.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text("Nobody here yet", style: TextStyle(color: T.muted))))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        itemCount: list.length,
                        itemBuilder: (_, i) => UserTile(
                          username: list[i]["username"] ?? "",
                          name: list[i]["name"] ?? "",
                          streak: list[i]["current_streak"] ?? 0,
                          state: widget.state,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    ),
    );
  }
}
