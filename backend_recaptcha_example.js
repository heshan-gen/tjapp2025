// Backend API Example for reCAPTCHA v3 Verification
// This should be implemented on your backend server

const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Your reCAPTCHA secret key (keep this secure!)
const RECAPTCHA_SECRET_KEY = '6Lf7Zh8jAAAAAHP2FjcUeunJLhtraS3LJROxk7Nn';
const RECAPTCHA_VERIFY_URL = 'https://www.google.com/recaptcha/api/siteverify';
const MIN_SCORE_THRESHOLD = 0.5;

// Verify reCAPTCHA token
async function verifyRecaptcha(token) {
  try {
    const response = await axios.post(RECAPTCHA_VERIFY_URL, {
      secret: RECAPTCHA_SECRET_KEY,
      response: token,
      remoteip: req.ip // Optional: include user's IP
    });

    const { success, score, action, challenge_ts, hostname, 'error-codes': errorCodes } = response.data;

    // Check if verification was successful
    if (!success) {
      console.log('reCAPTCHA verification failed:', errorCodes);
      return { valid: false, reason: 'Verification failed', errorCodes };
    }

    // Check score threshold
    if (score < MIN_SCORE_THRESHOLD) {
      console.log(`reCAPTCHA score too low: ${score} (minimum: ${MIN_SCORE_THRESHOLD})`);
      return { valid: false, reason: 'Score too low', score };
    }

    // Check action (optional but recommended)
    if (action !== 'contact_form_submit') {
      console.log(`reCAPTCHA action mismatch: ${action} (expected: contact_form_submit)`);
      return { valid: false, reason: 'Action mismatch', action };
    }

    return { 
      valid: true, 
      score, 
      action, 
      timestamp: challenge_ts,
      hostname 
    };

  } catch (error) {
    console.error('reCAPTCHA verification error:', error);
    return { valid: false, reason: 'Verification error', error: error.message };
  }
}

// API endpoint to verify reCAPTCHA and process contact form
app.post('/api/contact', async (req, res) => {
  try {
    const { name, email, subject, message, recaptchaToken } = req.body;

    // Validate required fields
    if (!name || !email || !subject || !message || !recaptchaToken) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    // Verify reCAPTCHA token
    const recaptchaResult = await verifyRecaptcha(recaptchaToken);
    
    if (!recaptchaResult.valid) {
      return res.status(400).json({
        success: false,
        message: 'reCAPTCHA verification failed',
        reason: recaptchaResult.reason
      });
    }

    // If reCAPTCHA is valid, process the contact form
    // Here you would typically:
    // 1. Save to database
    // 2. Send email notification
    // 3. Log the submission
    
    console.log('Contact form submitted successfully:', {
      name,
      email,
      subject,
      recaptchaScore: recaptchaResult.score
    });

    // TODO: Implement your email sending logic here
    // Example: await sendEmail({ name, email, subject, message });

    res.json({
      success: true,
      message: 'Message sent successfully',
      recaptchaScore: recaptchaResult.score
    });

  } catch (error) {
    console.error('Contact form error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
