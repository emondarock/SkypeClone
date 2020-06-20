import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:skypeclone/models/users.dart';
import 'package:skypeclone/resources/firebase_rapository.dart';
import 'package:skypeclone/screens/ChatScreen.dart';
import 'package:skypeclone/utils/universal_variables.dart';
import 'package:skypeclone/widgets/custom_tile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseRepository _repository = FirebaseRepository();


  List<User> userList;
  String query = "";
  TextEditingController searchEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _repository.getCurrentUser().then((user) {
      _repository.fetchAllUser(user).then((List<User> list){
        print("AllList $list");
        setState(() {
          userList = list;
        });
      });
    });
  }

  searchAppBar(context){
    return GradientAppBar(
      backgroundColorStart: UniversalVariables.gradientColorStart,
      backgroundColorEnd: UniversalVariables.gradientColorEnd,
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: TextField(
              controller: searchEditingController,
              onChanged: (val){
                setState(() {
                  query = val;
                });
              },
              cursorColor: UniversalVariables.blackColor,
              autofocus: true,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 30
              ),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: (){
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => searchEditingController.clear());
                  },
                ),
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0x88ffffff),
                    fontSize: 30
                )
              ),
            ),
          ),
          preferredSize: const Size.fromHeight(kToolbarHeight + 20)
      ),
    );
  }

  buildSuggestion(String query){
    final List<User> suggestionList = query.isEmpty
        ? []
        : userList.where(
            (User user) {
              String _getUsername = user.username.toLowerCase();
              String _query = query.toLowerCase();
              String _getName = user.name.toLowerCase();
              bool matchesUsername = _getUsername.contains(_query);
              bool matchesName = _getName.contains(_query);

              return (matchesUsername || matchesName);
            }).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index){
        User searchedUser = User(
          uid: suggestionList[index].uid,
          profilePhoto: suggestionList[index].profilePhoto,
          name: suggestionList[index].name,
          username: suggestionList[index].username
        );
        print("SearchedUser, $searchedUser");
        return CustomTile(
          mini: false,
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  receiver: searchedUser,

                )
              )
            );
          },
          leading: CircleAvatar(
            backgroundImage: searchedUser.profilePhoto != null
            ? NetworkImage(searchedUser.profilePhoto)
            : AssetImage('assets/default.png'),
            backgroundColor: Colors.grey,
          ),
          title: Text(
            searchedUser.username,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          subTitle: Text(
            searchedUser.name,
            style: TextStyle(
              color: UniversalVariables.greyColor
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: searchAppBar(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: buildSuggestion(query),
      ),
    );
  }
}
