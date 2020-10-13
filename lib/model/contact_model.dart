class ContactsModel {
  String id;
  String name;
  String email;
  String avatarUrl;

  ContactsModel({this.name, this.email, this.avatarUrl});

  ContactsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    avatarUrl = json['avatarUrl'];
  }
}
