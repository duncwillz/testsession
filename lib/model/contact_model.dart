class ContactsModel {
  String name;
  String email;
  String avatarUrl;

  ContactsModel({this.name, this.email, this.avatarUrl});

  ContactsModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    avatarUrl = json['avatarUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['avatarUrl'] = this.avatarUrl;
    return data;
  }
}
