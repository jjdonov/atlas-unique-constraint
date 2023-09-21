create extension if not EXISTS "uuid-ossp";
-- Add new schema named "auth"
CREATE SCHEMA "auth";
-- Create "email_token" table
CREATE TABLE "auth"."email_token" (
  "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "user_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
