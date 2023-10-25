const express = require('express')
const app = express();
const port = 8000
const http = require('http');


app.use(express.urlencoded({ extended: true }));

app.use(express.json());
const bodyParser = require('body-parser');
app.use(bodyParser.json());

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello, World!\n');
});
const transaction = require("./routes/transaction");
app.use("/api/transaction/", transaction);



app.listen(port, '192.168.1.5', () => {
    console.log('Server is running on http://192.168.1.5:8000');
})