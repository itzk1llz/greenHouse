package main

import (
	"fmt"
	"os"
)

var Reset string = "\033[0m"
var Bold string = "\033[1m"
var Underline string = "\033[4m"
var Italic string = "\033[3m"

var Red string = "\033[31m"
var Green string = "\033[32m"
var Yellow string = "\033[33m"
var Blue string = "\033[34m"
var Purple string = "\033[35m"
var Cyan string = "\033[36m"

func Info(tag string, msg string) {
	fmt.Printf("%s%s%s%s\n", Blue, tag, msg, Reset)
}

func Error(tag string, msg string) {
	fmt.Printf("%s%s%s%s\n", Red, tag, msg, Reset)
}

func Fatal(tag string, msg string) {
	fmt.Printf("%s%s%s%s\n", Red, tag, msg, Reset)
	os.Exit(2)
}

func Warn(tag string, msg string) {
	fmt.Printf("%s%s%s%s\n", Yellow, tag, msg, Reset)
}

func Success(tag string, msg string) {
	fmt.Printf("%s%s%s%s\n", Green, tag, msg, Reset)
}

func MQTTMsg(tag string, msg string) {
	fmt.Printf("%s%s%s%s\n", Cyan, tag, msg, Reset)
}

func Debug(tag string, msg string) {
	fmt.Printf("%s%s%s%s\n", Purple, tag, msg, Reset)
}
