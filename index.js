const express = require('express')
const { BlobServiceClient } = require('@azure/storage-blob');

const app = express()
const port = 8080

const containerName = process.env.sa_container_name;
const account = process.env.sa_account_name;
const sas = process.env.sa_sas;

const blobServiceClient = new BlobServiceClient(`https://${account}.blob.core.windows.net${sas}`);

app.get('/', async (req, res) => {
  const blobName = 'greeting.png';

  try {
    const containerClient = blobServiceClient.getContainerClient(containerName);
    const blobClient = containerClient.getBlobClient(blobName);
    const response = await blobClient.download();
    res.setHeader('Content-Type', 'image/png');
    response.readableStreamBody.pipe(res);
  } catch (error) {
    console.error('Error fetching image:', error);
    res.status(500).send('Internal Server Error');
  }
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})