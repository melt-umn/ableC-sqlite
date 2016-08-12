#include <sqlite.xh>
#include <stdio.h>

/* a simple query */
int main(void)
{
  use "test.db" with {
    table person  ( person_id  INTEGER,
                    first_name VARCHAR,
                    last_name  VARCHAR )
  } as db;

  on db query {
    SELECT * FROM person
  } as all_people;

  foreach (person : all_people) {
    printf("%d %10s %10s\n", person.person_id, person.last_name, person.first_name);
  }

  finalize(all_people);

  db_exit(db);

  return 0;
}

