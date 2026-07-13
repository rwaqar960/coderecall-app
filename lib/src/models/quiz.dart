enum QuestionType { mcq, multi, codeReview }

QuestionType _typeFrom(String raw) => switch (raw) {
      'mcq' => QuestionType.mcq,
      'multi' => QuestionType.multi,
      'code-review' => QuestionType.codeReview,
      _ => throw FormatException('Unknown question type: $raw'),
    };

class Quiz {
  const Quiz({
    required this.chapterId,
    required this.passScore,
    required this.questions,
  });

  final String chapterId;
  final double passScore;
  final List<Question> questions;

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        chapterId: json['chapterId'] as String,
        passScore: (json['passScore'] as num).toDouble(),
        questions: (json['questions'] as List)
            .map((q) => Question.fromJson(q as Map<String, dynamic>))
            .toList(),
      );
}

class Question {
  const Question({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.tags,
    this.code,
    this.codeLanguage,
  });

  final String id;
  final QuestionType type;
  final String difficulty;
  final String prompt;
  final String? code;
  final String? codeLanguage;
  final List<QuizOption> options;
  final Set<String> answer;
  final String explanation;
  final List<String> tags;

  bool isCorrect(Set<String> selected) =>
      selected.length == answer.length && selected.containsAll(answer);

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        type: _typeFrom(json['type'] as String),
        difficulty: json['difficulty'] as String,
        prompt: json['prompt'] as String,
        code: json['code'] as String?,
        codeLanguage: json['codeLanguage'] as String?,
        options: (json['options'] as List)
            .map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
            .toList(),
        answer: (json['answer'] as List).cast<String>().toSet(),
        explanation: json['explanation'] as String,
        tags: (json['tags'] as List).cast<String>(),
      );
}

class QuizOption {
  const QuizOption({required this.id, required this.text});

  final String id;
  final String text;

  factory QuizOption.fromJson(Map<String, dynamic> json) =>
      QuizOption(id: json['id'] as String, text: json['text'] as String);
}
