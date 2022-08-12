import '../../domain/entities/number_trivia.dart';
import 'number_trivia_state.dart';
import 'package:meta/meta.dart';

class Loaded extends NumberTriviaState {
  final NumberTrivia trivia;

  Loaded({@required this.trivia});

  @override
  List<Object> get props => [trivia];
}