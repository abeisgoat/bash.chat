const functions = require('firebase-functions');
const fs = require('fs');

const app = require('express')();

app.get("/", (req, res) => {
    const starterScript = fs.readFileSync("./starter.sh");
    const ua = req.headers["user-agent"];
    let protocol = req.protocol;
    const port = req.port;
    let host = req.get('host');

    if (host == "us-central1-fir-bash-chat.cloudfunctions.net") {
        host = "bash.chat"
        protocol = "https"
    }

    const url = `${protocol}://${host}/chat.sh`;

    if (ua.indexOf("curl") != -1) {
      res.send(starterScript.toString().replace("${url}", url));
    } else {
      res.send("$ bash <(curl https://bash.chat)");
    }
    res.end();
});

app.get("/chat.sh", (req, res) => {
    const bashScript = fs.readFileSync("./script.sh");
    res.send(bashScript);
});

exports.run = functions.https.onRequest(app);

if (require.main === module) {
    app.listen(8080);
}