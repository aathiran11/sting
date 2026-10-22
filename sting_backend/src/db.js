import pg from "pg";
import dotenv from "dotenv";
dotenv.config();

const isLocal = !process.env.DATABASE_URL || 
  process.env.DATABASE_URL.includes("localhost") || 
  process.env.DATABASE_URL.includes("127.0.0.1");

export const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: isLocal ? false : { rejectUnauthorized: false },
});

pool.on("error", (err) => {
  console.error("Database connection warning:", err.message);
});

export const q = (text, params) => pool.query(text, params);
