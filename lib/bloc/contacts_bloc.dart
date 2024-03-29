import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_sample/core/persistance/local_cache.dart';
import 'package:flutter_app_sample/di/dependencies_injector.dart';
import 'package:flutter_app_sample/core/service/firebase_service.dart';
import 'package:flutter_app_sample/model/contact_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactBloc extends Bloc<ContactEvent, ContactsState> {
  FirebaseService firebaseService;

  List<ContactsModel> contacts = [];

  //Set the fetch limit to preference
  final int fetchLimit = 10;
  int initialPageNumber = 1;

  bool isLoadingMore = false;

  ContactBloc({this.firebaseService});

  void loadContact({int pageNumber}) {
    add(LoadContacts(
        limit: fetchLimit, pageNumber: pageNumber ?? initialPageNumber));
  }

  bool get loadedAll => firebaseService.loadedAll;

  @override
  ContactsState get initialState => LoadingContacts();

  @override
  Stream<ContactsState> mapEventToState(ContactEvent event) async* {
    if (event is LoadContacts) {
      yield LoadingContacts();
      try {
        await firebaseService.getContacts(event.limit, event.pageNumber);
        yield ContactsLoaded(contacts: cacheData.values.toList());
      } on ServiceException {
        yield LoadingError(message: "Error loading from firebase");
      } on Exception {
        yield LoadingError(message: "An unknown error occured");
      }
    }
  }
}

abstract class ContactsState {}

class ContactsLoaded extends ContactsState {
  List<ContactsModel> contacts;
  ContactsLoaded({this.contacts});
}

class LoadingContacts extends ContactsState {}

class LoadingError extends ContactsState {
  String message;
  LoadingError({this.message});
}

class LoadedAllContacts extends ContactsState {}

class LoadContacts extends ContactEvent {
  int pageNumber, limit;
  LoadContacts({this.limit, this.pageNumber});
}

abstract class ContactEvent {}

final contactBloc = ContactBloc(firebaseService: getIt());
