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
--  Current store for all quotes.
CREATE TABLE
  IF NOT EXISTS main.Quotes (
    ID INT PRIMARY KEY NOT NULL,
    AUTHOR TEXT NOT NULL,
    QUOTE TEXT NOT NULL
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
CREATE TABLE
  IF NOT EXISTS main.DailyQuote (
    ID INT PRIMARY KEY NOT NULL,
    QUOTE_ID INT NOT NULL,
    --  ID in Quotes table
    DOQ TEXT NOT NULL,
    --  Date of Quote: When the daily quote was created.
    FOREIGN KEY (QUOTE_ID) REFERENCES Quotes (ID)
  );

--  Types:
--  0: Single Event Task
--  1: Recurring Task
--  2: No Due Date
CREATE TABLE
  IF NOT EXISTS main.Tasks (
    ID INT PRIMARY KEY NOT NULL,
    NAME TEXT NOT NULL,
    --  The short hand task name
    DESC TEXT NOT NULL,
    --  Description/Meta information about the task.
    TYPE INT NOT NULL,
    --  The Task type as an int. There will be an enum.
    CREATED DATE NOT NULL,
    --  Date the task was created/assigned.
    DUE DATE,
    --  Date of the task's deadline.
    COMPLETED BOOL NOT NULL --  Whether the task is completed.
  );

--  Contains the Main-Sub task relationship allowing for tasks to be broken
--  down into sub tasks.
CREATE TABLE
  IF NOT EXISTS main.SubTasks (
    ID INT PRIMARY KEY NOT NULL,
    MAIN INT NOT NULL,
    SUB INT NOT NULL,
    FOREIGN KEY (MAIN) REFERENCES Tasks (ID),
    FOREIGN KEY (SUB) REFERENCES Tasks (ID)
  );

--  Contains the string environment variables.
--  Records are stored as json text and serialized in the script.
--  May store variable types with the key
--  The type can then be split from the key and a conversion ran.
--  0: string, 1: bool, 2: int, 3: record
CREATE TABLE
  IF NOT EXISTS main.Env (
    ID INT PRIMARY KEY NOT NULL,
    KEY TEXT NOT NULL,
    --  Key in $env. $env.Key
    VALUE TEXT NOT NULL --  Value for $env.Key. Maybe add extra parsing options, for tables in json etc.
    TYPE INT NOT NULL --  Represents the data types.
  );