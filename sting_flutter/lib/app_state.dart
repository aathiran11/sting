import 'models/streak_tier.dart';
import 'models/verification.dart';
import 'services/api_client.dart';

class MyPost {
  final int? id;
  final String taskLabel;
  final String caption;
  final bool verifiedLive;
  final DateTime capturedAt;
  final String? imageUrl;
  final VerificationStats verification;

  MyPost({
    this.id,
    required this.taskLabel,
    required this.caption,
    required this.verifiedLive,
    DateTime? capturedAt,
    this.imageUrl,
    this.verification = const VerificationStats(),
  }) : capturedAt = capturedAt ?? DateTime.now();

  factory MyPost.fromJson(Map<String, dynamic> j) => MyPost(
        id: j["id"],
        taskLabel: j["task_label"] ?? "",
        caption: j["caption"] ?? "",
        verifiedLive: j["verified_live"] ?? false,
        capturedAt: j["captured_at"] != null ? DateTime.tryParse(j["captured_at"]) : null,
        imageUrl: j["image_url"],
        verification: VerificationStats.fromJson(j),
      );
}

class FeedPost {
  final int id;
  final String username;
  final String name;
  final String taskLabel;
  final String category;
  final String caption;
  final int streak;
  final String streakTier;
  final int stingScore;
  final int likes;
  final String? imageUrl;
  final String createdAt;
  VerificationStats verification;

  FeedPost({
    required this.id,
    required this.username,
    required this.name,
    required this.taskLabel,
    this.category = "Productivity",
    required this.caption,
    required this.streak,
    this.streakTier = "None",
    this.stingScore = 100,
    required this.likes,
    required this.createdAt,
    this.imageUrl,
    this.verification = const VerificationStats(),
  });

  factory FeedPost.fromJson(Map<String, dynamic> j) => FeedPost(
        id: j["id"] ?? 0,
        username: j["username"] ?? "",
        name: j["name"] ?? "",
        taskLabel: j["task_label"] ?? "",
        category: j["category"] ?? "Productivity",
        caption: j["caption"] ?? "",
        streak: j["current_streak"] ?? 0,
        streakTier: j["streak_tier"] ?? StreakTier.fromDays(j["current_streak"] ?? 0).title,
        stingScore: j["sting_score"] ?? 100,
        likes: j["likes"] ?? 0,
        createdAt: j["created_at"] ?? "",
        imageUrl: j["image_url"],
        verification: VerificationStats.fromJson(j),
      );
}

class SuggestedUser {
  final String username;
  final String name;
  final String bio;
  final String interest;
  final int streak;
  final String streakTier;
  final int stingScore;

  SuggestedUser({
    required this.username,
    required this.name,
    required this.bio,
    required this.interest,
    required this.streak,
    this.streakTier = "None",
    this.stingScore = 100,
  });

  factory SuggestedUser.fromJson(Map<String, dynamic> j) => SuggestedUser(
        username: j["username"] ?? "",
        name: j["name"] ?? "",
        bio: j["bio"] ?? "",
        interest: j["interest"] ?? "",
        streak: j["current_streak"] ?? 0,
        streakTier: j["streak_tier"] ?? StreakTier.fromDays(j["current_streak"] ?? 0).title,
        stingScore: j["sting_score"] ?? 100,
      );
}

/// Holds form state during onboarding, plus cached copies of whatever the
/// backend last returned. The ApiClient is the source of truth; this class
/// is a thin, mutable cache the UI reads from so screens don't all need
/// their own loading state.
class AppState {
  final ApiClient api = ApiClient();

  // Onboarding / auth form fields
  String email = "";
  String phone = "";
  String password = "";
  String username = "";
  String name = "";
  String bio = "";
  String interest = "Fitness";
  List<String> otp = ["", "", "", ""];

  bool privateAccount = false;
  bool dailyNotif = true;

  // Cached from server
  final Set<String> following = {};
  int myStreak = 0;
  int myLongestStreak = 0;
  int myStingScore = 120;
  int myFreezePasses = 1;
  String myStreakTier = "None";
  bool postedTodayFlag = false;
  final List<MyPost> myPosts = [];

  bool get postedToday => postedTodayFlag;

  Future<void> init() async {
    await api.loadToken();
  }

  /// Pulls /users/me into the local cache.
  Future<void> refreshMe() async {
    final me = await api.getMe();
    username = me["username"] ?? username;
    name = me["name"] ?? name;
    bio = me["bio"] ?? bio;
    interest = me["interest"] ?? interest;
    myStreak = me["currentStreak"] ?? 0;
    myLongestStreak = me["longestStreak"] ?? 0;
    myStingScore = me["stingScore"] ?? 100;
    myFreezePasses = me["freezePasses"] ?? 1;
    myStreakTier = me["streakTier"] ?? StreakTier.fromDays(myStreak).title;
  }

  Future<void> refreshFollowing() async {
    if (username.isEmpty) return;
    final list = await api.following(username);
    following
      ..clear()
      ..addAll(list.map((u) => u["username"] as String));
  }

  Future<void> refreshMyPosts() async {
    final raw = await api.myPosts();
    myPosts
      ..clear()
      ..addAll(raw.map((p) => MyPost.fromJson(p)));
    final today = DateTime.now();
    postedTodayFlag = myPosts.any((p) =>
        p.capturedAt.year == today.year && p.capturedAt.month == today.month && p.capturedAt.day == today.day);
  }

  bool isFollowing(String otherUsername) => following.contains(otherUsername);

  Future<void> toggleFollow(String otherUsername) async {
    if (following.contains(otherUsername)) {
      await api.unfollow(otherUsername);
      following.remove(otherUsername);
    } else {
      await api.follow(otherUsername);
      following.add(otherUsername);
    }
  }

  Future<void> reactToPost(FeedPost post, String reaction) async {
    final oldReaction = post.verification.myReaction;
    int v = post.verification.verifiedCount;
    int i = post.verification.inspiringCount;
    int r = post.verification.reviewCount;

    // Deduct previous reaction if changing
    if (oldReaction == "verified") v = (v - 1).clamp(0, 9999);
    if (oldReaction == "inspiring") i = (i - 1).clamp(0, 9999);
    if (oldReaction == "needs_review") r = (r - 1).clamp(0, 9999);

    // Add new reaction
    if (reaction == "verified") v++;
    if (reaction == "inspiring") i++;
    if (reaction == "needs_review") r++;

    post.verification = post.verification.copyWith(
      verifiedCount: v,
      inspiringCount: i,
      reviewCount: r,
      myReaction: reaction,
    );

    if (api.isLoggedIn && post.id > 0) {
      try {
        final res = await api.verify(post.id, reaction);
        post.verification = VerificationStats.fromJson(res);
      } catch (_) {
        // Optimistic UI state remains active in demo / offline mode
      }
    }
  }

  Future<void> clearReaction(FeedPost post) async {
    final oldReaction = post.verification.myReaction;
    int v = post.verification.verifiedCount;
    int i = post.verification.inspiringCount;
    int r = post.verification.reviewCount;

    if (oldReaction == "verified") v = (v - 1).clamp(0, 9999);
    if (oldReaction == "inspiring") i = (i - 1).clamp(0, 9999);
    if (oldReaction == "needs_review") r = (r - 1).clamp(0, 9999);

    post.verification = post.verification.copyWith(
      verifiedCount: v,
      inspiringCount: i,
      reviewCount: r,
      clearReaction: true,
    );

    if (api.isLoggedIn && post.id > 0) {
      try {
        final res = await api.unverify(post.id);
        post.verification = VerificationStats.fromJson(res);
      } catch (_) {
        // Optimistic UI fallback
      }
    }
  }

  Future<bool> activateFreeze() async {
    if (myFreezePasses <= 0) return false;
    myFreezePasses = (myFreezePasses - 1).clamp(0, 99);
    if (api.isLoggedIn) {
      try {
        await api.useFreezePass();
      } catch (_) {}
    }
    return true;
  }

  void logout() {
    api.clearToken();
    following.clear();
    myPosts.clear();
    myStreak = 0;
    myStingScore = 100;
    myFreezePasses = 1;
    postedTodayFlag = false;
    username = "";
    name = "";
    bio = "";
  }
}

