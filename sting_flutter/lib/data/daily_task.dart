import 'dart:math';

class DailyTaskDef {
  final String label;
  final String category;

  const DailyTaskDef({required this.label, required this.category});
}

const dailyTaskPool = <DailyTaskDef>[
  DailyTaskDef(label: "Read 10 pages of a physical book", category: "Learning"),
  DailyTaskDef(label: "Watch today's sunrise or sunset", category: "Nature"),
  DailyTaskDef(label: "A small act of kindness in progress", category: "Kindness"),
  DailyTaskDef(label: "Drink 3 liters of water — show your bottle", category: "Fitness"),
  DailyTaskDef(label: "One set or rep you almost skipped", category: "Fitness"),
  DailyTaskDef(label: "Spend 30 minutes offline — show your view", category: "Mental Health"),
  DailyTaskDef(label: "Review your expenses & write one budget goal", category: "Finance"),
  DailyTaskDef(label: "Sketch, write, or build something from scratch", category: "Creativity"),
  DailyTaskDef(label: "Capture natural light with no filter", category: "Photography"),
  DailyTaskDef(label: "Show your focused workspace right now", category: "Productivity"),
  DailyTaskDef(label: "Pick up 5 pieces of litter outside", category: "Kindness"),
  DailyTaskDef(label: "Call your parents or a mentor", category: "Kindness"),
  DailyTaskDef(label: "Learn one new word & write it down", category: "Learning"),
  DailyTaskDef(label: "Walk 5000 steps — capture your trail", category: "Fitness"),
];

/// Deterministic "today's task" based on the calendar date, so everyone
/// on the same day sees the same task.
DailyTaskDef todaysTaskDef() {
  final now = DateTime.now();
  final seed = now.year * 10000 + now.month * 100 + now.day;
  final rnd = Random(seed);
  return dailyTaskPool[rnd.nextInt(dailyTaskPool.length)];
}

String todaysTask() => todaysTaskDef().label;

String todaysCategory() => todaysTaskDef().category;

String todayKey() {
  final now = DateTime.now();
  return "${now.year}-${now.month}-${now.day}";
}

