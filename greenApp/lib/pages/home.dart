import 'package:flutter/material.dart';
import 'package:green_app/pages/stemlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appBar(),
      bottomNavigationBar: bottomNavbar(),
      body: selectedIndex == 0 ? HomePage() : StemList(),
    );
  }

  BottomNavigationBar bottomNavbar() {
    return BottomNavigationBar(

        selectedItemColor: Color(0xff000000),
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi),
            label: "Stems",
          ),
        ],

    );
  }

  Column HomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15,top: 20),
          child: Text(
              "🌻  Welcome!",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 30,
              ),
          ),
        )
      ],

    );
  }
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        "greenApp",
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      elevation: 0.0,

      backgroundColor: Color(0xff6d9e32),
      actions: [
        GestureDetector(
          onTap: () {
            // TODO: add functionality so it can add stems
            print("yes");
          },
          child: Container(
            width: 37,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                  Icons.add,
                  color: Colors.black,

              ),
            ),

          ),
        ),
      ],
    );

  }


