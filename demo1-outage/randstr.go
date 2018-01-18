package demo1_outage

import (
	"fmt"
	"math/rand"
	"net/http"
	"time"
	"log"
	"flag"
	"os"
	"os/signal"
	"syscall"
	"github.com/braintree/manners"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/prometheus/client_golang/prometheus"
)

var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

var symb_glob int
var reqPreSec int

var (
	// How often our /hello request durations fall into one of the defined buckets.
	// We can use default buckets or set ones we are interested in.
	duration = prometheus.NewHistogram(prometheus.HistogramOpts{
		Name:    "request_duration",
		Help:    "Histogram of the request duration in seconds.",
		Buckets: []float64{0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2},
	})

	counter = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "total_requests",
			Help: "Total number of requests",
		},
	)

	requestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "randstr_requests_total",
			Help: "Total number of requests",
		},
		[]string{"hostname"},
	)

	hostname string
)

func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func symbIncr() {
	for {
		//symb_glob++
		time.Sleep(100 * time.Millisecond)
	}
}

func reqCounting() {
	for {
		//log.Printf("%v\n", reqPreSec)
		reqPreSec = 0
		time.Sleep(1 * time.Second)
	}
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	defer func(begun time.Time) {
		//time.Sleep(1000 * time.Millisecond)
		duration.Observe(time.Since(begun).Seconds())
		counter.Inc()
		requestsTotal.WithLabelValues(hostname).Inc()
		fmt.Fprintln(w, randSeq(symb_glob))
		reqPreSec++
	}(time.Now())
}

// init registers Prometheus metrics.
func init() {
	prometheus.MustRegister(duration)
	prometheus.MustRegister(counter)
	prometheus.MustRegister(requestsTotal)
}

func main() {
	bind_port := flag.String("port", "8080", "Port to listen")
	bind_addr := flag.String("addr", "0.0.0.0", "Advertise ip address")
	symb_glob  = *flag.Int("symb", 51200, "Number of symbols to be return in response")
	flag.Parse()

	hostname, _ = os.Hostname()

	reqPreSec = 0

	go func() {
		sigchan := make(chan os.Signal, 1)
		signal.Notify(sigchan, syscall.SIGINT, syscall.SIGTERM)
		<-sigchan
		manners.Close()
	}()

	go reqCounting()
	go symbIncr()

	mux := http.NewServeMux()

	mux.HandleFunc("/", indexHandler)
	mux.Handle("/metrics", promhttp.Handler())

	log.Printf("Listening %v on port %v\n", *bind_addr, *bind_port)

	defer func() {
		log.Printf("Service demo-randstr exiting\n")
	}()

	if err := manners.ListenAndServe(fmt.Sprintf("%s:%s",  *bind_addr, *bind_port), mux); err != nil {
		log.Fatal(err)
	}
}