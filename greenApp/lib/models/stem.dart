import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Stem extends StatefulWidget {
  final String stem_name;
  final String stem_function;
  final String stem_id;
  final AsyncSnapshot<List<Stem>>? snapshot; 
  final int? index;  
  final String? stem_data;

  Stem({
    required this.stem_name,
    required this.stem_function,
    required this.stem_id,
    this.snapshot,  // Optional
    this.index,    // Optional
    this.stem_data, // Optional
    super.key,
  });

  static Future<List<Stem>> fetchStem() async {
    final response = await http.get(Uri.parse("http://${dotenv.get("GH_ADDR")}:${dotenv.get("GH_PORT")}/getstemlist"));

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

  static Widget stemType(AsyncSnapshot<List<Stem>> snapshot, int index) {
    var stemData = snapshot.data![index];
    if (stemData.stem_function == "thermohum") {
      return Stem(
        stem_name: stemData.stem_name,
        stem_function: stemData.stem_function,
        stem_id: stemData.stem_id,
        // No snapshot/index needed for thermohum
      );
    } else if (stemData.stem_function == "light") {
      return Stem(
        stem_name: stemData.stem_name,
        stem_function: stemData.stem_function,
        stem_id: stemData.stem_id,
        snapshot: snapshot,  // Pass snapshot
        index: index,        // Pass index
      );
    }
    return Container();  // Fallback
  }

  static Future<void> sendNameUpdate(String newName, String stem_id) async {
    await http.post(
      Uri.parse("http://${dotenv.get("GH_ADDR")}:${dotenv.get("GH_PORT")}/sendnameupdate?stemid=${stem_id}&stemname=${newName}"),
      body: "",
    );
  }

  
  

  
  @override
  State<Stem> createState() => _StemState();
}

class _StemState extends State<Stem> {
  String button_state = "ON"; 
  String temp_val = "?";
  String hum_val = "?";
  String rawVal = "";
  late Timer _sensorTimer;

  @override
  void initState() {
    super.initState();
    print("Stem widget initialized for ${widget.stem_name}");
    // Fetch data immediately on load
    fetchSensorData(widget.stem_id);
    // Set up periodic refresh every 10 seconds
    _sensorTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      print("Timer triggered - fetching data for ${widget.stem_name}");
      fetchSensorData(widget.stem_id);
    });
  }
  @override
  void dispose() {
    _sensorTimer.cancel();
    super.dispose();
  }

  Future<void> fetchSensorData(String stem_id) async {
    try {
      String url = "http://${dotenv.get("GH_ADDR")}:${dotenv.get("GH_PORT")}/getstemval?stemid=$stem_id";
      print("Constructed URL: $url");
      print("GH_ADDR: ${dotenv.get("GH_ADDR")}, GH_PORT: ${dotenv.get("GH_PORT")}");
      final response = await http.get(Uri.parse(url));
      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        rawVal = data['Stem_val'];
        print("Raw Stem_val: $rawVal");

        setState(() {
          if(rawVal.contains("C")) {
            List<String> parts = rawVal.split('C');
            temp_val = parts[0] + "°C";
            hum_val = parts.length > 2 ? parts[2] + "%" : "?";
            print("Parsed - Temp: $temp_val, Humidity: $hum_val");
          } else {
            temp_val = rawVal;
            hum_val = "-";
            print("No 'C' found - Raw value: $rawVal");
          }
        });
      } else {
        print("API call failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching sensor data: $e");
    }
  } 

  @override
  Widget build(BuildContext context) {
    if (widget.stem_function == "thermohum") {
      return Container(
        width: 130,
        height: 150,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 222, 222, 172),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Icon(
                    Icons.thermostat,
                    size: 30,
                    color: Colors.black,
                  ),
                  Text(
                    widget.stem_name,  
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    temp_val,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    hum_val,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (widget.stem_function == "light") {
      // Build light container (stateful)
      return Container(
        width: 130,
        height: 150,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 222, 222, 172),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 30,
                  ),
                  Text(
                    widget.snapshot!.data![widget.index!].stem_name,  // Use passed snapshot/index
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      print("tapped on/off button of ${widget.snapshot!.data![widget.index!].stem_name}");
                      setState(() {
                        button_state = button_state == "ON" ? "OFF" : "ON";
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 222, 222, 172),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          button_state,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container();  // Fallback
  }

  
}

