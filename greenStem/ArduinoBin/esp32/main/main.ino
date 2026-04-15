#include "Arduino.h"
#include "WiFi.h"
#include "ArduinoNvs.h"

bool res;
const String TAG = "gS: "; 

typedef struct stem {
  char stem_id[37];
  char stem_name[40];
  char stem_function[10];
};

typedef struct stemcfg {
  char ssid[32];
  char pass[32];
};

void kickstart() {
  Serial.begin(115200);
  NVS.begin();
  if(NVS.getString("wifissid") == "" || NVS.getString("wifipass") == "" || NVS.getString("stem_id") == "") {

    Serial.printf("%sConnect me to a greenHost via a USB cable and use your app to add me to your greenHouse!\n", TAG);
    
  } else {
    Serial.printf("%sTrying to connect to %s\n", TAG, NVS.getString("wifissid"));
  }
}

void setup() {
  kickstart(); // just as greenHost
}

void loop() {
  if(NVS.getString("wifissid") == "" || NVS.getString("wifipass") == "" || NVS.getString("stem_id") == "") {
    String msg = ""; // initial message string which will be incremented
    while(Serial.available()) {
        char incChar = Serial.read();
        if(incChar == '\n' || incChar == '\0') { // it means the string ended
          Serial.printf("%sGot %s\n",TAG, msg);
          msg = "";
        } else {
          msg += incChar;
        }
      }
      if(NVS.getString("wifissid") == "" || NVS.getString("wifipass") == "" || NVS.getString("stem_id") == "") {
        Serial.printf("%sSomething went wrong - retrying...\n", TAG);
      } else {
        Serial.printf("%sSuccess! greenStem will restart soon to proceed with setup!\n", TAG);
      }
  }
  delay(5000);
}
