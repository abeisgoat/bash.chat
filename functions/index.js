const functions = require('firebase-functions');
const fs = require('fs');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

const app = require('express')();

/********************************
 * Client Server
 */

app.get("/", (req, res) => {
    let starterScript = fs.readFileSync("./starter.sh").toString();
    const ua = req.headers["user-agent"];
    let protocol = req.protocol;
    const port = req.port;
    let host = req.get('host');

    if (host == "us-central1-fir-bash-chat.cloudfunctions.net") {
        protocol = "https"
    }

    const host_url = `${protocol}://${host}`;
    const client_url = `${host_url}/client.sh`;

    if (ua.indexOf("curl") != -1) {
      starterScript = starterScript.replace(new RegExp("CLIENT_URL", "g"), client_url)
      starterScript = starterScript.replace(new RegExp("HOST_URL", "g"), host_url)
      res.send(starterScript);
    } else {
      res.send("$ bash <(curl https://bash.chat)");
    }
    res.end();
});

app.get("/client.sh", (req, res) => {
    const bashScript = fs.readFileSync("./client.sh");
    console.log("Sending client.sh")
    res.send(bashScript);
});

app.get("/stream.awk", (req, res) => {
  const f = fs.readFileSync("./stream.awk");
  console.log("Sending stream.awk");
  res.send(f);
});

/********************************
 * Chat Server 
 */

const db = admin.firestore();

app.get("/listen", (req, res) => {
  console.log(req.query);
  if (!req.query.skipWelcome) {
    console.log("Sending welcome")
    res.write("WelcomeBot|Welcome to WWW chat!|26|");
  }

  console.log("Setting up listneer")
  const roomId = "default";
  db.collection(`chats/${roomId}/messages`)
    .orderBy("timestamp", "asc")
    .onSnapshot((snapshot) => {
      snapshot.docChanges.forEach((change) => {
        if (change.type == "added") {
          const data = change.doc.data();
          res.write(`${data.name}|${data.text}|${data.color}|`);
        }
      });
    });

  //TODO: Close snapshot on req close
});

app.get("/say", (req, res) => {
  const q = req.query;
  const text = q.text.trim();

  let sane = true;

  text.split("").forEach((c) => {
    const code = c.charCodeAt(0);

    sane = sane && (code >= 32 && code <= 126);
  });

  if (!sane) return res.end();  

  const name = q.name.slice(0, 12);
  const color = q.color;
  const roomId = "default";

  db.collection(`chats/${roomId}/messages`).add({
    name,
    text,
    color,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  }).then(() => {
    res.end("sent");
  });
});

/********************************
 * Initalization
 */

exports.run = functions.https.onRequest(app);

if (require.main === module) {
    app.listen(8080);
}