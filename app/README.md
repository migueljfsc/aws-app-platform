# app

Application layer for the platform.

- **`server.js`, `Dockerfile`, `public/`** — a minimal, zero-dependency Node.js
  frontend service. Serves a landing page at `/` and a health probe at `/health`.
  Port (`3000`) and health path match the ECS/ALB configuration in
  `app/infrastructure/terraform/aws/frontend`.
- **`infrastructure/`** — Terraform for the app tier (frontend + backend ECS
  services, and GitHub repository resources).

## Run locally

```bash
node server.js   # or: npm start
```

Then open http://localhost:3000 (health: http://localhost:3000/health).

## Run with Docker

```bash
docker build -t aws-app-platform-frontend .
docker run --rm -p 3000:3000 aws-app-platform-frontend
```

## Configuration

| Env var | Default   | Description   |
|---------|-----------|---------------|
| `PORT`  | `3000`    | Listen port   |
| `HOST`  | `0.0.0.0` | Bind address  |
