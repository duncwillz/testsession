import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_sample/core/persistance/local_cache.dart';
import 'package:flutter_app_sample/model/contact_model.dart';
import 'package:flutter_app_sample/util/string_types.dart';

abstract class FirebaseService {
  bool loadedAll = false;
  Stream<DocumentSnapshot> subscribeDocument(id);
  Future getContacts(int fetchLimit, int pageNumber);
}

class FirebaseServiceImpl extends FirebaseService {
  DocumentSnapshot lastDocument;

  /// Fetch and cache a list of [fetchLimit] contacts starting at page number [pageNumber]
  @override
  Future getContacts(int fetchLimit, int pageNumber) async {
    List<ContactsModel> contacts = [];
    QuerySnapshot querySnapshot;
    await Future.delayed(Duration(seconds: 1), () async {
      // Future.Delayed to simulate network delay
      try {
        if (pageNumber == 1) {
          querySnapshot = await Firestore.instance
              .collection(StringType.collectionName)
              .orderBy(StringType.fieldName, descending: false)
              .limit(fetchLimit)
              .getDocuments();
          lastDocument = querySnapshot.documents.last;
        } else {
          querySnapshot = await Firestore.instance
              .collection(StringType.collectionName)
              .orderBy(StringType.fieldName, descending: false)
              .startAfterDocument(lastDocument)
              .limit(fetchLimit)
              .getDocuments();
          if (querySnapshot.documents.isNotEmpty) {
            lastDocument = querySnapshot.documents.last;
          }
        }
        if (querySnapshot != null && querySnapshot.documents.isNotEmpty) {
          querySnapshot.documents.forEach((doc) {
            final contact = ContactsModel.fromJson(doc.data);
            contact.id = doc.documentID;
            contacts.add(contact);
          });
        }
      } catch (e) {
        throw ServiceException(exceptionMessage: e);
      }

      // Set loadedAll flag for when all contacts are loaded
      //  Any page that loads less than the limit is the last page
      // (Or 0 meaning the previous fully filled page was the last)
      if (contacts.length < fetchLimit || contacts.length == 0) {
        loadedAll = true;
      }
      var mapData = Map<String, ContactsModel>.fromIterable(contacts,
          key: (contact) => contact.email, value: (contact) => contact);

      // Cache data. Bloc reads directly from cache, passes this to UI
      cacheData.addAll(mapData);
    });
  }

  /// Subscribe to document with it's [id]
  @override
  Stream<DocumentSnapshot> subscribeDocument(id) {
    return Firestore.instance
        .collection(StringType.collectionName)
        .document(id)
        .snapshots();
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
