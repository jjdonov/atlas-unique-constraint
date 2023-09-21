## Issue Reproduction

This is a reproduction of [Atlas #2107](https://github.com/ariga/atlas/issues/2107)
This reproduction has been tested against:

```
atlas version

Atlas version
atlas version v0.13.2-63aacd3-canary
https://github.com/ariga/atlas/releases/latest
```

and
```
atlas version

atlas version v0.14.2-19611bb-canary
https://github.com/ariga/atlas/releases/latest
```


### Reproduction Steps

1. `docker-compose up`
2. Generate the schema and write the file
```
atlas schema inspect \
--schema auth \
--env poc \
--format '{{sql . "  "}}' >! poc.sql
```
3. ❗**Note** that the schame contains the unique index, but not the constraint ❗
4. Generate the baseline ...
```
 atlas migrate diff --env poc baseline
 ```
5. Apply the baseline
```
atlas migrate apply --env poc --baseline 20230921185848
```
6. Edit the schema, remove the index.
7. Run schema diff
```
--env poc \
--schema auth \
--to file://poc.sql \
--from "postgres://user:pass@localhost:5455?sslmode=disable"   
```

Outputs:
```
-- Modify "email_token" table
ALTER TABLE "auth"."email_token" DROP CONSTRAINT "email_token_user_id_unique";
```

7. Run migrate diff
```
atlas migrate diff rm-unique --env poc
```

8. Fail to apply the migration
```
atlas migrate apply --env poc
```

```
Migrating to version 20230921190633 from 20230921185848 (1 migrations in total):

  -- migrating version 20230921190633
    -> DROP INDEX "auth"."email_token_user_id_unique";
    pq: cannot drop index auth.email_token_user_id_unique because constraint email_token_user_id_unique on table auth.email_token requires it

  -------------------------
  -- 18.463208ms
  -- 0 migrations ok (1 with errors)
  -- 0 sql statements ok (1 with errors)
Error: sql/migrate: sql/migrate: execute: executing statement "DROP INDEX \"auth\".\"email_token_user_id_unique\";" from version "20230921190633": pq: cannot drop index auth.email_token_user_id_unique because constraint email_token_user_id_unique on table auth.email_token requires it: sql/migrate: execute: write revision: pq: current transaction is aborted, commands ignored until end of transaction block
```

The migration fails to apply. The generated migration file uses drop index, while the schema diff version uses drop constraint.

That `migrate diff` and `schema diff` output different things seems problematic, but I think the root issue starts with the introspection -- because it omits the constraint, and uses the index instead. From PG docs:

> Adding a unique constraint will automatically create a unique B-tree index on the column or group of columns listed in the constraint.
[PostgreSQL: Documentation: 9.4: Constraints](https://www.postgresql.org/docs/16/ddl-constraints.html)

Likewise, dropping a unique constraint removes the index. But dropping the index does not remove the constraint.

