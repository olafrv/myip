const { env } = require('process');
const express = require('express');
const maxmind = require('@maxmind/geoip2-node').Reader;
const fs = require("fs");

const PORT = env.MYIP_PORT || 3000;
const SSL_KEY = "./letsencrypt/privkey.pem";
const SSL_FULLCHAIN = "./letsencrypt/fullchain.pem";

const app = express();
const http = require('http');
const https = require('https');

app.use((req, res, next) => {
    const clientIP = req.ip || req.socket.remoteAddress;
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : '';
    if(token != env.MYIP_TOKEN){
        console.log(clientIP + ': Unauthorized!');
        res.status(403).json({
            error: 'Unauthorized'
        });
        return;
    }
    req.clientIP = clientIP;
    next();
});

app.get('/', (req, res) => {
    maxmind.open('./dbs/GeoLite2-ASN.mmdb').then(reader => {
        try {
            const query = reader.asn(req.clientIP);
            req.clientASN = query.autonomousSystemOrganization;
            console.log(req.clientIP + ': ' + req.clientASN);
            res.json({
                    ip: req.clientIP,
                    asn: req.clientASN
            });
        }catch(error){
            console.log(req.clientIP + ': ' + error.message);
            res.status(404).json({
                    error: 'Not found'
            });
        }
    });
});

s_key_exists = fs.existsSync(SSL_KEY);
s_fc_exists = fs.existsSync(SSL_FULLCHAIN);

console.log("Exists? " + SSL_KEY + " => " + s_key_exists);
console.log("Exists? " + SSL_FULLCHAIN + " => " + s_fc_exists);

if (s_key_exists && s_fc_exists){
    https.createServer({
        key: fs.readFileSync(SSL_KEY),
        cert: fs.readFileSync(SSL_FULLCHAIN)
    }, app).listen(PORT, '0.0.0.0', () => {
        console.log(`Server HTTPS is running on port ${PORT}`);
    });    
}else{
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`Server HTTP is running on port ${PORT}`);
    });    
}
