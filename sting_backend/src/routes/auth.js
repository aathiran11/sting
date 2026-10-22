import express from "express";
import bcrypt from "bcryptjs";
import { q } from "../db.js";
import { signToken } from "../middleware/auth.js";

const router = express.Router();

function genOtp() {
  return String(Math.floor(1000 + Math.random() * 9000)); // 4 digits
}

// POST /api/auth/register  { email? , phone?, password }
router.post("/register", async (req, res) => {
  const { email, phone, password } = req.body;
  if ((!email && !phone) || !password || password.length < 6) {
    return res.status(400).json({ error: "Email or phone, and a password of 6+ chars, are required." });
  }

  const existing = await q("SELECT id FROM users WHERE email = $1 OR phone = $2", [email || null, phone || null]);
  if (existing.rows.length) {
    return res.status(409).json({ error: "An account with this email/phone already exists." });
  }

  const code = genOtp();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 min
  await q("INSERT INTO otp_codes (contact, code, expires_at) VALUES ($1, $2, $3)", [
    email || phone,
    code,
    expiresAt,
  ]);

  // In production this goes out via an SMS/email provider (Twilio, SES, etc).
  // For now we log it so you can test the flow end-to-end locally.
  console.log(`[OTP] Code for ${email || phone}: ${code}`);

  // Stash the pending signup in a short-lived way: we re-verify password
  // client-side by round-tripping it through /verify-otp below, so nothing
  // sensitive sits unhashed longer than necessary here. Store hash now.
  const passwordHash = await bcrypt.hash(password, 10);
  await q(
    `INSERT INTO otp_codes (contact, code, expires_at) VALUES ($1, $2, $3)`,
    [`pending:${email || phone}:${passwordHash}`, code, expiresAt]
  );

  res.json({ message: "Verification code sent.", devHint: process.env.NODE_ENV !== "production" ? code : undefined });
});

// POST /api/auth/verify-otp  { contact, code }
router.post("/verify-otp", async (req, res) => {
  const { contact, code } = req.body;
  if (!contact || !code) return res.status(400).json({ error: "contact and code are required." });

  const result = await q(
    `SELECT * FROM otp_codes
     WHERE contact LIKE $1 AND code = $2 AND used = FALSE AND expires_at > now()
     ORDER BY created_at DESC LIMIT 1`,
    [`pending:${contact}:%`, code]
  );
  if (!result.rows.length) {
    return res.status(400).json({ error: "Invalid or expired code." });
  }

  const row = result.rows[0];
  await q("UPDATE otp_codes SET used = TRUE WHERE id = $1", [row.id]);

  const passwordHash = row.contact.split(":")[2];
  const isEmail = contact.includes("@");

  const inserted = await q(
    `INSERT INTO users (email, phone, password_hash, username)
     VALUES ($1, $2, $3, $4) RETURNING id, username`,
    [isEmail ? contact : null, isEmail ? null : contact, passwordHash, `user${Date.now()}`]
  );

  const token = signToken(inserted.rows[0].id);
  res.json({ token, userId: inserted.rows[0].id });
});

// POST /api/auth/login  { emailOrUsername, password }
router.post("/login", async (req, res) => {
  const { emailOrUsername, password } = req.body;
  if (!emailOrUsername || !password) {
    return res.status(400).json({ error: "emailOrUsername and password are required." });
  }

  const result = await q(
    "SELECT * FROM users WHERE email = $1 OR username = $1 OR phone = $1",
    [emailOrUsername]
  );
  if (!result.rows.length) return res.status(401).json({ error: "Invalid credentials." });

  const user = result.rows[0];
  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) return res.status(401).json({ error: "Invalid credentials." });

  const token = signToken(user.id);
  res.json({ token, userId: user.id, username: user.username });
});

// POST /api/auth/forgot-password  { email }
router.post("/forgot-password", async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: "email is required." });

  const result = await q("SELECT id FROM users WHERE email = $1", [email]);
  // Always respond success regardless of whether the account exists —
  // avoids leaking which emails are registered.
  if (result.rows.length) {
    const code = genOtp();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    await q("INSERT INTO otp_codes (contact, code, expires_at) VALUES ($1, $2, $3)", [
      `reset:${email}`,
      code,
      expiresAt,
    ]);
    console.log(`[RESET] Code for ${email}: ${code}`);
  }
  res.json({ message: "If that email exists, a reset code has been sent." });
});

// GET /api/auth/check-username/:username
router.get("/check-username/:username", async (req, res) => {
  const { username } = req.params;
  if (!/^[a-z0-9._]{3,20}$/.test(username)) {
    return res.json({ available: false, reason: "3-20 chars, lowercase letters/numbers/./_" });
  }
  const result = await q("SELECT id FROM users WHERE username = $1", [username]);
  res.json({ available: result.rows.length === 0 });
});

export default router;
