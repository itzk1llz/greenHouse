package main

import (
	"fmt"
	"math/rand"
)

func GenerateSID() string {

	Info(TAG, "Generating a stem_id!")

	chars := []rune("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")

	finalID := ""
	for i := 0; i < 4; i++ {
		randomIndex := rand.Intn(len(chars))
		finalID = fmt.Sprintf("%s%s", finalID, string(chars[randomIndex]))
	}
	finalID = fmt.Sprintf("%s%s", finalID, "-")
	for i := 0; i < 4; i++ {
		randomIndex := rand.Intn(len(chars))

		finalID = fmt.Sprintf("%s%s", finalID, string(chars[randomIndex]))
	}
	if len(finalID) < 9 {
		Fatal(TAG, "The ID that was generated is faulty! Halting. Please reinstall greenHost.")
	}

	return finalID
}
