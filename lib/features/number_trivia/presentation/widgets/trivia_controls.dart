import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/blocs/number_trivia/number_trivia_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  // String inputString = '';
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Textfield
        TextField(
          onSubmitted: (_) {
            addConcrete();
          },
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            // hintText: 'Input a number',
            label: Text('Input a number'),
          ),
          keyboardType: TextInputType.number,
          // onChanged: (value) => inputString = value,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: addConcrete,
                child: const Text('Search'),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: addRandom,
                child: const Text('Get random Trivia'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void addConcrete() {
    FocusScope.of(context).unfocus();
    context.read<NumberTriviaBloc>().add(
          GetTriviaForConcreteNumber(number: controller.text),
        );
    controller.clear();
  }

  void addRandom() {
    controller.clear();
    FocusScope.of(context).unfocus();
    context.read<NumberTriviaBloc>().add(
          GetTriviaForRandomNumber(),
        );
  }
}
