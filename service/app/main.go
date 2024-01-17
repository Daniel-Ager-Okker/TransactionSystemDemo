package main

import (
	"TransactionSystem/backend/database"
	"TransactionSystem/backend/handle"
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	// 0.Create router entity
	var router = gin.Default()

	// 1.Pull frontend
	// router.LoadHTMLGlob("/TransactionSystemApp/frontend/*")
	router.LoadHTMLGlob("/TransactionSystemApp/frontend/*")
	router.GET("/index", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.tmpl", gin.H{
			"title": "Main website",
		})
	})

	// 2.Open connection with database
	pDataBse, err := database.ConnectToDataBase()
	if err != nil {
		panic(err)
	}
	defer pDataBse.Close()

	// 3.Connect handles with controller package functions
	router.GET("/balance", func(ginContext *gin.Context) {
		handle.HandleBalance(ginContext, pDataBse)
	})

	router.POST("/invoice", func(ginContext *gin.Context) {
		handle.HandleInvoice(ginContext, pDataBse)
	})

	router.POST("/withdraw", func(ginContext *gin.Context) {
		handle.HandleWithdraw(ginContext, pDataBse)
	})

	// 4.Run router
	router.Run(":8054")
}
