# Node vs Go Performance Comparison

It is a case-by-case Node.js vs Go performance comparison, demonstraiting some pitfalls of the signle-threaded nature of Node.js that, when ignored, start being a problem under certain load or conditions. It does not necesserily mean that Go is "better" than Node.js, as usual -- it depends. Node is easier to pick up, faster to roll out and simpler to use, Go is more performant but its performance comes with a price of dealing with some low-level details that make a bigger room for human error (like using shared resources from multiple goroutines or necessity to release some of system resources manually - like file descriptors). So, time for experiments and some numbers:

[_As a side note: on some of the graphs you can notice that the CPU usage is said to be in percents but the actual values go way above 1k. Well, blame psutil for OSX and the way it collects CPU usage for a selected process. Just treat it as some kind of index, higher the value -- higher the usage._]

## Max RPS and how number of simultaneous connections affect performance

Let's see how much we can squeeze from Node.js and Go HTTP servers on my local machine (OSX, 3.1 GHz Intel Core i5, 8 GB 2133 MHz RAM) by calling a route that does nothing more than returning current timestamp. 

Go server can handle at least 3 times more RPS than the Node one with much better and stable latency. I said "at least" becasue the benchmark and the server were launched on the same machine and they were compeating for resources (like CPU), which didn't allow the Go server run at full scale. Take a look at the table below:

| Server | Number Of Connectinos | RPS | Mean Latency (ms) | Std. Dev |
| :---: | :---: | :---: | :---: | :---: |
| Node | 10 | 12.9K | 37.4 | 95 |
| Go | 10 | 39.5k | 164 | 108 | 
| Node | 100 | 12.9K | 7 | 10 |
| Go | 100 | 39K | 3 | 2 |
| Node | 500 | 12.5k | 67.5 | 135 |
| Go | 500 | 38.6k | 6.2 | 3.8 |
| Node | 1000 | 12.1k | 437 | 103.5 |
| Go | 1000 | 38k | 13.8 | 7.7 | 

Number of connections indicates how many sockets are used simultaneously to pass the the traffic to the server. As you can see from the table, it can significantly affect server latency but not the RPS (well, not too much). Why is that the case? Let's say your server has a fixed pool of connections to some database it keeps open (which is replaced by the benchmark app in our case):

* Increasing number of connections from 10 to 100 made Node latency 5 times better and Go latency 82 times better. Thing is, every connection/socket has a queue maintained by the OS kernel, where it stores the requests before passing them to the underlying network device. If the device is busy, more and more requests get queued and since the queues size is limited, at some point queues get full and become a bottleneck. Adding more connections/sockets just gives you more queues where requests can happily wait until the network device can handle them.
* Increasing number of connections from 100 to 500 and then to 1000 made latency of both Node.js and Go servers worse, although for Node it was much worse. Node: 7ms -> 67.5ms -> 437ms. Go: 2ms -> 6.2ms -> 13.8ms. What happened and why Node was affected more than Go? Every new connection, say in your database connections pool, becomes a new source of events for your server. At some point just switching between different sources-of-events/connections becomes expensive and Node was affected by that much more than Go just becasue it could not utilise parallelism and handle different connections simultaneously.

[test](/imgs/stats_node_1.png)
