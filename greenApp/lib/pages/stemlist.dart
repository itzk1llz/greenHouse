import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class Stem {
  String stem_name;
  String stem_function;
  String stem_id;

  Stem({
    required this.stem_name,
    required this.stem_function,
    required this.stem_id,
  });




}

class StemList extends StatefulWidget {
  const StemList({super.key});

  @override
  State<StemList> createState() => _StemListState();
}

class _StemListState extends State<StemList> {

  Future<List<Stem>> fetchStem() async {
    final response = await http.get(Uri.parse('http://192.168.0.113:8080/getstemlist'));

    var responseData = json.decode(response.body);

    List<Stem> stemlist = [];

    for(var onestem in responseData) {
      Stem stem = Stem (
        stem_name: onestem["Stem_name"],
        stem_function: onestem["Stem_function"],
        stem_id: onestem["Stem_id"],
      );
      stemlist.add(stem);
    }

    return stemlist;
  }
  late Future<List<Stem>> futureStem;

  @override
  void initState(){
    super.initState();
    futureStem = fetchStem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pairedStemsText(),
            const SizedBox(
              height:20,
            ),

                stemList()

              ],
            ),

        ),


    );
  }

  Expanded stemList() {
    return Expanded(
                child: FutureBuilder<List<Stem>>(
                    future: fetchStem(),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if(snapshot.data == null) {
                        return Container (
                          child: Center(
                            child: CircularProgressIndicator()
                          ),
                        );
                      } else {
                        return Container (
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListView.builder(
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      height: 50,
                                      width: 350,
                                      decoration: BoxDecoration(
                                        color: Color(0xfff5f5ed),
                                        borderRadius: BorderRadius.circular(10),

                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width:15,),
                                              Text(
                                                snapshot.data[index]!.stem_name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              SizedBox(width:15,),
                                              Text(
                                                snapshot.data[index].stem_function,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontStyle: FontStyle.italic,

                                                ),
                                              ),
                                              SizedBox(width: 15,),
                                              GestureDetector(
                                                onTap: () {
                                                  print("Tapped X of " + snapshot.data[index].stem_name);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 5),
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                    ),
                                                    child: Text("  X"),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(width: 15,),
                                              Text(
                                                "Serial: ",
                                                style: TextStyle(

                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                snapshot.data[index].stem_id,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height: 10,
                                    ),

                                  ],
                                );
                              },
                              itemCount: snapshot.data.length),
                        );
                      }
                    }
                ),
              );
  }

  Padding pairedStemsText() {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: const Text(
              "Paired stems",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 30,
              ),
            ),
    );
  }
}
