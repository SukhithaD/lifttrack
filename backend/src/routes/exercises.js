const express = require('express');
const ExerciseLog = require('../models/exercise_log');
const auth = require('../middleware/auth');
const router = express.Router();

router.get('/', auth, async (req, res) => {
  try {
    const names = await ExerciseLog.distinct('name', { userId: req.userId });
    res.json(names);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/:name', auth, async (req, res) => {
  try {
    const logs = await ExerciseLog.find({
      userId: req.userId,
      name: { $regex: new RegExp('^' + req.params.name + '$', 'i') }
    }).sort({ createdAt: -1 }).limit(20);
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
