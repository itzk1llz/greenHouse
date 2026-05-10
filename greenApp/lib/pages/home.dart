import 'package:flutter/material.dart';
import 'package:green_app/models/portlist.dart';
import 'package:green_app/pages/stemlist.dart';
import '../models/stem.dart';
const List<String> stemtypes = ["Thermometer", "Soil Humidity", "Light"];
class HomePage extends StatefulWidget {
  HomePage({super.key});

  



  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  String portSelection = "";
  String stemType = "";
  
  final TextEditingController _controller = TextEditingController();

  late Future<List<Stem>> futureStem;

  @override
  void initState() {
    super.initState();
    futureStem = Stem.fetchStem();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appBar(context),
      bottomNavigationBar: bottomNavbar(),
      body: selectedIndex == 0 ? buildHomePage() : StemList(),
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

  Column buildHomePage() {
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
        ),
        SizedBox(height: 20,),
        Expanded(child: stemShower()),
      ],
    );
  }

  FutureBuilder<List<Stem>> stemShower() {
    return FutureBuilder<List<Stem>>(future: Stem.fetchStem(), builder: (BuildContext ctx, AsyncSnapshot<List<Stem>> snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if(snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if(snapshot.data != null && snapshot.data!.isNotEmpty) {
        return Container (
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) {
                return GestureDetector(
                  onTap: () async {
                    await openStemModal(context, snapshot.data![index]);
                    setState(() {
                      futureStem = Stem.fetchStem();
                    });
                  },
                  child: Stem.stemType(snapshot, index));
                  
              },
            ),
          );
      } else {
        return Center(child: Text('No stems paired.'));
      }
    });
  }

  AppBar appBar(BuildContext context) {
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
            print("bogdanmateicostin");
            openModal(context);
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

  Future<dynamic> openModal(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return _PortSelectionModal();
        }
    );
  }
    Future<dynamic> openStemModal(BuildContext context, Stem stem) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return stemUpdate(stem);
        }
    );
  }

    Container stemUpdate(Stem stem) {
      return Container(
          height: 300,
          width: 500,
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                stem.stem_name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                ),
                SizedBox(height: 1),
                Text(
                  stem.stem_function,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    
                  ),
                ),
                Divider(),
                SizedBox(height: 4,),
                Text(
                  "Update name",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  
                  ),
                SizedBox(height: 10,),
                SizedBox(
                  width:300,
                  height: 50,
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter new name (max 10 chars.)",
                      hintStyle: TextStyle(
                        color: Color(0xfdddada),
                        fontSize: 12,
                      ),
                      filled: false,
                      contentPadding: EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xff6d9e32), width: 1,)
                      )
                    ), 
                  ),
                ),
                SizedBox(height: 10,),
                GestureDetector(
                  onTap: () async {
                    if(_controller.text.length <= 10){
                      _controller.text.trim();
                      print("Contents of textfield: ${_controller.text}");
                      await Stem.sendNameUpdate(_controller.text, stem.stem_id);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xff6d9e32),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Update",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                  ),
                )
            ],
          ),
        );
    }
}

class _PortSelectionModal extends StatefulWidget {
  @override
  _PortSelectionModalState createState() => _PortSelectionModalState();
}

class _PortSelectionModalState extends State<_PortSelectionModal> {
  String? portSelection;
  String? stemType;
  final TextEditingController _wificontroller = TextEditingController();
  final TextEditingController _passcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select a serial port"),
          Expanded(
            child: FutureBuilder<List<Port_item>>(
              future: Port_item.fetchPorts(),
              builder: (BuildContext ctx, AsyncSnapshot<List<Port_item>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, index) {
                      return RadioListTile<String>(
                        title: Text(snapshot.data![index].port_name),
                        value: snapshot.data![index].port_name,
                        groupValue: portSelection,
                        onChanged: (String? value) {
                          setState(() {
                            portSelection = value!;
                          });
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No ports available.'));
                }
              },
            ),
          ),
          Divider(),
          SizedBox(height: 10),
          Text("What kind of stem are you adding?"),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (ctx, index) {
                return RadioListTile<String>(
                  title: Text("${stemtypes[index]}"),
                  value: index.toString(),
                  groupValue: stemType,
                  onChanged: (String? value) {
                    setState(() {
                      stemType = value;
                    });
                  },
                );
              },
            ),
          ),
          Divider(),
          SizedBox(height: 10),
          Text("Enter your wifi ssid"),
          addStemTextField(_wificontroller, "Enter wifi creds (max 10 chars.)"),
          SizedBox(height: 10),
          Text("Enter your wifi password"),
          addStemTextField(_passcontroller, "Enter wifi pass (max 10 chars.)"),
               
                
          ElevatedButton(
            onPressed: () {
              if (portSelection != null && stemType != null && _passcontroller.text != "" && _wificontroller.text != "" && _passcontroller.text.length <= 10 && _wificontroller.text.length <= 10) {
                // TODO: Add stem using selected port
                String stemtypeliteral = "";
                switch(stemType!) {
                  case "0":
                    stemtypeliteral = "thermohum";
                    break;
                  case "1":
                    stemtypeliteral = "soilhum";
                    break;
                  case "2":
                    stemtypeliteral = "light";
                    break;
                  default:
                    break;
                }
                Port_item.sendSelection(portSelection!, stemtypeliteral, _wificontroller.text, _passcontroller.text);
                print(portSelection! + " and " + stemtypeliteral + " and " + _wificontroller.text + " and " + _passcontroller.text);
                Navigator.of(context).pop();
                
              }
            },
            
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  TextField addStemTextField(TextEditingController ctrl, String hint) {
    return TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Color(0xfdddada),
                      fontSize: 12,
                    ),
                    filled: false,
                    contentPadding: EdgeInsets.all(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xff6d9e32), width: 1,)
                    )
                  ), 
                );
  }
}