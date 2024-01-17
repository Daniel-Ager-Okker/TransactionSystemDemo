package database

import (
	"TransactionSystem/backend/model"
	"database/sql"
	"fmt"
	"os"

	_ "github.com/lib/pq"
)

func getOpenConnectionStatement() string {
	var hostName string = os.Getenv("DATABASE_HOST_NAME")
	var user string = os.Getenv("DATABASE_USER")
	var password string = os.Getenv("DATABASE_PASSWORD")
	var port string = os.Getenv("DATABASE_PORT")
	var dbname string = os.Getenv("DATABASE_NAME")
	var sslmode string = os.Getenv("SSL_MODE")

	return fmt.Sprintf(
		"host=%s user=%s password=%s port=%s dbname=%s sslmode=%s",
		hostName, user, password, port, dbname, sslmode)
}

// Function for connect to the database
func ConnectToDataBase() (*sql.DB, error) {
	// 1.First step - try to open database
	pDataBase, err := sql.Open("postgres", getOpenConnectionStatement())
	if err != nil {
		panic(err)
	}
	defer pDataBase.Close()

	// 2.Second step - check if there is connection
	err = pDataBase.Ping()
	if err != nil {
		panic(err)
	}

	return pDataBase, nil
}

// Function for customize max connections count (need to control load)
func SetMaxConnectionsCount(database *sql.DB, count int) {
	database.SetMaxOpenConns(count)
}

// Function for increase user cash value in corresponding currency type
func Invoice(pDataBase *sql.DB, req model.RequestData) model.TransactionStatus {
	// TODO
	return model.Success
}

// Function for decrease user cash value in corresponding currency type
func Withdraw(pDataBase *sql.DB, req model.RequestData) model.TransactionStatus {
	// TODO
	return model.Success
}

// Function for get client balance information
func Balance(pDataBase *sql.DB, req *model.RequestData) (model.TransactionStatus, model.BalanceData) {
	var clientID int
	err := pDataBase.QueryRow("SELECT id FROM system_clients WHERE swallet_number=?", req.WalletID).Scan(&clientID)
	if err != nil {
		return model.Error, model.BalanceData{}
	}
	return model.Error, model.BalanceData{}
}
