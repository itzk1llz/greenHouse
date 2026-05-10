import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Port_item  {
    String port_name; 

    Port_item({
        required this.port_name,
    });

    static Future<List<Port_item>> fetchPorts() async {
        final response = await http.get(Uri.parse("http://${dotenv.get("GH_ADDR")}:${dotenv.get("GH_PORT")}/getportlist"));

        var responseData = json.decode(response.body);

        List<Port_item> ports = [];

        for(var aport in responseData) {
            Port_item port = Port_item (
                port_name: aport["Port_name"],
            );
            ports.add(port);
        }
        return ports;
    }
    
    static Future<void> sendSelection(String port_name, String stem_type, String wifissid, String wifipass) async {
        try {
            final response = await http.post(
                Uri.parse("http://${dotenv.get("GH_ADDR")}:${dotenv.get("GH_PORT")}/selectport"),
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'port': port_name,
                  'stemType': stem_type,
                  'wifissid': wifissid,
                  'wifipass': wifipass,
                  'mqtt': dotenv.get("MQTT_ADDR")
                  }),
            );
            
            if (response.statusCode == 200) {
                print("Port selected successfully");
            } else {
                print("Failed to select port: ${response.statusCode}");
            }
        } catch (e) {
            print("Error sending port selection: $e");
        }
    }
}


    
    

