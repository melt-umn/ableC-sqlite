grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:types;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables as tbls;
import edu:umn:cs:melt:ableC:abstractsyntax;
import edu:umn:cs:melt:ableC:abstractsyntax:env;
import edu:umn:cs:melt:ableC:abstractsyntax:overload;

abstract production sqliteDbTypeExpr
top::BaseTypeExpr ::= tables::[tbls:SqliteTable]
{
  top.typerep = sqliteDbType([], tables);

  forwards to
    typedefTypeExpr(
      [],
      name("_sqlite_db", location=builtIn())
    );
}

abstract production sqliteDbType
top::Type ::= qs::[Qualifier] tables::[tbls:SqliteTable]
{
  forwards to
    noncanonicalType(
      typedefType(
        qs,
        "_sqlite_db",
        pointerType(
          [],
          tagType(
            [],
            refIdTagType(
              structSEU(),
              "_sqlite_db_s",
              "edu:umn:cs:melt:exts:ableC:sqlite:_sqlite_db_s"
            )
          )
        )
      )
    );
}

abstract production sqliteQueryTypeExpr
top::BaseTypeExpr ::= columns::[abs:SqliteColumn]
{
  top.typerep = sqliteQueryType([], columns);

  forwards to
    typedefTypeExpr(
      [],
      name("_sqlite_query", location=builtIn())
    );
}

abstract production sqliteQueryType
top::Type ::= qs::[Qualifier] columns::[abs:SqliteColumn]
{
  forwards to
    noncanonicalType(
      typedefType(
        qs,
        "_sqlite_query",
        pointerType(
          [],
          tagType(
            [],
            refIdTagType(
              structSEU(),
              "_sqlite_query_s",
              "edu:umn:cs:melt:exts:ableC:sqlite:_sqlite_query_s"
            )
          )
        )
      )
    );
}

-- TODO: don't duplicate this
-- New location for expressions which don't have real locations
abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}

