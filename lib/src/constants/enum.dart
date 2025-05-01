enum ChatThreadStatus { new_, existing }

enum ChatRole {
  user('user'),
  model('model');

  final String text;
  const ChatRole(this.text);
}