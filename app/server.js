"use strict";

// Minimal zero-dependency frontend service.
// Serves a static landing page at "/" and a health probe at "/health".
// Port and health path align with the ECS/ALB expectations in
// app/infrastructure/terraform/aws/frontend (container_port = 3000, path = /health).

const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");

const PORT = Number(process.env.PORT) || 3000;
const HOST = process.env.HOST || "0.0.0.0";

const indexHtml = fs.readFileSync(path.join(__dirname, "public", "index.html"));

const server = http.createServer((req, res) => {
  if (req.url === "/health" || req.url === "/healthz") {
    res.writeHead(200, { "content-type": "application/json" });
    res.end(JSON.stringify({ status: "ok", uptime: process.uptime() }));
    return;
  }

  if (req.method === "GET" && (req.url === "/" || req.url === "/index.html")) {
    res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
    res.end(indexHtml);
    return;
  }

  res.writeHead(404, { "content-type": "text/plain" });
  res.end("Not Found");
});

server.listen(PORT, HOST, () => {
  console.log(`frontend listening on http://${HOST}:${PORT}`);
});

// Graceful shutdown so ECS task draining is clean.
for (const signal of ["SIGTERM", "SIGINT"]) {
  process.on(signal, () => {
    console.log(`received ${signal}, shutting down`);
    server.close(() => process.exit(0));
  });
}
