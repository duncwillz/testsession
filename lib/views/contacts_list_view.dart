import 'package:flutter/material.dart';
import 'package:flutter_app_sample/bloc/contacts_bloc.dart';
import 'package:flutter_app_sample/model/contact_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactListView extends StatefulWidget {
  @override
  _ContactListViewState createState() => _ContactListViewState();
}

class _ContactListViewState extends State<ContactListView> {
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
            Expanded(
              child: NotificationListener(
                  onNotification: (ScrollNotification scrollInfo) {
                if (contacts.isNotEmpty &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !contactBloc.loadedAll) {
                  int pageNumber = ((contacts.length / limit).truncate());
                  contactBloc.loadContact(
                      limit: limit, pageNumber: ++pageNumber);
                }
                return true;
              }, child: BlocBuilder<ContactBloc, ContactsState>(
                      builder: (context, state) {
                if (state is ContactsLoaded) {
                  contacts = state.contacts;
                }
                return content(state: state);
              })),
            ),
            BlocBuilder<ContactBloc, ContactsState>(builder: (context, state) {
              return Column(
                children: <Widget>[
                  if (contacts.isNotEmpty && state is LoadingContacts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        height: 40,
                        child: Center(
                          child: SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              )),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget content({ContactsState state}) {
    return state is LoadingContacts && contacts.isEmpty
        ? Center(
            child: CircularProgressIndicator(),
          )
        : state is ContactsLoaded || contacts.isNotEmpty
            ? ListView.builder(
                itemCount: contacts.length + 1,
                itemBuilder: (context, itemIndex) {
                  bool isLoadingContacts = state is LoadingContacts;
                  if (itemIndex == contacts.length) {
                    if (contactBloc.loadedAll) {
                      return Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: FlutterLogo());
                    }
                    return Container();
                  } else if (itemIndex < contacts.length) {
                    ContactsModel contact = contacts[itemIndex];
                    return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          child: CircleAvatar(
                            radius: 20,
                            child: contact.avatarUrl == ""
                                ? Image.asset(
                                    "assets/img/avatar.jpeg",
                                    fit: BoxFit.fill,
                                  )
                                : Image.network(contact.avatarUrl),
                          ),
                        ),
                        title: Text(contact.name),
                        subtitle: Text(contact.email));
                  }
                  return Container();
                })
            : state is LoadingError
                ? Container(
                    child: Center(
                        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        state.message,
                        style: TextStyle(color: Colors.red),
                      ),
                      FlatButton(
                          onPressed: () {
                            contacts = [];
                            contactBloc.loadContact(
                                limit: limit, pageNumber: 1);
                          },
                          child: Text("Retry"))
                    ],
                  )))
                : SizedBox();
  }
}
