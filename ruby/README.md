## Steps to run the tests

1. Create a `README.md` file under `/ruby/`
2. Copy the `.env.example` file under `/ruby/` and rename it to `.env`
3. Replace the `DB_HOST`, `DB_USER` and `DB_PASS` with the actual values.
4. Create the required DB and the tables using the provided Rakefile,
   ```bash
   $ rake db:create
   $ rake db:migrate
   $ rake db:seed
   ```
   This should create the DB, the tables and seeds the same with the initial set of data
5. Run the tests as specified in the handout (sent over email)

## Improvement suggestions:

1. Delete API doesn't follows API standards. Making changes in existing codebase will require doing changes in `spec/` directory. As of now, `delete` APIs return response code as `200`, instead they should return `204`
1. For Not Allowed methods, the status code returned is 500 instead of 405. For example, DELETE on /api/v1/authors
1. The version of the Ruby used (2.7) has reached the EOL, project should be upgraded to latest version
1. Swagger documentation should return the list of APIs instead of README.md
1. An author can create multiple articles with same name at different time or multiple authors can create
   different articles with same name, we should generate a unique hash (title+content) while inserting a record in DB and can be checked everytime
1. From security point of view, we should allow only specific API methods, specifically those which we are exposing
