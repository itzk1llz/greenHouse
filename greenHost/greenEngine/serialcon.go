package main

import (
	"encoding/json"
	"fmt"

	"go.bug.st/serial"
)

type greenPort struct {
	Port_name string
	Stem_type string
	WifiSSID  string
	WifiPass  string
}

type selectedPortReuqestParams struct {
	SelectedPort string `json:"port"`
	StemType     string `json:"stemType"`
	WifiSSID     string `json:"wifissid"`
	WifiPass     string `json:"wifipass"`
	Mqtt         string `json:"mqtt"`
}

func serial_test() {

	ports, err := serial.GetPortsList()

	if err != nil {
		fmt.Printf("%s\n", err)
		Fatal(TAG, "Something went wrong with the ports!")
	}
	if len(ports) == 0 {
		Warn(TAG, "There are no serial ports!")
	}
	for _, port := range ports {
		fmt.Printf("%sGot port: %v\n", TAG, port)
	}

}

func get_serial_ports() []byte {

	port_list := []greenPort{}

	ports, err := serial.GetPortsList()

	if err != nil {
		Fatal(TAG, "There was an error! Exiting.")
	}
	if len(ports) == 0 {
		Warn(TAG, "There are no ports available.")
	}
	var aPort greenPort
	for _, port := range ports {
		aPort.Port_name = port
		port_list = append(port_list, aPort)
	}
	finalPortListJson, err := json.Marshal(port_list)
	if err != nil {
		Error(TAG, "Couldn't marshal port list!")
	} else {
		Success(TAG, "Sent the port list.")
	}
	return finalPortListJson
}

func send_serial(portName string, stemType string, wifissid string, wifipass string, mqttaddr string) {
	mode := &serial.Mode{
		BaudRate: 115200,
	}

	port, err := serial.Open(portName, mode)

	if err != nil {
		Error(TAG, "Something went wrong while opening the port!")
	}

	final_id := GenerateSID()
	nfinal_id := fmt.Sprintf("i%s\n", final_id)
	nstemType := fmt.Sprintf("f%s\n", stemType)
	nwifissid := fmt.Sprintf("w%s\n", wifissid)
	nwifipass := fmt.Sprintf("p%s\n", wifipass)
	nmqtt := fmt.Sprintf("m%s\n", mqttaddr)
	_, err = port.Write([]byte(nwifissid))
	_, err = port.Write([]byte(nwifipass))
	_, err = port.Write([]byte(nstemType))
	_, err = port.Write([]byte(nfinal_id))
	_, err = port.Write([]byte(nmqtt))
	if err != nil {
		Error(TAG, "Error while sending")
		return
	}
	port.Close()
	Info(TAG, "Sent information. Will add the stem to the DB.")
	var stem Stem
	stem.Stem_id = final_id
	stem.Stem_function = stemType
	stem.Stem_name = "stem" + "^"
	addStem(stem)
}

func close_port() {

}
