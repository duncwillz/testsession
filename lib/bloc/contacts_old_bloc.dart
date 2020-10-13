import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_sample/core/persistance/local_cache.dart';
import 'package:flutter_app_sample/core/service/firebase_service.dart';
import 'package:flutter_app_sample/di/dependencies_injector.dart';
import 'package:flutter_app_sample/model/contact_model.dart';

abstract class Bloc with ChangeNotifier {
  void dispose();
}

class ContactsOldBloc extends Bloc {
  //Set the fetch limit to preference
  final int fetchLimit = 10;
  int initialPageNumber = 1;
  bool isLoadingMore = false;

  bool get loadedAll => firebaseService.loadedAll;
  FirebaseService firebaseService;

  ContactsOldBloc({this.firebaseService});

  List<ContactsModel> contacts = [];

  final _contactsController = StreamController<List<ContactsModel>>();

  Stream<List<ContactsModel>> get contactsStream => _contactsController.stream;

  getContacts({int pageNumber}) async {
    contacts = await firebaseService.getContacts(
        fetchLimit, pageNumber ?? initialPageNumber);
    _contactsController.sink.add(cacheData.values.toList());
    notifyLoadingMore(state: false);
  }

  Stream<DocumentSnapshot> subscribeToContact(String id) {
    return firebaseService.subscribeDocument(id);
  }

  ContactsModel getContact(DocumentSnapshot snapShot) {
    return ContactsModel.fromJson(snapShot.data);
  }

  notifyLoadingMore({bool state}) {
    isLoadingMore = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _contactsController.close();
    super.dispose();
  }
}

final contactsOldBloc = ContactsOldBloc(firebaseService: getIt());
