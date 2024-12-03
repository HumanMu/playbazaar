
class QuizQuestionModel {
  final String? path;
  final String question;
  final String correctAnswer;
  final String wrongAnswers;
  final String? description;
  final double? random;

  const QuizQuestionModel({
    this.path,
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
    this.random,
    this.description,
  });


  factory QuizQuestionModel.fromMap(Map<String, dynamic> map) {
    return QuizQuestionModel(
      path: map['path'] as String?,
      question: map['question'] as String,
      correctAnswer: map['correctAnswer'] as String,
      wrongAnswers: map['wrongAnswers'] as String,
      description: map['description'] as String?,
      random: (map['random'] as num?)?.toDouble(),
    );
  }


  @override
  String toString() {
    return 'QuizzQuestionModel(path: $path, question: $question, correctAnswer: $correctAnswer, wrongAnswers: $wrongAnswers, description: $description, random: $random)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizQuestionModel &&
        other.question == question &&
        other.correctAnswer == correctAnswer;
  }

  @override
  int get hashCode => question.hashCode ^ correctAnswer.hashCode;
}

class QuizAttempt {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  QuizAttempt({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      question: json['question'],
      userAnswer: json['userAnswer'],
      correctAnswer: json['correctAnswer'],
      isCorrect: json['isCorrect'],
    );
  }
}


