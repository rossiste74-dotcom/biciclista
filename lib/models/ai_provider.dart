/// AI Provider options for the AI Coach feature
enum AIProvider {
  openai('OpenAI', 'GPT-4o, GPT-4o mini'),
  claude('Anthropic Claude', 'Claude 3.5 Sonnet'),
  gemini('Google Gemini', 'Gemini 1.5 Pro');

  final String displayName;
  final String models;
  
  const AIProvider(this.displayName, this.models);
}
