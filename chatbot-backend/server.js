import express from "express";
import bodyParser from "body-parser";
import fetch from "node-fetch";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();

const app = express();
app.use(bodyParser.json());
app.use(cors());

const PORT = process.env.PORT || 8080;
const GOOGLE_API_KEY = process.env.API_KEY;

app.get("/", async (req, res) => {
  res.send("Helloooo");
});

// Chatbot endpoint - UPDATED
app.post("/api/chat", async (req, res) => {
  try {
    const userMessage = req.body.message;
    if (!userMessage) {
      return res.status(400).json({ error: "Message is required." });
    }
    console.log("User message:", userMessage);

    // ✅ 1. NEW: Use the updated Gemini API endpoint
    const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${GOOGLE_API_KEY}`;

    // ✅ 2. NEW: Use the updated request body structure for Gemini
    const requestBody = {
      contents: [{
        parts: [{
          text: userMessage
        }]
      }]
    };

    const response = await fetch(apiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(requestBody),
    });

    if (!response.ok) {
      // Log the error response from the API for better debugging
      const errorData = await response.json();
      console.error("API Error:", errorData);
      throw new Error(`API request failed with status ${response.status}`);
    }

    const data = await response.json();
    
    // ✅ 3. NEW: Use the updated path to get the bot's reply
    const botReply = data.candidates?.[0]?.content?.parts?.[0]?.text || "Sorry, I couldn't get a response.";

    res.json({ reply: botReply });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong on our end." });
  }
});

app.listen(PORT, () =>
  console.log(`✅ Chatbot backend running on port ${PORT}`)
);
