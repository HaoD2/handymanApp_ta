const express = require('express')
const app = express();
const port = 3000
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
const FCM = require("./routes/firebaseFCM");
app.use("/api/transaction/", transaction);
app.use("/api/notification/", FCM);






app.listen(port, () => {
    console.log(`Server is running on ${port}`);
})

