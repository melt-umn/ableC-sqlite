#include <sqlite.xh>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* clear the database and repopulate it */

struct person_and_details_t {
  const char *first_name;
  const char *last_name;
  int age;
  const char *gender;
};

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

  on db commit { DELETE FROM person };
  on db commit { DELETE FROM details };

  srand(time(NULL));
  struct person_and_details_t c_people[] = {
    {"Aaron",    "Allen",       (rand() % 10), "M"},
    {"Abigail",  "Adams",  10 + (rand() % 10), "F"},
    {"Benjamin", "Brown",  20 + (rand() % 10), "M"},
    {"Belle",    "Bailey", 30 + (rand() % 10), "F"},
  };

  int i;
  for (i=0; i < sizeof(c_people) / sizeof(struct person_and_details_t); ++i) {
    on db commit {
      INSERT INTO person VALUES
        (${i}, ${c_people[i].first_name}, ${c_people[i].last_name})
    };

    on db commit {
      INSERT INTO details VALUES
        (${i}, ${c_people[i].age}, ${c_people[i].gender})
    };
  }

  on db query {
    SELECT person.person_id AS person_id, first_name, last_name, age, gender
    FROM   person JOIN details
                    ON person.person_id = details.person_id
  } as people;

  foreach (person : people) {
    printf("%d %10s %10s %2d %s\n", person.person_id, person.first_name,
        person.last_name, person.age, person.gender);
  }

  finalize(people);

  db_exit(db);

  return 0;
}

