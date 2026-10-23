import pg from "pg";
import dotenv from "dotenv";
dotenv.config();

const DEFAULT_DB_URL = "postgresql://neondb_owner:npg_n5x6yADtKUNr@ep-royal-wind-b3xs2hr2.c-4.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&options=-csearch_path%3Dsting,public";

let connectionString = process.env.DATABASE_URL || DEFAULT_DB_URL;
if (connectionString.includes("neon.tech") && !connectionString.includes("options=")) {
  connectionString = connectionString.replace("-pooler", "");
  const sep = connectionString.includes("?") ? "&" : "?";
  connectionString = `${connectionString}${sep}options=-csearch_path%3Dsting,public`;
}

const isLocal = !connectionString || 
  connectionString.includes("localhost") || 
  connectionString.includes("127.0.0.1");

export const pool = new pg.Pool({
  connectionString,
  ssl: isLocal ? false : { rejectUnauthorized: false },
});

pool.on("error", (err) => {
  console.error("Database connection warning:", err.message);
});

export const q = (text, params) => pool.query(text, params);

