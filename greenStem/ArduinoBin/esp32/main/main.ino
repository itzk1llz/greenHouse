#include "Arduino.h"
#include "string.h"
#include "WiFi.h"
#include "ArduinoNvs.h"
#include "PubSubClient.h"
#include "WiFiClient.h"
#include <stdio.h>
#include "DHT.h"

#define DHTTYPE DHT11

bool res;
const String TAG = "gS: "; 

const int sensorPin = 17;
String wifissid;
String wifipass;
String stem_id;
String mqtt_addr;
String stemfunction;
String ok;

DHT dht(sensorPin, DHTTYPE);

WiFiClient wificl;
PubSubClient client(wificl);

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("gS: got message (");
  Serial.print(topic);
  Serial.print(") ");
  for (int i=0;i<length;i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  if(String(topic) == "/greenHostComm") {
    client.publish("/greenHouseComm", "Pong");
  }
}

byte mqtt_ip[4]; 
long lastMsg = 0;
char mqtt_msg[50];
int value = 0;


void parseIP(String ipStr) {
  
  int parts[4];
  if (sscanf(ipStr.c_str(), "%d.%d.%d.%d", &parts[0], &parts[1], &parts[2], &parts[3]) == 4) {
    for (int i = 0; i < 4; i++) {
      mqtt_ip[i] = (byte)parts[i];
    }
  } 
}

void kickstart() {
  Serial.begin(115200);
  NVS.begin();
  wifissid = NVS.getString("wifissid");
  wifipass = NVS.getString("wifipass");
  stem_id = NVS.getString("stem_id");
  mqtt_addr = NVS.getString("mqtt_addr");
  stemfunction = NVS.getString("stemfunction");
  ok = NVS.getString("ok");
  Serial.println(NVS.getString("wifissid"));
          Serial.println(wifipass);
          Serial.println(stem_id);
          Serial.println(mqtt_addr);
          Serial.println(stemfunction);
  if(wifissid == "" || wifipass == "" || stem_id == "" || mqtt_addr == "" || stemfunction == "") {

    Serial.printf("%sConnect me to a greenHost via a USB cable and use your app to add me to your greenHouse!\n", TAG);
    
  } else {
    parseIP(mqtt_addr);
    Serial.printf("%sTrying to connect to %s\n", TAG, wifissid);
    WiFi.mode(WIFI_STA);
    WiFi.begin(wifissid, wifipass);
    while(WiFi.status() != WL_CONNECTED) {
      Serial.println("Connecting...");
      delay(200);
    }
    Serial.println("Connected!");
    client.setServer(mqtt_ip, 1883);
    client.setCallback(callback);

    if(stemfunction == "thermohum") {
      dht.begin();
    }
    
  }
}

void reconnect() {
  while(!client.connected()) {
    Serial.println("Trying to connect to MQTT broker...");
    if(client.connect(stem_id.c_str())) {
      Serial.println("Connected to the MQTT broker!");
      client.subscribe("/greenHostComm");
      client.subscribe("/greenHouseComm");
    }
    delay(2000);
  }
}

void reset_nvs() {
  NVS.setString("wifissid", "");
          wifissid = NVS.getString("wifissid");
          NVS.setString("wifipass", "");
          wifipass = NVS.getString("wifipass");
          NVS.setString("stem_id", "");
          stem_id = NVS.getString("stem_id");
          NVS.setString("mqtt_addr", "");
          mqtt_addr = NVS.getString("mqtt_addr");
          NVS.setString("ok", "NO");
          ok = NVS.getString("ok");
          NVS.setString("stemfunction", "");
          stemfunction = NVS.getString("stemfunction");
          WiFi.disconnect();
          ESP.restart();
}

uint8_t cnt =0;
void setup() {
  kickstart(); // just as greenHost
  Serial.printf("%d %d %d %d\n", mqtt_ip[0], mqtt_ip[1], mqtt_ip[2], mqtt_ip[3]);
  pinMode(sensorPin, OUTPUT);
}

void loop() {
  
    //String msg = ""; // initial message string which will be incremented
    while(Serial.available()) {
      String msg = Serial.readStringUntil('\n');
        msg.trim();
        Serial.println(msg);
      if(wifissid.length() == 0 || wifipass.length() == 0 || stem_id.length() == 0 || mqtt_addr.length() == 0) {
        
        if(msg[0] == 'f') {
          Serial.println("Got stem function!");
          NVS.setString("stemfunction", msg.substring(1));
          stemfunction = NVS.getString("stemfunction");
        }
        
        if(msg[0] == 'w') {
          Serial.println("Got wifi ssid!");
          NVS.setString("wifissid", msg.substring(1));
          wifissid = NVS.getString("wifissid");
        }
        if(msg[0] == 'p') {
          Serial.println("Got pass");
          NVS.setString("wifipass", msg.substring(1));
          wifipass = NVS.getString("wifipass");
        }
        if(msg[0] == 'i') {
          Serial.println("Got ID");
          NVS.setString("stem_id", msg.substring(1));
          stem_id = NVS.getString("stem_id");
        }
        if(msg[0] == 'm') {
          Serial.println("Got mqtt");
          NVS.setString("mqtt_addr", msg.substring(1));
          mqtt_addr = NVS.getString("mqtt_addr");
        }
        if(msg[0] == 'g') {
          Serial.println(NVS.getString("wifissid"));
          Serial.println(wifipass);
          Serial.println(stem_id);
          Serial.println(mqtt_addr);
          Serial.println(stemfunction);

        }
        if(msg[0] == 'r') {
          reset_nvs();
        }
        

        msg = "";
        
        } 
        if(wifissid.length() != 0 && wifipass.length() !=0 && stem_id.length() != 0 && mqtt_addr.length() != 0 && stemfunction.length() != 0 && ok == "NO") {
          Serial.println("Got everything! Will restart.");
          NVS.setString("ok", "YES");
          ok = NVS.getString("ok");
          delay(500);
          ESP.restart();
        } 
        else {
          if(msg[0] == 'r') {
            reset_nvs();
          }

          
        }     
  
  delay(200);
}
  if(!client.connected()) {
            reconnect();
          }
          client.loop();

          long now = millis();
          if(now - lastMsg > 5000) {
            lastMsg = now;
            if(stemfunction == "thermohum") {
              float h = dht.readHumidity();
              float t = dht.readTemperature();
              if(isnan(h) || isnan(t)) {
                Serial.println("Could not output hum/temp");
              } else {
                snprintf(mqtt_msg, sizeof(mqtt_msg), "%s:%0.1fC%d", stem_id.c_str(), t, (int) h);
              }
              
            }
            
            client.publish("/greenHouseComm", mqtt_msg);
          }
}
