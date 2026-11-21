// Proves, on lg-static, what a Go service needs from its base image: a static binary starts, the CA
// bundle is found and parses, the time zone database is present, and the nonroot user exists.
package main

import (
	"crypto/x509"
	"fmt"
	"os"
	"os/user"
	"time"
)

func main() {
	pool, err := x509.SystemCertPool()
	if err != nil || len(pool.Subjects()) == 0 { //nolint:staticcheck // Subjects() is enough to count the bundle
		fmt.Println("FAIL: no system CA certificates")
		os.Exit(1)
	}
	if _, err := time.LoadLocation("Europe/Rome"); err != nil {
		fmt.Println("FAIL: no tzdata:", err)
		os.Exit(1)
	}
	u, err := user.Current()
	if err != nil || u.Uid != "65532" {
		fmt.Println("FAIL: not running as nonroot (65532):", u, err)
		os.Exit(1)
	}
	fmt.Println("OK go-hello")
}
