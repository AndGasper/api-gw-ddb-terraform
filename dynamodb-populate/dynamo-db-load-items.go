package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"

	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
)

// if you don't capitalize, then the marshaling doesn't quite work, or doesn't quite "see" the fields?

type Entity struct {
	Id string `json:"id"`
	Details struct {
		FirstName string `json:"firstName"`
		LastName string `json:"lastName"`
	}
}

// func functionName(args) []ReturnType
// Get table items from JSON file
func getEntities() []Entity {
	// Readfile ([]byte, err)
	// so pick off the raw bytes returned as fileData
	fileData, err := ioutil.ReadFile("./sample-data.json")

	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}

	var entities []Entity
	json.Unmarshal(fileData, &entities)
	return entities
}

func main() {
	// create a new session
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		Profile: "load-data-into-dynamodb",
	}))
	
	// Create the dynamodb client
	svc := dynamodb.New(sess, &aws.Config{
		Region: aws.String("us-east-1"),
	})

	entities := getEntities()

	
	tableName := "a-table-name"
	
	for _, entity := range entities {

		av, err := dynamodbattribute.MarshalMap(entity)

		if err != nil {
			fmt.Println("Got error while marhsal mapping:")
			fmt.Println(err.Error())
			os.Exit(1)
		}
		// This  creates the item
		input := &dynamodb.PutItemInput{
			Item: av,
			TableName: aws.String(tableName),
		}
	
		_, err = svc.PutItem(input)
		
		if err != nil {
			fmt.Println("Got error calling PutItem:")
			fmt.Println(err.Error())
			os.Exit(1)
		}
	
		entityId := entity.Id
	
		fmt.Println("Successfully added: " + entityId + " to table: " + tableName)
	}
}
