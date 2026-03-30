const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  split: {
    mon: String, tue: String, wed: String,
    thu: String, fri: String, sat: String, sun: String
  },
  workoutDays: [String],
  notificationTime: { type: String, default: '07:00' },
  useKilograms: { type: Boolean, default: true },
  notificationsEnabled: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
