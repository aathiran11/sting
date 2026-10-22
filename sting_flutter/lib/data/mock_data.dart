import '../models/verification.dart';

class SUser {
  final String username;
  final String name;
  final String bio;
  final int streak;
  final String streakTier;
  final int stingScore;
  final String interest;

  const SUser({
    required this.username,
    required this.name,
    required this.bio,
    required this.streak,
    this.streakTier = "None",
    this.stingScore = 100,
    required this.interest,
  });

  String get initial => name.substring(0, 1).toUpperCase();
}

class Post {
  final int id;
  final String username;
  final String taskLabel;
  final String category;
  final String caption;
  final String timeAgo;
  final int streak;
  final String streakTier;
  final int stingScore;
  int likes;
  VerificationStats verification;

  Post({
    this.id = 1,
    required this.username,
    required this.taskLabel,
    this.category = "Productivity",
    required this.caption,
    required this.timeAgo,
    this.streak = 10,
    this.streakTier = "Bronze",
    this.stingScore = 150,
    this.likes = 0,
    this.verification = const VerificationStats(),
  });
}

const mockUsers = <SUser>[
  SUser(username: "aria_k", name: "Aria Kapoor", bio: "Chasing light and long runs.", streak: 42, streakTier: "Silver", stingScore: 480, interest: "Fitness"),
  SUser(username: "devon.p", name: "Devon Park", bio: "Sketchbooks and cold brew.", streak: 118, streakTier: "Gold", stingScore: 710, interest: "Creativity"),
  SUser(username: "mei.lin", name: "Mei Lin", bio: "Trail dog, plant mom.", streak: 7, streakTier: "Bronze", stingScore: 195, interest: "Nature"),
  SUser(username: "noah_r", name: "Noah Reyes", bio: "Reading one page at a time.", streak: 30, streakTier: "Silver", stingScore: 410, interest: "Learning"),
  SUser(username: "sana.k", name: "Sana Khatri", bio: "Small kindnesses, daily.", streak: 65, streakTier: "Silver", stingScore: 560, interest: "Kindness"),
  SUser(username: "leo.tan", name: "Leo Tan", bio: "Breathing exercises > everything.", streak: 12, streakTier: "Bronze", stingScore: 240, interest: "Mindfulness"),
  SUser(username: "priya_m", name: "Priya Menon", bio: "Street photography, mostly rain.", streak: 380, streakTier: "Diamond", stingScore: 920, interest: "Photography"),
  SUser(username: "kwame_o", name: "Kwame Owusu", bio: "5am club, most days.", streak: 88, streakTier: "Silver", stingScore: 630, interest: "Fitness"),
  SUser(username: "elena_v", name: "Elena Vance", bio: "1000 days of genuine moments.", streak: 1042, streakTier: "Legend", stingScore: 995, interest: "Kindness"),
];

final mockPosts = <Post>[
  Post(
    id: 101,
    username: "priya_m",
    taskLabel: "Capture natural light with no filter",
    category: "Photography",
    caption: "Sunset over the flyover, raw camera shot. Day 380.",
    timeAgo: "2h",
    streak: 380,
    streakTier: "Diamond",
    stingScore: 920,
    likes: 341,
    verification: const VerificationStats(verifiedCount: 48, inspiringCount: 31, reviewCount: 0),
  ),
  Post(
    id: 102,
    username: "devon.p",
    taskLabel: "Show your focused workspace right now",
    category: "Productivity",
    caption: "Ink stains, notebook, and cold brew. No cleanup for the camera.",
    timeAgo: "4h",
    streak: 118,
    streakTier: "Gold",
    stingScore: 710,
    likes: 89,
    verification: const VerificationStats(verifiedCount: 22, inspiringCount: 9, reviewCount: 1),
  ),
  Post(
    id: 103,
    username: "kwame_o",
    taskLabel: "One set or rep you almost skipped",
    category: "Fitness",
    caption: "Heavy squat day. Almost gave in to excuses. Glad I pushed.",
    timeAgo: "6h",
    streak: 88,
    streakTier: "Silver",
    stingScore: 630,
    likes: 154,
    verification: const VerificationStats(verifiedCount: 34, inspiringCount: 19, reviewCount: 0),
  ),
  Post(
    id: 104,
    username: "sana.k",
    taskLabel: "A small act of kindness in progress",
    category: "Kindness",
    caption: "Left water and energy bars for our building sanitation staff.",
    timeAgo: "9h",
    streak: 65,
    streakTier: "Silver",
    stingScore: 560,
    likes: 210,
    verification: const VerificationStats(verifiedCount: 52, inspiringCount: 40, reviewCount: 0),
  ),
  Post(
    id: 105,
    username: "mei.lin",
    taskLabel: "Watch today's sunrise or sunset",
    category: "Nature",
    caption: "Morning fog clearing over the balcony fern.",
    timeAgo: "11h",
    streak: 7,
    streakTier: "Bronze",
    stingScore: 195,
    likes: 47,
    verification: const VerificationStats(verifiedCount: 12, inspiringCount: 4, reviewCount: 0),
  ),
];

