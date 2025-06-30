class SingleQuestionDto {
  final int selectedIndex;
  final String question;
  final String correctAnswer;
  final String wrongAnswers;
  final String? description;

  const SingleQuestionDto({
    required this.selectedIndex,
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
    this.description,
  });
}
