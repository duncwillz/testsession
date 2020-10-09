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

  ContactBloc({this.firebaseService});

  void loadContact({int limit, int pageNumber}) {
    add(LoadContacts(limit: limit, pageNumber: pageNumber));
  }

  bool get loadedAll => firebaseService.loadedAll;

  @override
  ContactsState get initialState => LoadingContacts();

  @override
  Stream<ContactsState> mapEventToState(ContactEvent event) async* {
    if (event is LoadContacts) {
      yield LoadingContacts();
      try {
        Future.delayed(Duration(seconds: 3000));
        await firebaseService.getContacts(event.limit, event.pageNumber);
        yield ContactsLoaded(contacts: cacheData.values.toList());
      } on ServiceException catch (e) {
        yield LoadingError(message: "Error loading from firebase");
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
  bool loadMore;
  LoadContacts({this.limit, this.pageNumber, this.loadMore = false});
}

abstract class ContactEvent {}

final contactBloc = ContactBloc(firebaseService: getIt());
