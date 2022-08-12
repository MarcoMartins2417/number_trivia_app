import 'number_trivia_state.dart';
import 'package:meta/meta.dart';

class Error extends NumberTriviaState {
  final String message;

  Error({@required this.message});

  @override
  List<Object> get props => [message];
}
