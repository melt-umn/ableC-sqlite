#include <sqlite.xh>
#include <stdio.h>

/* a more complex query */
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

  int min_age = 18;
  const char except_surname[] = "Adams";

  on db query {
    SELECT   age, gender, last_name AS surname
    FROM     person JOIN details
                      ON person.person_id = details.person_id
    WHERE    age >= ${min_age} AND surname <> ${except_surname}
    ORDER BY surname DESC
  } as selected_people;

  foreach (person : selected_people) {
    printf("%10s %2d %s\n", person.surname, person.age, person.gender);
  }

  finalize(selected_people);

  db_exit(db);

  return 0;
}

