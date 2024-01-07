const express = require("express");
const sql = require('mssql');
  
const app = express();

const config = {
    authentication: {
        type: 'default'
    },
    options: {
        encrypt: true
    }
}
  
app.listen(8080, () => {
  console.log(`Server is up and running on 8080 ...`);
});

app.get("/", async (req, res) => {
  response.write("<h1>Hello</h1>");
  response.send();
});