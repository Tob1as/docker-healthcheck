package main

import (
    "crypto/tls"
    "flag"
    "fmt"
    "log"
    "net/http"
    "os"
    "strconv"
    "time"
)

func main() {

    help := flag.Bool("help", false, "Show help message")
    flag.Parse()

    if *help {
        fmt.Println("Usage: healthcheck [OPTIONS]")
        fmt.Println()
        fmt.Println("Simple Healthcheck for Container Images with Webserver written in GO! <https://github.com/Tob1as/docker-healthcheck>")
        fmt.Println()
        fmt.Println("Environment Variables:")
        fmt.Println("  HEALTHCHECK_URL              Full URL of the endpoint (overrides other options for url).")
        fmt.Println("  HEALTHCHECK_HOST             Hostname of the server (default: localhost).")
        fmt.Println("  HEALTHCHECK_PROTOCOL         Protocol to use (http or https, default: http).")
        fmt.Println("  HEALTHCHECK_PORT             Port of the server (default: 8080).")
        fmt.Println("  HEALTHCHECK_PATH             Path on the server (default: /).")
        fmt.Println("  HEALTHCHECK_SKIP_TLS_VERIFY  Set to true to disable TLS certificate verification (default: false).")
        fmt.Println()
        fmt.Println("Example Usage:")
        fmt.Println("  healthcheck")
        fmt.Println("  healthcheck --help")
        fmt.Println("  HEALTHCHECK_URL=http://localhost:8080/ healthcheck")
        os.Exit(0)
    }

    fullURL := os.Getenv("HEALTHCHECK_URL")
    if fullURL == "" {
        protocol := os.Getenv("HEALTHCHECK_PROTOCOL")
        if protocol == "" {
            protocol = "http"   // set to http or https
        }
        host := os.Getenv("HEALTHCHECK_HOST")
        if host == "" {
            host = "localhost"  // or container name
        }
        port := os.Getenv("HEALTHCHECK_PORT")
        if port == "" {
            port = "8080"       // for http set to 80 , for https set to 443
        }
        path := os.Getenv("HEALTHCHECK_PATH")
        if path == "" {
            path = "/"          // or /healthz
        }
        fullURL = protocol + "://" + host + ":" + port + path
    }

    skipTLSVerify := false
    if val := os.Getenv("HEALTHCHECK_SKIP_TLS_VERIFY"); val != "" {
        parsed, err := strconv.ParseBool(val)
        if err == nil {
            skipTLSVerify = parsed
        } else {
            log.Printf("[healthcheck] WARN: Invalid value for SKIP_TLS_VERIFY: %s", val)
        }
    }

    client := &http.Client{
        Timeout: 3 * time.Second,
        Transport: &http.Transport{
            TLSClientConfig: &tls.Config{
                InsecureSkipVerify: skipTLSVerify,
            },
        },
    }

    req, err := http.NewRequest("GET", fullURL, nil)
    if err != nil {
        log.Fatalf("[healthcheck] ERROR: Could not create request: %v", err)
    }
    req.Header.Set("User-Agent", "healthcheck")

    resp, err := client.Do(req)
    if err != nil {
        log.Fatalf("[healthcheck] ERROR: Healthcheck failed: %v", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        log.Fatalf("[healthcheck] ERROR: Unexpected status code %d", resp.StatusCode)
    }

    log.Println("[healthcheck] INFO: Healthcheck passed")
}