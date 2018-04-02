#include <sqlite.xh>
#include <stdio.h>

/* select error */
int main(void)
{
  use "test.db" with {
    table person  ( person_id  INTEGER,
                    first_name VARCHAR,
                    last_name  VARCHAR ),
    table details ( person_id  INTEGER,
                    age        INTEGER,
                    gender     VARCHAR )
  } as db;

  // table `foo' does not exist
  on db query {
    SELECT * FROM foo
  } as foos;

  // column `bar' does not exist
  on db query {
    SELECT bar FROM person
  } as bars;

  // column `age' does not exist in table `person' even though `age' is
  //  available in the results
  on db query {
    SELECT person.age
    FROM   person JOIN details
                    ON person.person_id = details.person_id
  } as no_ages;

  db_exit(db);

  return 0;
}

