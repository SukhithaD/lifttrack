const express = require('express');
const ExerciseLog = require('../models/exercise_log');
const Session = require('../models/session');
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
    }).sort({ createdAt: -1 }).limit(20).lean();

    // Attach splitDay from session to each log
    const sessionIds = [...new Set(logs.map(l => l.sessionId?.toString()).filter(Boolean))];
    const sessions = await Session.find({ _id: { $in: sessionIds } }).lean();
    const sessionMap = {};
    sessions.forEach(s => { sessionMap[s._id.toString()] = s.splitDay; });

    const enriched = logs.map(log => ({
      ...log,
      splitDay: sessionMap[log.sessionId?.toString()] || '—'
    }));

    res.json(enriched);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
