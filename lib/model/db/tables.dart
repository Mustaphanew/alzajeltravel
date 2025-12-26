String notifications = """
CREATE TABLE IF NOT EXISTS notifications(
  id varchar(255) PRIMARY key,
  title varchar(255),
  body text,
  img text,
  url text,
  page text,
  done_visit INTEGER DEFAULT 0,
  created_at varchar(50)
);
""";

String tmp = """
CREATE TABLE IF NOT EXISTS tmp(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name varchar(255),
  detail varchar(255),
  is_show INTEGER,
  created_at varchar(50),
  updated_at varchar(50)
);
""";
