import 'package:flutter/material.dart';
import 'package:flutter_app_sample/core/service/firebase_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/contacts_bloc.dart';
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ContactsModel> contacts = [];
  int limit = 3;
  @override
  void initState() {
    contactBloc.loadContact(limit: limit, pageNumber: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactBloc>(
      create: (context) => contactBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Firestore contacts"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20),
              child: Text(
                "All Contacts",
                textAlign: TextAlign.left,
              ),
            ),
            BlocBuilder<ContactBloc, ContactsState>(builder: (context, state) {
              if (state is ContactsLoaded) {
                contacts = state.contacts;
              }
              return Expanded(
                child: NotificationListener(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (state is ContactsLoaded &&
                          contacts.isNotEmpty &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent &&
                          !contactBloc.loadedAll) {
                        int pageNumber = ((contacts.length / limit).truncate());
                        contactBloc.loadContact(
                            limit: limit, pageNumber: ++pageNumber);
                      }
                      return true;
                    },
                    child: state is LoadingContacts &&
                            contacts.isEmpty &&
                            state is LoadingError
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : state is ContactsLoaded
                            ? ListView.builder(
                                itemCount: contacts.length,
                                itemBuilder: (context, itemIndex) {
                                  ContactsModel contact = contacts[itemIndex];
                                  return ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        child: CircleAvatar(
                                          radius: 20,
                                          child: contact.avatarUrl == ""
                                              ? FlutterLogo()
                                              : Image.network(
                                                  contact.avatarUrl),
                                        ),
                                      ),
                                      title: Text(contact.name),
                                      subtitle: Text(contact.email));
                                })
                            : state is LoadingError
                                ? Container(
                                    child: Center(child: Text(state.message)))
                                : SizedBox()),
              );
            }),
            BlocBuilder<ContactBloc, ContactsState>(builder: (context, state) {
              return Column(
                children: <Widget>[
                  if (contacts.isNotEmpty && state is LoadingContacts)
                    Container(
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (contactBloc.loadedAll) ...[
                    Center(
                      child: FlutterLogo(),
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ]
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
