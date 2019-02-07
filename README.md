# Node vs Go: when to use what?

This is a case-by-case Node.js vs Go performance comparison, demonstraiting some pitfalls of the signle-threaded nature of Node.js that, when ignored, starts being a problem under certain load and conditions. In no way it means that Go is "better" than Node.js and we shall start using it everywhere and for everything like other cool kids over there. This analysis is an attempt to come up with some rules of thumb for choosing one language over another for your projects/microservices. 

## Node.js and when to use it 

Don't forget that Node can handle a lot of load when used properly while allowing you to move fast, release quickly and prototype features, which is essential when your problem domain is mostly unknown.

1. You expect less than 4-5k RPS
2. Most of what your server does is I/O
3. Your server is small, simple and unifunctional in a sense that it's not designed to be a swiss knife that deals with many different problem domains at once (a monolyth).

An official Node.js documentation states: _Here's a good rule of thumb for keeping your Node server speedy: Node is fast when the work associated with each client at any given time is "small"_. Ok, what does "small" mean? You can think of Node.js as a very performant I/O router. If most of what your server does is I/O and there're no expensive blocking operations surrounding the I/O (like heavy computations or sophisticated data procesding bits), it can be a great choice for your project that handles roughly 4-5k RPS with stable and predictable latency.

## Go and when to use it

Either
1. You expect a lot of load on your server: >5k RPS per instance,
2. Or your server has to include some heavy computations, sophisticated data verification logic, anything that burns CPU cycles and slows Node down,
3. Or you naturally grow out of Node.js and want to improve performance.

Go is definitely much more performant. Unlike Node, it naturally combines parallelism and concurrency incorporated to the concept of goroutines ([green threads](https://en.wikipedia.org/wiki/Green_threads)). As everything in life, performance comes with a price of dealing with some low-level details that make a bigger room for human error: like using shared resources from multiple goroutines or necessity to release some of system resources manually - like file descriptors. Go is harder to use and debug, so if you need to prototype or relase fast, it's not the best option. Use Node.js isntead, you can always switch to Go once performance is a problem.

# Peformance analysis

_As a side note: on some of the graphs you can notice that the CPU usage is said to be in percents but the actual values go way above 1k. Well, blame psutil for OSX and the way it collects CPU usage for a selected process. Just treat it as some kind of index, higher the value -- higher the usage._

## Max RPS and how number of simultaneous connections affect performance

Let's see how much we can squeeze from Node.js and Go HTTP servers on my local machine (OSX, 3.1 GHz Intel Core i5, 8 GB 2133 MHz RAM) by calling a route that does nothing more than returning current timestamp. 

Go server can handle at least 3 times more RPS than the Node one with much better and stable latency. I said "at least" becasue the benchmark and the server were launched on the same machine, so they were compeating for resources (like CPU), which didn't allow the Go server to run at full scale. Take a look at the table below:

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

Number of connections indicates how many sockets are used simultaneously to pass the the traffic to the server. A useful way to think of it as number of, say, DB connections in a pool your server keeps open. As you can see from the table, chaning this number can significantly affect server latency but not the RPS (well, not too much). Why is that the case? 

* Increasing the number of connections from 10 to 100 made Node latency 5 times better and Go latency 82 times better. Thing is, every connection/socket has a queue maintained by the OS kernel, where it stores the requests before passing them to the underlying network device. If the device is busy, more and more requests get queued and since the queues size is limited, at some point the queues get full and become a bottleneck. Adding more connections/sockets just gives your server more queues where it can redistributed reuqests more efficiently.

* Increasing number of connections from 100 to 500 and then to 1000 made latency of both Node.js and Go servers worse, although for Node it was much worse. Node: 7ms -> 67.5ms -> 437ms. Go: 2ms -> 6.2ms -> 13.8ms. What happened and why Node was affected more than Go? Every new connection, say in your database connections pool, becomes a new source of events for your server. At some point just switching between different sources-of-events/connections becomes relatively expensive and Node was affected by that much more than Go just becasue it could not utilise parallelism and handle different connections simultaneously.

![](imgs/perf_stats.png)
