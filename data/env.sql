--  This SQL script will create a database for the nushell environment.
--  All environment variables and data for the shell will eventually be stored
--  in this file.
--  Required Tables
--  1. Quotes
--  2. DailyQuote
--  3. Tasks
--  4. Environment Variables
--  5. Color Palettes (?)
--  6. Themes (?)
--  7. E-Book Library integration (Rust interactions?)

-- DROP TABLE [IF EXISTS] Quotes;
-- DROP TABLE [IF EXISTS] DailyQuote;
-- DROP TABLE [IF EXISTS] Tasks;

--  Current store for all quotes.
CREATE TABLE IF NOT EXISTS main.Quotes (
  ID      INT         PRIMARY KEY NOT NULL,
  AUTHOR  TEXT   NOT NULL,
  QUOTE   TEXT  NOT NULL
);
--  The current daily quote will be queryed with the current date.
--  Maintains quote history over time.

--  If there is a table with a foreign key and the reference table is being
--  deleted then you need to disable foreign keys temporarily and then re-enable
--  them.
--  PRAGMA foreign_keys = OFF;
--  DROP TABLE main.Quotes;
--  UPDATE main.DailyQuote
--  SET QUOTE_ID = 0;
--  PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS main.DailyQuote(
  ID        INT   PRIMARY KEY NOT NULL,
  QUOTE_ID  INT   NOT NULL,
  DOQ       TEXT  NOT NULL,
  FOREIGN KEY(QUOTE_ID) REFERENCES Quotes(ID)
);
--  Tasks have yet to be implemented.
--  Functions Required:
--  Get
--  All
--  Filter Due Date
--  Filter Creation Date
--  Insert
--  Update
CREATE TABLE IF NOT EXISTS main.Tasks(
  ID        INT         PRIMARY KEY NOT NULL,
  DESC      TEXT   NOT NULL,
  NAME      TEXT   NOT NULL,
  TYPE      INT    NOT NULL,
  CREATED   DATE   NOT NULL,
  DUE       DATE,
  COMPLETED BOOL        NOT NULL
);
-- Contains the string environment variables.
CREATE TABLE IF NOT EXISTS main.Env(
  ID        INT   PRIMARY KEY   NOT NULL,
  KEY       TEXT  NOT NULL,
  VALUE     TEXT  NOT NULL
)