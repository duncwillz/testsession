import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_sample/bloc/contacts_old_bloc.dart';
import 'package:flutter_app_sample/di/dependencies_injector.dart';
import 'package:flutter_app_sample/model/contact_model.dart';
import 'package:flutter_app_sample/util/string_types.dart';
import 'package:provider/provider.dart';

class ContactsBlocListView extends StatefulWidget {
  @override
  _ContactsBlocListViewState createState() => _ContactsBlocListViewState();
}

class _ContactsBlocListViewState extends State<ContactsBlocListView> {
  @override
  void initState() {
    contactsOldBloc.getContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              style:
                  TextStyle(fontSize: 20, color: Colors.black.withOpacity(0.5)),
              textAlign: TextAlign.left,
            ),
          ),
          StreamBuilder<List<ContactsModel>>(
            stream: contactsOldBloc.contactsStream,
            builder: (context, snapshot) {
              if (snapshot.data != null && snapshot.data.isNotEmpty) {
                return Expanded(
                    child: NotificationListener(
                  onNotification: (ScrollNotification scrollInfo) {
                    // Load next page when scrolled to bottom and if there are
                    // more contacts to fetch.
                    if (snapshot.data.isNotEmpty &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        !contactsOldBloc.loadedAll &&
                        !contactsOldBloc.isLoadingMore) {
                      contactsOldBloc.notifyLoadingMore(state: true);
                      contactsOldBloc.getContacts(
                          pageNumber: ++contactsOldBloc.initialPageNumber);
                    }
                    return true;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.separated(
                      itemCount: snapshot.data.length + 1,
                      itemBuilder: (context, itemIndex) {
                        if (itemIndex == snapshot.data.length) {
                          if (contactsOldBloc.loadedAll) {
                            return Padding(
                                padding: EdgeInsets.only(bottom: 20, top: 20),
                                child: FlutterLogo(
                                  size: 50,
                                ));
                          }
                          return Container();
                        } else if (itemIndex < snapshot.data.length) {
                          ContactsModel contact = snapshot.data[itemIndex];
                          return contactListTile(contact);
                        }
                        return Container();
                      },
                      separatorBuilder: (context, itemIndex) {
                        return Divider(
                          height: 1,
                        );
                      },
                    ),
                  ),
                ));
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return Expanded(
                    child: Center(child: CircularProgressIndicator()));
              }
              return Container();
            },
          ),
          Provider.of<ContactsOldBloc>(context).isLoadingMore
              ? Padding(
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
                )
              : SizedBox(),
        ],
      ),
    );
  }

  /// Render the contact list tile with [contact] object
  Widget contactListTile(ContactsModel contact) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(StringType.collectionName)
          .document(contact.id)
          .snapshots(),
      builder: (context, AsyncSnapshot snapShot) {
        if (!snapShot.hasData) return SizedBox();
        ContactsModel contact = ContactsModel.fromJson(snapShot.data.data);
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              contact.email,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ));
      },
    );
  }
}
