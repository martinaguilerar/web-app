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
  res.status(200).sendFile(path.join(__dirname, '/index.html'));
});