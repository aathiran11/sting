class VerificationStats {
  final int verifiedCount;
  final int inspiringCount;
  final int reviewCount;
  final String? myReaction; // 'verified', 'inspiring', 'needs_review', or null

  const VerificationStats({
    this.verifiedCount = 0,
    this.inspiringCount = 0,
    this.reviewCount = 0,
    this.myReaction,
  });

  int get totalCommunityVotes => verifiedCount + inspiringCount + reviewCount;

  /// Percentage of positive peer verifications
  int get trustPercent {
    if (totalCommunityVotes == 0) return 100;
    final positive = verifiedCount + inspiringCount;
    return ((positive / totalCommunityVotes) * 100).round();
  }

  VerificationStats copyWith({
    int? verifiedCount,
    int? inspiringCount,
    int? reviewCount,
    String? myReaction,
    bool clearReaction = false,
  }) {
    return VerificationStats(
      verifiedCount: verifiedCount ?? this.verifiedCount,
      inspiringCount: inspiringCount ?? this.inspiringCount,
      reviewCount: reviewCount ?? this.reviewCount,
      myReaction: clearReaction ? null : (myReaction ?? this.myReaction),
    );
  }

  factory VerificationStats.fromJson(Map<String, dynamic> j) {
    return VerificationStats(
      verifiedCount: j["verifiedCount"] ?? j["verified_count"] ?? 0,
      inspiringCount: j["inspiringCount"] ?? j["inspiring_count"] ?? 0,
      reviewCount: j["reviewCount"] ?? j["review_count"] ?? 0,
      myReaction: j["myReaction"] ?? j["my_reaction"],
    );
  }

  Map<String, dynamic> toJson() => {
        "verifiedCount": verifiedCount,
        "inspiringCount": inspiringCount,
        "reviewCount": reviewCount,
        "myReaction": myReaction,
      };
}
