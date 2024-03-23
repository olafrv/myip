const { env } = require('process');
const express = require('express');
const maxmind = require('@maxmind/geoip2-node').Reader;

const PORT = env.MYIP_PORT || 3000;
const app = express();

app.use((req, res, next) => {
    const clientIP = req.ip || req.socket.remoteAddress;
    const token = req.query.token || '';
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

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});
