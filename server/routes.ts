import type { Express } from "express";
import express from "express";
import { createServer, type Server } from "http";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { villages } from "./data/villages";
import { festivals } from "./data/festivals";
import { morungData } from "./data/morung";
import { glossaryTerms } from "./data/glossary";
import { storage } from "./storage";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export async function registerRoutes(app: Express): Promise<Server> {
  // Serve static assets (images) from attached_assets folder with cache headers
  app.use("/assets", express.static(path.resolve(__dirname, "..", "attached_assets"), {
    etag: true,
    lastModified: true,
    maxAge: 0, // Don't cache aggressively - allow immediate revalidation
    setHeaders: (res, path) => {
      // For images, set cache-control to allow revalidation
      if (path.match(/\.(jpg|jpeg|png|gif|webp|svg)$/i)) {
        res.setHeader('Cache-Control', 'no-cache, must-revalidate');
      }
    }
  }));

  // Middleware to set no-cache headers for all API responses
  app.use("/api", (req, res, next) => {
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate, max-age=0');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    next();
  });

  // Get all villages
  app.get("/api/villages", (req, res) => {
    res.json(villages);
  });

  // Get single village by ID
  app.get("/api/villages/:id", (req, res) => {
    const village = villages.find(v => v.id === req.params.id);
    if (!village) {
      return res.status(404).json({ error: "Village not found" });
    }
    res.json(village);
  });

  // Get all festivals
  app.get("/api/festivals", (req, res) => {
    res.json(festivals);
  });

  // Get morung information
  app.get("/api/morung", (req, res) => {
    res.json(morungData);
  });

  // Get glossary terms
  app.get("/api/glossary", (req, res) => {
    res.json(glossaryTerms);
  });

  // Get visitor count
  app.get("/api/visitor-count", (req, res) => {
    res.json({ count: storage.getVisitorCount() });
  });

  // Increment visitor count (called when a new visitor arrives)
  app.post("/api/visitor-count/increment", (req, res) => {
    const count = storage.incrementVisitorCount();
    res.json({ count });
  });

  const httpServer = createServer(app);

  return httpServer;
}
