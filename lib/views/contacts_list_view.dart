import 'package:flutter/material.dart';
import 'package:flutter_app_sample/bloc/contacts_bloc.dart';
import 'package:flutter_app_sample/model/contact_model.dart';
import 'package:flutter_app_sample/util/string_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactListView extends StatefulWidget {
  @override
  _ContactListViewState createState() => _ContactListViewState();
}

class _ContactListViewState extends State<ContactListView> {
  @override
  void initState() {
    // Load 1st page first
    contactBloc.loadContact();
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
                style: TextStyle(
                    fontSize: 20, color: Colors.black.withOpacity(0.5)),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: NotificationListener(
                  onNotification: (ScrollNotification scrollInfo) {
                    // Load next page when scrolled to bottom and if there are
                    // more contacts to fetch.
                    if (contactBloc.contacts.isNotEmpty &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        !contactBloc.loadedAll &&
                        !contactBloc.isLoadingMore) {
                      contactBloc.isLoadingMore = true;
                      contactBloc.loadContact(
                          pageNumber: ++contactBloc.initialPageNumber);
                    }
                    return true;
                  },

                  // Contact List
                  child: BlocBuilder<ContactBloc, ContactsState>(
                      condition: (_, state) => state is ContactsLoaded,
                      builder: (context, state) {
                        if (state is ContactsLoaded) {
                          contactBloc.contacts = state.contacts;
                          contactBloc.isLoadingMore = false;
                        }
                        return content(state: state);
                      })),
            ),

            // Loading more indicator
            BlocBuilder<ContactBloc, ContactsState>(builder: (context, state) {
              return Column(
                children: <Widget>[
                  if (contactBloc.contacts.isNotEmpty &&
                      state is LoadingContacts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        height: 20,
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
    return state is LoadingContacts && contactBloc.contacts.isEmpty
        ?
        // Empty, loading state
        Center(child: CircularProgressIndicator())
        :

        // Loaded State
        state is ContactsLoaded || contactBloc.contacts.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  itemCount: contactBloc.contacts.length + 1,
                  itemBuilder: (context, itemIndex) {
                    bool isLoadingContacts = state is LoadingContacts;
                    if (itemIndex == contactBloc.contacts.length) {
                      if (contactBloc.loadedAll) {
                        return Padding(
                            padding: EdgeInsets.only(bottom: 20, top: 20),
                            child: FlutterLogo(
                              size: 50,
                            ));
                      }
                      return Container();
                    } else if (itemIndex < contactBloc.contacts.length) {
                      ContactsModel contact = contactBloc.contacts[itemIndex];

                      return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: contact.avatarUrl == ""
                                  ? AssetImage(
                                      AssetPath.defaultAvatar,
                                    )
                                  : NetworkImage(contact.avatarUrl),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            contact.email,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w400),
                          ));
                    }
                    return Container();
                  },
                  separatorBuilder: (context, itemIndex) {
                    return Divider(
                      height: 1,
                    );
                  },
                ),
              )

            // Error State
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
                            contactBloc.contacts = [];
                            contactBloc.loadContact(pageNumber: 1);
                          },
                          child: Text("Retry"))
                    ],
                  )))
                : SizedBox();
  }
}
