import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:number_trivia_app/core/usecases/usecase.dart';
import 'package:number_trivia_app/core/util/input_converter.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

import '../../../../core/error/failures.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/number_trivia.dart';
import '../states/number_trivia_export_states.dart';
import '../widgets/widgets.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaPage extends StatefulWidget {
  @override
  State<NumberTriviaPage> createState() => NumberTriviaPageState(concrete: sl(), random: sl(), inputConverter: sl());
}

class NumberTriviaPageState extends State<NumberTriviaPage> {
  NumberTriviaState state = Empty(); // Initialize state //

  // TriviaControls
  final controller = TextEditingController();
  String inputStr;

  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaPageState({
    @required GetConcreteNumberTrivia concrete,
    @required GetRandomNumberTrivia random,
    @required this.inputConverter,
  })  : assert(concrete != null),
        assert(random != null),
        assert(inputConverter != null),
        getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Number Trivia',
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                buildTrivia(state),
                SizedBox(
                  height: 20,
                ),
                buildTriviaControls(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTrivia(NumberTriviaState state) {
    if (state is Empty) {
      return MessageDisplay(
        message: 'Start searching',
      );
    } else if (state is Loading) {
      return LoadingWidget();
    } else if (state is Loaded) {
      return TriviaDisplay(
        numberTrivia: state.trivia,
      );
    } else {
      return MessageDisplay(
        message: state.message,
      );
    }
  }

  Widget buildTriviaControls(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) {
            onGetConcreteTriviaPassed();
          },
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                child: Text(
                  'Search',
                ),
                color: Theme.of(context).accentColor,
                textTheme: ButtonTextTheme.primary,
                onPressed: onGetConcreteTriviaPassed,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: RaisedButton(
                child: Text(
                  'Get random trivia',
                ),
                onPressed: onGetRandomTriviaPassed,
              ),
            ),
          ],
        )
      ],
    );
  }

  void changeState(NumberTriviaState state) {
    setState(
      () {
        this.state = state;
      },
    );
  }

  void onGetConcreteTriviaPassed() {
    controller.clear();

    final inputEither = inputConverter.stringToUnsignedInteger(inputStr);
    inputEither.fold(
      (failure) {
        changeState(Error(message: INVALID_INPUT_FAILURE_MESSAGE));
      },
      (integer) async* {
        changeState(Loading());
        final failureOrTrivia = await getConcreteNumberTrivia(Params(number: integer));
        yield* _eitherLoadedOrErrorState(failureOrTrivia);
      },
    );
  }

  Future<void> onGetRandomTriviaPassed() async {
    controller.clear();

    changeState(Loading());
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    _eitherLoadedOrErrorState(failureOrTrivia);
  }

  Stream<NumberTriviaState> _eitherLoadedOrErrorState(
    Either<Failure, NumberTrivia> failureOrTrivia,
  ) async* {
    yield failureOrTrivia.fold(
      (failure) => Error(message: _mapFailureToMessage(failure)),
      (trivia) => Loaded(trivia: trivia),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
