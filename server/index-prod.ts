import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { type Server } from "node:http";

import express, { type Express } from "express";
import { config } from "dotenv";

// Load .envdev file for configuration
config({ path: ".envdev" });

const __dirname = path.dirname(fileURLToPath(import.meta.url));

import runApp from "./app";

export async function serveStatic(app: Express, _server: Server) {
  const distPath = path.resolve(__dirname, "public");

  if (!fs.existsSync(distPath)) {
    throw new Error(
      `Could not find the build directory: ${distPath}, make sure to build the client first`,
    );
  }

  // Serve static files with appropriate cache headers
  app.use(express.static(distPath, {
    etag: true,
    lastModified: true,
    setHeaders: (res, filePath) => {
      const fileName = path.basename(filePath);
      
      // Never cache HTML files - always fetch fresh version
      if (fileName === "index.html" || filePath.endsWith(".html")) {
        res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate, max-age=0');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
      }
      // JS and CSS files with hashes can be cached longer (Vite adds hashes to filenames)
      // But still allow revalidation to ensure updates are picked up
      else if (filePath.match(/\.(js|css)$/i)) {
        res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
      }
      // Other assets (images, fonts, etc.)
      else {
        res.setHeader('Cache-Control', 'public, max-age=86400, must-revalidate');
      }
    }
  }));

  // fall through to index.html if the file doesn't exist
  app.use("*", (_req, res) => {
    // Ensure index.html is never cached
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate, max-age=0');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    res.sendFile(path.resolve(distPath, "index.html"));
  });
}

(async () => {
  await runApp(serveStatic);
})();
