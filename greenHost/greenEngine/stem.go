package main

type Stem struct {
	Stem_name     string
	Stem_function string
	Stem_id       string
}

func validateStem(stem Stem) uint8 {
	stemTypes := []string{"thermohum", "light"} // available stem types for now

	if stem.Stem_name == "" || stem.Stem_function == "" || stem.Stem_id == "" {
		return 0
	}
	if doesStemExist(stem) == true {
		Error(TAG, "Stem with that ID exists!")
		return 0
	}
	ok := false
	for _, v := range stemTypes {
		if stem.Stem_function == v {
			ok = true
		}
	}
	if ok == false {
		return 0
	} else {
		return 1
	}

}
