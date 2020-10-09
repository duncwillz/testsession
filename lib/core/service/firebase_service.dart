import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_sample/core/persistance/local_cache.dart';
import 'package:flutter_app_sample/model/contact_model.dart';

abstract class FirebaseService {
  bool loadedAll = false;
  Future getContacts(int limit, int pageNumber);
}

class FirebaseServiceImpl extends FirebaseService {
  DocumentSnapshot lastDocument;

  /// Fetch and cache a list of [limit] contact starting at [page]
  @override
  Future getContacts(int limit, int pageNumber) async {
    List<ContactsModel> contacts = [];
    QuerySnapshot qs;
    await Future.delayed(Duration(seconds: 2), () async {
      try {
        if (pageNumber == 1) {
          qs = await Firestore.instance
              .collection("contacts")
              .orderBy("name")
              .limit(limit)
              .getDocuments();
          lastDocument = qs.documents.last;
        } else {
          qs = await Firestore.instance
              .collection("contacts")
              .orderBy("name")
              .startAfterDocument(lastDocument)
              .limit(limit)
              .getDocuments();
          if (qs.documents.isNotEmpty) {
            lastDocument = qs.documents.last;
          }
        }
        if (qs != null && qs.documents.isNotEmpty) {
          qs.documents
              .forEach((doc) => contacts.add(ContactsModel.fromJson(doc.data)));
        }
      } catch (e) {
        throw ServiceException(exceptionMessage: e);
      }
      if (contacts.length < limit || contacts.length == 0) {
        loadedAll = true;
      }
      var mapData = Map<String, ContactsModel>.fromIterable(contacts,
          key: (c) => c.email, value: (c) => c);

      cacheData.addAll(mapData);
    });
  }
}

class ServiceException implements Exception {
  var exceptionMessage;
  var data;

  ServiceException({this.exceptionMessage, this.data});

  @override
  String toString() {
    return '{exceptionMessage: $exceptionMessage, data: $data}';
  }
}
