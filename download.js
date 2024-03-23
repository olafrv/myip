const { env } = require('process');
const https = require('https');
const httpsfr = require('follow-redirects').https;
const fs = require('fs');

const options = {
    host: 'download.maxmind.com',
    path: '/geoip/databases/GeoLite2-ASN/download?suffix=tar.gz',
    headers: {
        'Authorization': 'Basic ' + Buffer.from(env.MYIP_MM_USER + ':' + env.MYIP_MM_KEY).toString('base64')
    },
    filename: './dbs/GeoLite2-ASN.tar.gz'   
};

const file = fs.createWriteStream(options.filename);
request = httpsfr.get(options, function(res) {
    // console.log(res);
    res.pipe(file);
    file.on('finish', function() {
        file.close();
        console.log('Downloaded: ' + options.filename);
    });
});
