import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterrentalapp/Models/AppConstants.dart';
import 'package:flutterrentalapp/Models/data.dart';
import 'package:flutterrentalapp/Models/review_objects.dart';
import 'package:flutterrentalapp/Models/user_objects.dart';
import 'package:flutterrentalapp/Screens/guest_home_page.dart';
import 'package:flutterrentalapp/Views/form_widgets.dart';
import 'package:flutterrentalapp/Views/list_widgets.dart';
import 'package:flutterrentalapp/Views/text_widgets.dart';

class view_profile_page extends StatefulWidget {
  static final String routeName = '/viewProfilePageRoute';

  final Contact contact;

  view_profile_page({this.contact, Key key}) : super(key: key);

  @override
  _view_profile_page_state createState() => _view_profile_page_state();
}

class _view_profile_page_state extends State<view_profile_page> {

  Contact _contact;
  User _user;

  @override
  void initState() {
    if(widget.contact.id == AppConstants.currentUser.id){
      this._user = AppConstants.currentUser;
    } else {
      this._user =widget.contact.createUserFromContact();
      this._user.getUserInfoFromFirestore().whenComplete(() {
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarText(text: 'View Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(35, 50, 35, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: AutoSizeText(
                              'Hello! My name is ${_user.firstName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          CircleAvatar(

                            backgroundColor: Colors.black,
                            radius: MediaQuery.of(context).size.width / 9.5,
                            child: CircleAvatar(
                              backgroundImage:
                                  _user.displayImage,
                              radius: MediaQuery.of(context).size.width / 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'About Me',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AutoSizeText(
                  _user.bio,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.home),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: AutoSizeText(
                          'Lives in ${_user.city}, ${_user.country}',
                          minFontSize: 20,
                          maxLines: 2,

                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'Reviews:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:20.0),
                child: review_form(user: this._user,),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: StreamBuilder(
                  stream: Firestore.instance.collection('users/${_user.id}/reviews').orderBy('dateTime',descending: true).snapshots(),
                  builder: (context,snapshots){
                    switch (snapshots.connectionState){
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        return ListView.builder(
                          itemCount: snapshots.data.documents.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            DocumentSnapshot snapshot = snapshots.data.documents[index];
                            Review currentReview = Review();
                            currentReview.getReviewInfoFromFirestore(snapshot);
                            return Padding(
                              padding: const EdgeInsets.only(top:10.0,bottom:10.0),
                              child: ReviewListTile(review: currentReview),
                            );
                          },
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
