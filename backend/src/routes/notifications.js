const express = require('express');
const auth = require('../middleware/auth');
const User = require('../models/user');
const Session = require('../models/session');
const ExerciseLog = require('../models/exercise_log');
const router = express.Router();

router.get('/message', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    const recentSessions = await Session.find({ userId: req.userId })
      .sort({ createdAt: -1 }).limit(5);
    const today = new Date().toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase().slice(0, 3);
    const todaySplit = user.split?.[today] || 'workout';
    const lastSession = recentSessions[0];
    const lastExercises = lastSession?.exercises?.slice(0, 3).map(e => `${e.name} ${e.weight}kg`).join(', ') || 'no recent data';

    const prompt = `You are a gym notification generator for a lifting app called LiftTrack.
Generate a short, motivating push notification for a lifter.
Keep the title under 40 characters and body under 80 characters.
Be direct, not cringe. No hashtags. No exclamation marks unless truly warranted.

Context:
- User's name: ${user.name}
- Today's split: ${todaySplit}
- Last session exercises: ${lastExercises}
- Sessions this week: ${recentSessions.length}

Respond in this exact JSON format:
{"title": "...", "body": "..."}`;

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 100,
        messages: [{ role: 'user', content: prompt }]
      })
    });

    const data = await response.json();
    const text = data.content[0].text.trim();
    const message = JSON.parse(text);
    res.json(message);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
