#include <sqlite.xh>
#include <stdio.h>

/* bugs */
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

  on db query {
    // person_id is ambiguous, this should be an error but is not
    SELECT person_id
    FROM   person JOIN details
                    ON person.person_id = details.person_id
  } as person_ids;

  // there are no results
  foreach (person : person_ids) {
    printf("%d\n", person.person_id);
  }

  finalize(person_ids);

  on db query {
    // this will select person.person_id and details.person_id but the foreach
    //  loop will have no way to disambiguate the two
    SELECT *
    FROM   person JOIN details
                    ON person.person_id = details.person_id
  } as people;

  // this will declare person_id twice
  foreach (person : people) {
    printf("%s\n", person.first_name);
  }

  finalize(people);

  db_exit(db);

  return 0;
}

