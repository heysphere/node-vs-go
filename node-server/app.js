const fs = require('fs')
const express = require("express");
const app = express();

const PORT = process.env.BATTLE_PORT
TEST_FILENAME = '1mb.txt'


app.get("/now", (req, res, next) => {
    res.json({now: Date.now()})
})

app.get("/now-5ms-delay", (req, res, next) => {
    setTimeout(() => {
        res.json({now: Date.now()})
    }, 5)
})

app.listen(PORT, () => {
    console.log(`[Node] :: listening on ${PORT} and ready 👌`)
})

// app.get("/fast", (req, res, next) => {
//     setTimeout(() => {
//         res.json({now: Date.now()})
//     }, 1000 * 5)
// });

// app.get('/with-async-io', (req, res, next) => {
//     setTimeout(() => {
//         res.json({now: Date.now()})
//     }, 10)
// })

// app.get('/blocking-read', (req, res, next) => {
//     let ctx = fs.readFileSync(TEST_FILENAME)
//     res.json({data: ctx})
// })

// app.get('/non-blocking-read', (req, res, next) => {
//     fs.readFile(TEST_FILENAME, (buf) => {
//         res.json({ data: buf })
//     })
// })


// function computeFibonacci(n) {
//     if (n == 0) return 0
//     if (n == 1) return 1
//     return computeFibonacci(n - 1) + computeFibonacci(n - 2)
// }

// app.get('/slow-computation', (req, res, next) => {
//         res.json({fib: computeFibonacci(100)})
// })

// app.get('/io-and-computation', (req, res, next) => {
//     setTimeout(() => {
//         res.json({fib: computeFibonacci(500)})
//     })
// })

