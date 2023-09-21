create extension if not exists "uuid-ossp";
create schema "auth";
create schema "user";

create table "auth"."email_token" (
  "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "user_id" integer NOT NULL,

  primary key("id")
);

alter table "auth"."email_token" ADD CONSTRAINT email_token_user_id_unique UNIQUE (user_id);