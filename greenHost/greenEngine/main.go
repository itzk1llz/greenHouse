package main

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

const TAG string = "greenEngine >> "

func kickstart() { // This function checks whether everything is in order or not.
	Info(TAG, "Kickstarting...")
	load_env()                // mqttconn.go
	checkDB()                 // db.go
	serial_test()             // serialcon.go
	Debug(TAG, GenerateSID()) // stemidgen.go
	mqtt_connect()            // mqttcon.go
	Success(TAG, "Kickstarted!")
}
func main() {

	r := gin.Default()
	kickstart() // initialising the server

	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusForbidden, "You shall not pass!")
	})

	r.POST("/localizestem", func(c *gin.Context) {
		var localStem Stem
		localStem.Stem_name = c.Query("stemname")
		localStem.Stem_function = c.Query("stemfunction")
		localStem.Stem_id = c.Query("stemid")

		fmt.Printf("Got %s %s %s\n", localStem.Stem_name, localStem.Stem_function, localStem.Stem_id)
		if validateStem(localStem) == 0 {
			c.String(http.StatusNoContent, "")
		} else {
			c.String(http.StatusOK, "")
			addStem(localStem)
		}
	})

	r.GET("/getstemlist", func(c *gin.Context) {
		jsonData := returnStemList()
		c.Data(http.StatusOK, "application/json", jsonData)
	})

	r.POST("/removestem", func(c *gin.Context) {
		stemID := c.Query("stemid")
		if stemID != "" {
			removeStem(stemID)
		}
		c.String(http.StatusOK, "")
	})

	r.GET("/getportlist", func(c *gin.Context) {
		c.Data(http.StatusOK, "application/json", get_serial_ports())
	})

	r.POST("/selectport", func(c *gin.Context) {
		var newSelPort selectedPortReuqestParams

		if err := c.BindJSON(&newSelPort); err != nil {
			Error(TAG, "Could not bind to json")
			c.String(http.StatusBadRequest, "invalid JSON payload")
		}
		fmt.Println(newSelPort)
		Info(TAG, fmt.Sprintf("Got %v", newSelPort))
		send_serial(newSelPort.SelectedPort, newSelPort.StemType, newSelPort.WifiSSID, newSelPort.WifiPass, newSelPort.Mqtt)
		c.String(http.StatusOK, "")
	})

	r.POST("/getstemval", func(c *gin.Context) {
		stem_id := c.Query("stemid")
		var stem Stem
		stem.Stem_id = stem_id
		if doesStemExist(stem) { // it exists
			c.Data(http.StatusOK, "application/json", getStemVal(stem_id))
		}
	})

	r.POST("/sendmqttupdate", func(c *gin.Context) {
		var stem Stem
		stem.Stem_id = c.Query("stemid")
		stem.Stem_function = c.Query("stemfunction")

		if stem.Stem_id == "" || stem.Stem_function == "" {
			Error(TAG, "Query params are null for mqtt update!")
			c.String(http.StatusForbidden, "")
		} else {
			mqtt_send_msg("/greenHostComm", fmt.Sprintf("%s: %s", stem.Stem_id, stem.Stem_function))
			updateStem(stem)
			c.String(http.StatusOK, "")
		}

	})

	r.GET("/needmqttdata", func(c *gin.Context) {
		mqtt_send_msg("/greenHostComm", "sensordata")
		c.String(http.StatusOK, "")
	})

	r.POST("/togglelight", func(c *gin.Context) {
		stem_id := c.Query("stemid")
		mqtt_send_msg("/greenHostComm", stem_id)
	})

	r.POST("/sendnameupdate", func(c *gin.Context) {
		var stem Stem
		stem.Stem_id = c.Query("stemid")
		stem.Stem_name = c.Query("stemname")

		if stem.Stem_id == "" || stem.Stem_name == "" {
			Error(TAG, "Query params are null!")
			c.String(http.StatusForbidden, "")
		} else if len(stem.Stem_name) > 9 {
			c.String(http.StatusSeeOther, "Stem name is too long!")

		} else {
			mqtt_send_msg("/greenHostComm", fmt.Sprintf("%s: %s", stem.Stem_id, stem.Stem_name))
			updateStemName(stem)
			c.String(http.StatusOK, "Updated name")
		}

	})

	r.Run()
}
