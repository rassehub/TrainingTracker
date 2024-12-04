// userLogMiddleware.js

const UserLog = require('../models/userLogModel'); // Import the UserLog model

// Middleware to log user actions
async function logUserAction(req, res, next) {
  try {
    const userId = req.session.userId || 'unauthorized'; // Replace with actual user ID retrieval logic
    const ip = req.ip;
    const userAgent = req.headers['user-agent'];

    // Exclude the session ID cookie from the logged details
    const headersToLog = { ...req.headers };
    if (headersToLog.cookie) {
      // Remove the session cookie (e.g., connect.sid)
      headersToLog.cookie = headersToLog.cookie
        .split(';')
        .filter(cookie => !cookie.trim().startsWith('connect.sid='))
        .join(';');
    }

    const logEntry = new UserLog({
      userId,
      action: `${req.method} ${req.originalUrl}`,
      ip,
      userAgent,
      details: {
        headers: headersToLog, // Log the headers, excluding the session cookie
        body: req.body,
      },
    });

    // Save the log entry to MongoDB
    await logEntry.save();
  } catch (error) {
    console.error('Error logging user action:', error);
  }

  next(); // Pass control to the next middleware
}

module.exports = logUserAction; // Export the middleware function