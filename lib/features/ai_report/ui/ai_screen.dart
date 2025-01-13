import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pulsehub/features/ai_report/cubit/ai_report_cubit.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  AiScreenState createState() => AiScreenState();
}

class AiScreenState extends State<AiScreen> {
  String? selectedModel = 'Gemini-1.0-Pro';
  bool useKnowledgeBase = false;
  double numberOfReferences = 1; // Initial value for the slider
  final TextEditingController questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiReportCubit, AiReportState>(
      listener: (context, state) {
        if (state is AiReportFailure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AiReportCubit>();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown for model selection
                const Text(
                  'Select Model',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedModel,
                  onChanged: (newValue) {
                    setState(() {
                      selectedModel = newValue;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                        value: 'Gemini-1.0-Pro', child: Text('Gemini-1.0-Pro')),
                    DropdownMenuItem(
                        value: 'GPT-4o-Mini-128k',
                        child: Text('GPT-4o-Mini-128k')),
                    DropdownMenuItem(
                        value: 'GPT-3.5-Turbo-16k',
                        child: Text('GPT-3.5-Turbo-16k')),
                    DropdownMenuItem(
                        value: 'Gemini-1.5-Flash',
                        child: Text('Gemini-1.5-Flash')),
                    DropdownMenuItem(
                        value: 'Claude-instant', child: Text('Claude-instant')),
                    DropdownMenuItem(
                        value: 'Llama-3-70b-Inst-FW',
                        child: Text('Llama-3-70b-Inst-FW')),
                    DropdownMenuItem(
                        value: 'Llama-3-70b-Groq',
                        child: Text('Llama-3-70b-Groq')),
                    DropdownMenuItem(
                        value: 'Mistral-7B-v0.3-T',
                        child: Text('Mistral-7B-v0.3-T')),
                    DropdownMenuItem(
                        value: 'Mistralv0-2-32k',
                        child: Text('Mistralv0-2-32k')),
                    DropdownMenuItem(
                        value: 'Mixtral-8x7b-Groq',
                        child: Text('Mixtral-8x7b-Groq')),
                  ],
                ),
                const SizedBox(height: 16),

                // Checkbox for specialized knowledge base
                CheckboxListTile(
                  title:
                      const Text("Use CloudMATE's Specialized Knowledge-base"),
                  value: useKnowledgeBase,
                  onChanged: (newValue) {
                    setState(() {
                      useKnowledgeBase = newValue ?? false;
                    });
                  },
                ),

                // Slider for Number of References (visible only when checkbox is checked)
                if (useKnowledgeBase) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Number of References:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: numberOfReferences,
                    min: 1,
                    max: 3,
                    divisions: 2,
                    label: numberOfReferences.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        numberOfReferences = value;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 16),

                // TextField for user question
                const Text(
                  'Your Question',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Type your question here',
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: null, // Allows unlimited lines
                ),
                const SizedBox(height: 16),

                // Generate Answer button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      cubit.generateAnswer(
                        questionController.text,
                        numberOfReferences.toInt(),
                        useKnowledgeBase,
                        selectedModel ?? '',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: state is AiReportLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Generate Answer'),
                  ),
                ),
                const SizedBox(height: 16),

                // Display response details
                // Display response details
                if (state is AiReportSuccess)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: MarkdownBody(
                            data: state.response.response
                                .message, // Render Markdown content
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(fontSize: 16),
                              listBullet: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Retrieved Chunks:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (state.response.response.retrievedChunks !=
                                  null)
                                Text(
                                  state.response.response.retrievedChunks!,
                                  style: const TextStyle(fontSize: 14),
                                )
                              else
                                const Text(
                                  'No relevant chunks were retrieved for this query.',
                                  style: TextStyle(fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Card for Response Details
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Response Details:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              MarkdownBody(
                                data:
                                    '**Time Taken:** ${state.response.response.time}',
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Normalized Evaluation: ${state.response.response.normalizedEvaluation ?? 0.0}',
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('BERT Evaluation: '),
                                  ...List.generate(
                                    ((state.response.response.bertEvaluation ??
                                                0) /
                                            2)
                                        .clamp(0, 5)
                                        .round(),
                                    (index) => const Icon(Icons.star,
                                        color: Colors.amber),
                                  ),
                                  ...List.generate(
                                    5 -
                                        ((state.response.response
                                                        .bertEvaluation ??
                                                    0) /
                                                2)
                                            .clamp(0, 5)
                                            .round(),
                                    (index) => const Icon(Icons.star_border,
                                        color: Colors.amber),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
