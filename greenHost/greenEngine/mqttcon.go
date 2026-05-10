package main

import (
	"fmt"
	"os"
	"strings"

	mqtt "github.com/eclipse/paho.mqtt.golang"
	"github.com/joho/godotenv"
)

type BackConfig struct {
	BrokerHost string
	BrokerPort string
}

var Client mqtt.Client
var Token mqtt.Token
var Cfg BackConfig

func load_env() {
	err := godotenv.Load("./config.env")
	if err != nil {
		Fatal(TAG, "Could not load config.env file!")
	}
	Cfg.BrokerHost = os.Getenv("MQTT_ADDRESS")
	Cfg.BrokerPort = os.Getenv("MQTT_PORT")
}

func mqtt_connect() {
	Info(TAG, "Checking MQTT")
	var broker = Cfg.BrokerHost
	var port = Cfg.BrokerPort

	opts := mqtt.NewClientOptions()
	opts.AddBroker(fmt.Sprintf("mqtt://%s:%s", broker, port))

	opts.SetClientID("greenHost")
	opts.SetUsername("greenHost")
	opts.OnConnect = func(c mqtt.Client) {
		Success(TAG, "Connected to the MQTT server!")
		go mqtt_listen("#")
	}
	opts.OnConnectionLost = func(c mqtt.Client, _ error) {
		Warn(TAG, "Lost connection to the broker!")
	}
	Client = mqtt.NewClient(opts)

	if Token = Client.Connect(); Token.Wait() && Token.Error() != nil {
		Fatal(TAG, "Does the broker exist? Please check.")
	}
}

func mqtt_listen(topic string) {
	Info(TAG, fmt.Sprintf("Will be listening over %s", topic))

	Client.Subscribe(topic, 0, func(client mqtt.Client, msg mqtt.Message) {
		MQTTMsg(TAG, fmt.Sprintf("%s | %s", string(msg.Payload()), msg.Topic()))
		if msg.Topic() == "/test" {
			Info(TAG, "This was received on /test!")
		}
		// this is dedicated for the server to communicate with the greenStems
		if msg.Topic() == "/greenHostComm" {
		}
		// this is dedicated for the greenStems to communicate with the server
		if msg.Topic() == "/greenHouseComm" {
			Info(TAG, "Got an update from a stem!")
			stem_data := strings.Split(string(msg.Payload()), ":")
			Info(TAG, fmt.Sprintf("%s %s", stem_data[0], strings.ReplaceAll(stem_data[1], " ", "")))

			stem_id := stem_data[0]
			stem_vals := stem_data[1]
			MQTTMsg(TAG, stem_data[1])
			var stem Stem
			stem.Stem_id = stem_id
			if doesStemExist(stem) == true {
				updateStemVal(stem_id, stem_vals)
			}

		}

	})

}

func mqtt_send_msg(topic string, msg string) {
	t := Client.Publish(topic, 0, false, msg)

	go func() {
		_ = t.Wait()
		if t.Error() != nil {
			Error(TAG, "Error while sending message!")
		}
	}()
}
