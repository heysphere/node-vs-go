# Node vs Go Performance Comparison

It is a case-by-case Node.js vs Go performance comparison, demonstraiting some pitfalls of the signle-threaded nature of Node.js that, when combined with heavy computatoin, start being a problem under certain load. It does not necesserily mean that Go is "better" than Node.js. As usual, it depends. Node is easier to pick up and simpler to use, Go is more performant but its performance comes with a price of dealing with some low-level details that make a bigger room for human error (like using shared resources from multiple goroutines or necessity to release some of system resources manually - like file descriptors). So, time for experiments and some numbers:

[_As a side note: on some of the graphs you can notice that the CPU usage is said to be in percents but the actual values go way above 1k. Well, blame psutil for OSX and the way it collects CPU usage for a selected process. Just treat it as some kind of index, higher the value -- higher the usage._]

## Max RPS

Let's see how much we can squeeze from Node.js and Go HTTP servers on my local machine (OSX, 3.1 GHz Intel Core i5, 8 GB 2133 MHz RAM) by calling a route that does nothing more than returning current timestamp. As you can see from the table below, single Go service can handle at least 3 times more RPS than the Node one with much better and less fluctuating latency. I said "at least" becasue the benchmark and the server were ran on the same machine and they were compeating for resources (like CPU), which didn't allow the Go server run at full scale.

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

Number of connections is basically how many sockets are used simultaneously for passing requests to the servers. 
Why does the number of connections affects the latency so much? Let's say you have a server keeping 10 open connections to your database. If the number of requests initiated to the database is too big, sockets queues (basically where OS kernel keep your requests until they can be passed to the network card) get full and become a bottleneck. That's why you can see a significant improvement in latency of both Node.js and Go servers when the number of simultaneous connections/sockets grows from 10 to 100. Although, latency starts to degrade when we move from 100 to 500 and then 1000 connections. It happens because every open socket comes with a price, it takes resources and has to be managed in some way by the server. At some point the number of open connections itself is just way too expensive to manage.

