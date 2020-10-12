import 'package:flutter/material.dart';
import 'package:flutter_app_sample/core/service/firebase_service.dart';
import 'package:flutter_app_sample/views/contact_bloc_list_view.dart';
import 'package:flutter_app_sample/views/contacts_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'bloc/contacts_bloc.dart';
import 'bloc/contacts_old_bloc.dart';
import 'di/dependencies_injector.dart';
import 'model/contact_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Flutter bloc
      //  home: ContactListView(),
      // Old Bloc
      home: ChangeNotifierProvider<ContactsOldBloc>(
          create: (context) => contactsOldBloc, child: ContactsBlocListView()),
    );
  }
}
