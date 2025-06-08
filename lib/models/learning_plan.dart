class LearningPlan {
  String title;
  String description;
  bool isDone;

  LearningPlan({
    required this.title,
    required this.description,
    this.isDone = false,
  });
}
