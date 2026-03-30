const express = require('express');
const Session = require('../models/session');
const ExerciseLog = require('../models/exercise_log');
const auth = require('../middleware/auth');
const router = express.Router();

router.get('/', auth, async (req, res) => {
  try {
    const sessions = await Session.find({ userId: req.userId }).sort({ createdAt: -1 }).limit(20);
    res.json(sessions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/', auth, async (req, res) => {
  try {
    const { splitDay, exercises } = req.body;
    const session = await Session.create({ userId: req.userId, splitDay, exercises });
    const logs = exercises.map(ex => ({
      userId: req.userId,
      name: ex.name,
      weight: ex.weight,
      sets: ex.sets,
      reps: ex.reps,
      sessionId: session._id
    }));
    await ExerciseLog.insertMany(logs);
    res.status(201).json(session);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
