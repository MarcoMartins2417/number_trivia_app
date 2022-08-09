import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import '../../../../injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Number Trivia')), body: buildBody(context));
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                child: Placeholder(),
              ),
              SizedBox(height: 20),
              Column(
                children: <Widget>[
                  Placeholder(fallbackHeight: 40),
                  SizedBox(height: 10),
                  Row(children: <Widget>[
                    Expanded(
                      child: Placeholder(fallbackHeight: 30),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Placeholder(fallbackHeight: 30),
                    ),
                  ])
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
