package database

import (
	"TransactionSystem/backend/database"
	"database/sql"
	"testing"
)

func connectToDB() *sql.DB {
	pDataBase, err := database.ConnectToDataBase()
	if err != nil {
		panic(err)
	}
	return pDataBase
}

func closeConnectionDB(pDataBase *sql.DB) {
	pDataBase.Close()
}

func TestBalance(test *testing.T) {
	pDataBase := connectToDB()

	closeConnectionDB(pDataBase)
}
