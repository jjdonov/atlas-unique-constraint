-- Add new schema named "auth"
CREATE SCHEMA "auth";
-- Create "email_token" table
CREATE TABLE "auth"."email_token" (
  "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "user_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
-- Create index "email_token_user_id_unique" to table: "email_token"
CREATE UNIQUE INDEX "email_token_user_id_unique" ON "auth"."email_token" ("user_id");
