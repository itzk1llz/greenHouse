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
	defer db.Close()
	stem_name, stem_function, stem_id := stem.Stem_name, stem.Stem_function, stem.Stem_id

	_, err = db.Exec("INSERT INTO stem_list (stem_name, stem_function, stem_id) VALUES (?, ?, ?)", stem_name, stem_function, stem_id)

	if err != nil {
		Error(TAG, "Could not add stem!")
	} else {
		stemStatus := fmt.Sprintf("Added stem with id %s", stem_id)
		Success(TAG, stemStatus)
	}
}

func doesStemExist(stem Stem) bool { // returns whether there is a stem or not already in the DB
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "Opened DB!")
	}
	defer db.Close()

	var count int
	err = db.QueryRow("SELECT COUNT(*) from stem_list WHERE stem_id = ?", stem.Stem_id).Scan(&count)

	if err != nil {
		return true
	}

	return count > 0

}

func returnStemList() []byte {
	db, err := sql.Open("sqlite3", dbpath)

	if err != nil {
		Fatal(TAG, "Could not open DB!")
	} else {
		Success(TAG, "DB exists!")
	}
	defer db.Close()

	rows, err := db.Query("SELECT stem_name, stem_function, stem_id FROM stem_list;")
	if err != nil {
		Error(TAG, "Could not select rows!")
	}
	defer rows.Close()

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
	return nil

}
