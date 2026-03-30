const mongoose = require('mongoose');

const exerciseEntrySchema = new mongoose.Schema({
  name: { type: String, required: true },
  weight: { type: Number, required: true },
  sets: Number,
  reps: Number
});

const sessionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  splitDay: { type: String, required: true },
  exercises: [exerciseEntrySchema]
}, { timestamps: true });

module.exports = mongoose.model('Session', sessionSchema);
