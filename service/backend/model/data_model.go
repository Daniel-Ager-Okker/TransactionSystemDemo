package model

type CurrencyType string

const (
	USDT CurrencyType = "USDT"
	RUB  CurrencyType = "RUB"
	EUR  CurrencyType = "EUR"
)

type BalanceData struct {
	Currency CurrencyType
	Actual   float64
	Frozen   float64
}

type RequestData struct {
	Currency  CurrencyType
	CashValue float64
	WalletID  uint64
}

type TransactionStatus string

const (
	Error   TransactionStatus = "Error"
	Success TransactionStatus = "Success"
	Created TransactionStatus = "Created"
)
