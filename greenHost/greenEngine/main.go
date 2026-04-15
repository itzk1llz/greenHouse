package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

const TAG string = "greenEngine >> "

func kickstart() { // This function checks whether everything is in order or not.
	Info(TAG, "Kickstarting...")
	checkDB()                 // db.go
	serial_test()             // serialcon.go
	Debug(TAG, GenerateSID()) // stemidgen.go
	Success(TAG, "Kickstarted!")
}
func main() {

	r := gin.Default()
	kickstart()

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

	r.GET("/stempair", func(c *gin.Context) {

		var stem Stem
		stem.Stem_id = GenerateSID()
		for doesStemExist(stem) == true {
			Warn(TAG, "There is another stem with that ID! Trying again...")
			time.Sleep(2 * time.Second)
		}
		dbgstr := fmt.Sprintf("Generated stem_id %s", stem.Stem_id)
		Info(TAG, dbgstr)
		c.String(http.StatusOK, "Magic's going to happen soon.")
	})

	r.Run()
}
