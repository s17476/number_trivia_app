import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/blocs/number_trivia/number_trivia_bloc.dart';
import 'package:number_trivia_app/injection_container.dart';

import '../../domain/entities/number_trivia.dart';
import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import '../widgets/trivia_controls.dart';
import '../widgets/trivia_display.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: BlocProvider(
          create: (context) => sl<NumberTriviaBloc>(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Column(
                children: [
                  // Top half
                  BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                    builder: (context, state) {
                      if (state is Empty) {
                        return const MessageDisplay(
                          message: 'Start searching',
                        );
                      } else if (state is Error) {
                        return MessageDisplay(message: state.message);
                      } else if (state is Loading) {
                        return const LoadingWidget();
                      } else if (state is Loaded) {
                        return TriviaDisplay(numberTrivia: state.trivia);
                      } else {
                        return Container();
                      }
                    },
                  ),
                  //  Bottom half
                  const TriviaControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
