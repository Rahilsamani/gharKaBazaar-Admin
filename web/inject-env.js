const fs = require("fs");
const path = require("path");
const dotenv = require("dotenv");

// Load environment variables from .env file
dotenv.config();

// Path to your HTML file
const filePath = path.join(__dirname, "index.html");

// Read the HTML file
let htmlContent = fs.readFileSync(filePath, "utf8");

// Replace placeholders with environment variables
htmlContent = htmlContent.replace(
  /\$FIREBASE_API_KEY/g,
  process.env.FIREBASE_API_KEY
);
htmlContent = htmlContent.replace(
  /\$FIREBASE_AUTH_DOMAIN/g,
  process.env.FIREBASE_AUTH_DOMAIN
);
htmlContent = htmlContent.replace(
  /\$FIREBASE_PROJECT_ID/g,
  process.env.FIREBASE_PROJECT_ID
);
htmlContent = htmlContent.replace(
  /\$FIREBASE_STORAGE_BUCKET/g,
  process.env.FIREBASE_STORAGE_BUCKET
);
htmlContent = htmlContent.replace(
  /\$FIREBASE_MESSAGING_SENDER_ID/g,
  process.env.FIREBASE_MESSAGING_SENDER_ID
);
htmlContent = htmlContent.replace(
  /\$FIREBASE_APP_ID/g,
  process.env.FIREBASE_APP_ID
);
htmlContent = htmlContent.replace(
  /\$FIREBASE_MEASUREMENT_ID/g,
  process.env.FIREBASE_MEASUREMENT_ID
);

// Write the modified content back to the HTML file
fs.writeFileSync(filePath, htmlContent, "utf8");

console.log("Environment variables injected into HTML file");
