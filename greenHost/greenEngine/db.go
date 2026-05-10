package main

import (
	"database/sql"
	"encoding/json"
	"fmt"

	_ "github.com/mattn/go-sqlite3"
)

const dbpath string = "../greenDB/greenDB.db"

func checkDB() { // Function checks for DB existence
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "DB exists!")
	}
	defer db.Close()
}

func addStem(stem Stem) { // stem.go
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "Opened DB!")
	}

	stem_name, stem_function, stem_id := stem.Stem_name, stem.Stem_function, stem.Stem_id

	_, err = db.Exec("INSERT INTO stem_list (stem_name, stem_function, stem_id) VALUES (?, ?, ?)", stem_name, stem_function, stem_id)

	if err != nil {
		Error(TAG, "Could not add stem!")
	} else {
		stemStatus := fmt.Sprintf("Added stem with id %s", stem_id)
		Success(TAG, stemStatus)
	}
	_, err = db.Exec("INSERT INTO stem_values (stem_id, stem_val) VALUES (?, ?)", stem_id, "?")

	if err != nil {
		Error(TAG, "Could not add stem to secondary DB!")
	} else {
		stemStatus := fmt.Sprintf("Added stem with id %s to secondary DB!", stem_id)
		Success(TAG, stemStatus)
	}
	db.Close()
}

func doesStemExist(stem Stem) bool { // returns whether there is a stem or not already in the DB
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "Opened DB!")
	}

	var count int
	err = db.QueryRow("SELECT COUNT(*) from stem_list WHERE stem_id = ?", stem.Stem_id).Scan(&count)

	if err != nil {
		return true
	}
	db.Close()
	return count > 0

}

func returnStemList() []byte {
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	}

	rows, err := db.Query("SELECT stem_name, stem_function, stem_id FROM stem_list;")
	if err != nil {
		Error(TAG, "Could not select rows!")
	}

	stems := []Stem{}

	for rows.Next() {
		var stem Stem
		if err := rows.Scan(&stem.Stem_name, &stem.Stem_function, &stem.Stem_id); err != nil {
			Error(TAG, err.Error())
		}
		stems = append(stems, stem)
	}
	if err = rows.Err(); err != nil {
		Error(TAG, err.Error())
	}
	if len(stems) > 0 {

		finalStemJson, err := json.Marshal(stems)
		if err != nil {
			Error(TAG, err.Error())
		} else {
			logthing := fmt.Sprintf("Returned %d stems.", len(stems))
			Success(TAG, logthing)
		}
		return finalStemJson
	} else {
		Info(TAG, "Nothing found!")
	}
	rows.Close()
	db.Close()
	return nil

}

func updateStem(stem Stem) { // this already has the new values
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "Opened DB!")
	}

	stem_function, stem_id := stem.Stem_function, stem.Stem_id

	sql := `UPDATE stem_list SET stem_function=? WHERE stem_id=?;`

	_, err = db.Exec(sql, stem_function, stem_id)

	if err != nil {
		Error(TAG, "Error while updaing DB!")
		Info(TAG, stem_id)
		Info(TAG, stem_function)
		fmt.Println(err)
	} else {
		Success(TAG, fmt.Sprintf("Updated DB for stem with ID %s - %s", stem_id, stem_function))
	}
	db.Close()

}
func updateStemName(stem Stem) { // this already has the new values
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "Opened DB!")
	}

	stem_name, stem_id := stem.Stem_name, stem.Stem_id

	sql := `UPDATE stem_list SET stem_name=? WHERE stem_id=?;`

	_, err = db.Exec(sql, stem_name, stem_id)

	if err != nil {
		Error(TAG, "Error while updaing DB!")
		fmt.Printf("%s - %s\n", TAG, err)
	} else {
		Success(TAG, fmt.Sprintf("Updated DB for stem with ID %s - name: %s", stem_id, stem_name))
	}

}

func updateStemVal(stem_id string, stem_val string) { // this already has the new values
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "Opened DB!")
	}

	defer db.Close()

	sql := `UPDATE stem_values SET stem_val=? WHERE stem_id=?;`

	_, err = db.Exec(sql, stem_val, stem_id)

	if err != nil {
		Error(TAG, "Error while updaing DB!")
		fmt.Printf("%s - %s\n", TAG, err)
	} else {
		Success(TAG, fmt.Sprintf("Updated DB for stem with ID %s - value: %s", stem_id, stem_val))
	}

}
func getStemVal(stem_id string) []byte {
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "Opened DB!")
	}

	var val StemVal
	err = db.QueryRow("SELECT stem_val from stem_values WHERE stem_id = ?", stem_id).Scan(&val.Stem_val)

	if err != nil {
		Error(TAG, "Error while getting the stem value.")
	}
	finalVal, err := json.Marshal(val)

	db.Close()
	return finalVal

}

func removeStem(stemid string) {
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "Opened DB!")
	}

	sql := `DELETE FROM stem_list WHERE stem_id=?`
	_, err = db.Exec(sql, stemid)
	if err != nil {
		Error(TAG, "Error while updaing DB!")
		fmt.Printf("%s - %s\n", TAG, err)
	} else {
		Success(TAG, fmt.Sprintf("Removed stem with ID %s", stemid))
	}
	sql = `DELETE FROM stem_values WHERE stem_id=?`
	_, err = db.Exec(sql, stemid)
	if err != nil {
		Error(TAG, "Error while updaing DB!")
		fmt.Printf("%s - %s\n", TAG, err)
	} else {
		Success(TAG, fmt.Sprintf("Removed stem with ID %s from secondary DB", stemid))
	}
	db.Close()
}
