const express = require('express');
const bodyParser = require('body-parser');
const fetch = require('node-fetch');

const app = express();
app.use(bodyParser.json());

// Health
app.get('/', (req, res) => res.send('TechDeck functions prototype'));

// OpenAI proxy endpoint (placeholder)
app.post('/openaiProxy', async (req, res) => {
  const prompt = req.body.prompt || '';
  const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
  if (!OPENAI_API_KEY) {
    return res.status(500).json({ error: 'OPENAI_API_KEY not configured in functions environment.' });
  }

  try {
    // Use OpenAI Completion or Chat API -- this is a minimal example using text completion endpoint
    const response = await fetch('https://api.openai.com/v1/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({ model: 'text-davinci-003', prompt: prompt, max_tokens: 300 }),
    });
    const data = await response.json();
    const text = (data.choices && data.choices[0] && data.choices[0].text) ? data.choices[0].text.trim() : null;
    return res.json({ text });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'OpenAI request failed' });
  }
});

// WhatsApp webhook stub
app.post('/whatsappWebhook', (req, res) => {
  // Validate webhook token / signature in production
  console.log('Received whatsapp webhook (prototype):', JSON.stringify(req.body).slice(0, 500));
  // In production you would parse messages and store them in Firestore / Storage
  res.sendStatus(200);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Functions prototype listening on ${PORT}`));
