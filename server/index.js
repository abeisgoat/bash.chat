const app = require("express")();

const ress = [];

app.get("/listen", (req, res) => {
  if (!req.query.skipWelcome) {
    res.write("WelcomeBot|Welcome to WWW chat!|26|");
  }
  ress.push(res);
});

app.get("/say", (req, res) => {
  const q = req.query;
  const msg = `${q.name.slice(0, 12)}|${q.text}|${q.color}|`;
  
  ress.forEach((res) => {
    res.write(msg);
  });

  console.log(msg);
  res.send("sent");
});

app.listen(5000);
