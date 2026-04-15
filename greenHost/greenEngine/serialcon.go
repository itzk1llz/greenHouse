package main

import (
	"fmt"

	"go.bug.st/serial"
)

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
