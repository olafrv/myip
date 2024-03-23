const { env } = require('process');
const express = require('express');
const maxmind = require('@maxmind/geoip2-node').Reader;

const app = express();

app.use((req, res, next) => {
    const clientIP = req.ip || req.socket.remoteAddress;
    const token = req.query.token || '';
    if(token !== env.MYIP_TOKEN){
        res.status(403).json({
            error: 'Unauthorized'
        });
        console.log(clientIP + ': Unauthorized!');
        return;
    }
    req.clientIP = clientIP;
    maxmind.open('./dbs/GeoLite2-ASN.mmdb').then(reader => {
        try {
            const response = reader.asn(clientIP);
            req.asn = response.Asn.autonomousSystemOrganization;
        }catch(error){
            console.log(error.message);
            req.asn = undefined;
        }
    });
    next();
});

app.get('/', (req, res) => {
    if (req.asn === undefined){
        res.json({
            ip: req.clientIP,
            asn: 'unknown'
        });
    }else{
        res.json({
            ip: req.clientIP,
            asn: req.asn
        });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
