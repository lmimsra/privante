import 'package:flutter/material.dart';
import 'package:privante/components/form_submit_button.dart';
import 'package:privante/services/auth.dart';
import 'package:privante/validators/email_password_form_validator.dart';

enum EmailSignInFormType { signIn, Register }

class MailPasswordForm extends StatefulWidget with EmailAndPasswordValidator {
  MailPasswordForm({Key key, this.auth}) : super(key: key);

  final Auth auth;

  @override
  _MailPasswordFormState createState() => _MailPasswordFormState(auth);
}

class _MailPasswordFormState extends State<MailPasswordForm> {
  final Auth _auth;

  _MailPasswordFormState(this._auth);

  final TextEditingController _mailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String get _email => _mailEditingController.text;

  String get _password => _passwordEditingController.text;
  EmailSignInFormType _formType = EmailSignInFormType.signIn;
  bool _submitted = false;

  void _submit() async {
    setState(() {
      _submitted = true;
    });
    // 登録完了時の処理
    try {
      if (_formType == EmailSignInFormType.signIn) {
        await _auth.signInWithEmail(email: _email, password: _password);
      } else {
        await _auth.createWithEmail(email: _email, password: _password);
      }
      Navigator.of(context).pop();
    } catch (e) {
      print(e.toString());
    }
  }

  void _emailEditingComplete() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  /// 入力フォーム切替
  void _toggleFormType() {
    setState(() {
      _submitted = false;
      _formType = _formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.Register
          : EmailSignInFormType.signIn;
    });
    _mailEditingController.clear();
    _passwordEditingController.clear();
  }

  List<Widget> _buildChildren() {
    final submitButtonMessage = _formType == EmailSignInFormType.signIn
        ? 'Sign in'
        : 'Create an account';
    final flatButtonMessage = _formType == EmailSignInFormType.signIn
        ? 'アカウントがないですか？ 新規登録'
        : 'アカウントお持ちですか？ サインイン';
    bool submitEnabled = widget.emailValidator.isValid(_email) &&
        widget.passwordValidator.isValid(_password);

    return [
      _buildEmailTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildPasswordTextField(),
      SizedBox(
        height: 8.0,
      ),
      FormSubmitButton(
        text: submitButtonMessage,
        onPressed: submitEnabled ? _submit : null,
      ),
      SizedBox(
        height: 8.0,
      ),
      FlatButton(
        child: Text(flatButtonMessage),
        onPressed: _toggleFormType,
      )
    ];
  }

  Widget _buildEmailTextField() {
    bool showErrorMessage =
        _submitted && !widget.emailValidator.isValid(_email);
    return TextField(
      controller: _mailEditingController,
      focusNode: _emailFocusNode,
      decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'example@sample.com',
          errorText: showErrorMessage ? widget.emailValidErrorText : null),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (email) => _updateState(),
      onEditingComplete: _emailEditingComplete,
    );
  }

  Widget _buildPasswordTextField() {
    bool showErrorMessage =
        _submitted && !widget.passwordValidator.isValid(_password);

    return TextField(
      controller: _passwordEditingController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
          labelText: 'Password',
          errorText: showErrorMessage ? widget.passwordValidErrorText : null),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: (password) => _updateState(),
      onEditingComplete: _submit,
    );
  }

  // 状態更新
  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren()),
    );
  }
}
