import 'dart:math';

import 'package:mnehomeapp/bloc/login_bloc.dart';
import 'package:mnehomeapp/component/bootstrap/bootstrap.dart';
import 'package:mnehomeapp/main.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginForm extends StatefulWidget {
  final BootstrapController? controller;

  const LoginForm({Key? key, this.controller}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  var lastUserName = 'admin';
  var lastPassword = '';
  var urlToCouchDb = '';
  var sendAsBasicAuth = false;
  var storeAuthDataInClient = false;

  @override
  void initState() {
    super.initState();
    storeAuthDataInClient = preferences.getBool('storeAuth') ?? false;
    sendAsBasicAuth = preferences.getBool('sendbasic') ?? false;
    lastUserName = preferences.getString('username') ?? 'admin';
    lastPassword = preferences.getString('password') ?? '';
    urlToCouchDb =
        preferences.getString('serverUrl') ?? 'http://localhost:8080';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (bcontext) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (bcontext, state) {
          if (state is LoginOk) {
            if (widget.controller != null) {
              widget.controller?.procced();
            } else {
              Navigator.of(bcontext).pushReplacementNamed('dashboard');
            }
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (bcontext, state) {
            return Center(
              child: buildContent(bcontext, state),
            );
          },
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context, LoginState state) {
    //Ok is handled in the listener inside build
    if (state is LoginInitial || state is LoginFailed) {
      var corsError = false;
      var errorMessage = '';
      if (state is LoginFailed) {
        corsError = state.maybeCors;
        errorMessage = state.message;
      }
      return buildForm(context, state is LoginFailed, corsError, errorMessage);
    } else if (state is LoginRunning) {
      return const CircularProgressIndicator();
    } else {
      debugPrint("Login form BadState " + state.toString());
      return const Text('This is not the text you are looking for');
    }
  }

  Widget buildForm(
      BuildContext context, bool error, bool maybeCors, String errorMessage) {
    final maxWidth = MediaQuery.of(context).size.width;
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: min(500, maxWidth),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  HomeServerLocalizations.of(context)!.titleLogin,
                  style: Theme.of(context).textTheme.headline4,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    helperText: 'Server url',
                  ),
                  initialValue: urlToCouchDb,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'URL required';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    urlToCouchDb = value ?? '';
                  },
                ),
                TextFormField(
                  initialValue: lastUserName,
                  decoration: const InputDecoration(
                    helperText: 'User name',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'User name required';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    lastUserName = value ?? '';
                  },
                ),
                TextFormField(
                  obscureText: true,
                  obscuringCharacter: '*',
                  decoration: InputDecoration(
                    helperText: 'Password',
                    errorText: error ? getError(maybeCors, errorMessage) : null,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Password required';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    lastPassword = value ?? '';
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 15)),
                ExpansionTile(
                  title: const Text('Advanced options'),
                  children: [
                    SwitchListTile(
                      title: const Text('Send basic auth'),
                      subtitle: const Text('All request contain this'),
                      value: sendAsBasicAuth,
                      onChanged: (newValue) {
                        setState(() {
                          sendAsBasicAuth = newValue;
                        });
                      },
                    ),
                    SwitchListTile(
                        title: const Text('Save authentication'),
                        subtitle: const Text(
                            'Either stores your user and password or checks the authentication cookie'),
                        value: storeAuthDataInClient,
                        onChanged: (newValue) {
                          setState(() {
                            storeAuthDataInClient = newValue;
                          });
                        })
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NeumorphicButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          //Let bloc request a login
                          BlocProvider.of<LoginBloc>(context).add(
                            LoginRequest(
                              urlToCouchDb,
                              lastUserName,
                              lastPassword,
                              sendAsBasicAuth,
                              storeAuthDataInClient,
                            ),
                          );
                        }
                      },
                      child: const Text('Login'),
                    ),
                    NeumorphicButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('cors');
                      },
                      child: const Text('Login issue?'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getError(bool corsError, String message) {
    if (corsError) {
      return 'Maybe CORS error, see help';
    } else if (message != '') {
      return message;
    }
    return 'User or password wrong';
  }
}
