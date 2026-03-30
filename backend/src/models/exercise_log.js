const mongoose = require('mongoose');

const exerciseLogSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  weight: { type: Number, required: true },
  sets: Number,
  reps: Number,
  sessionId: { type: mongoose.Schema.Types.ObjectId, ref: 'Session' }
}, { timestamps: true });

module.exports = mongoose.model('ExerciseLog', exerciseLogSchema);
