CREATE TABLE memos(
  id serial PRIMARY KEY,
  title text NOT NULL,
  body text NOT NULL,
  created_at timestamp with time zone NOT NULL,
  edited_at timestamp with time zone
);
