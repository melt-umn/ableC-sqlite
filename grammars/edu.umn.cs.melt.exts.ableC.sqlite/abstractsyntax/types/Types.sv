grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:types;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables as tbls;
import edu:umn:cs:melt:ableC:abstractsyntax:host;
import edu:umn:cs:melt:ableC:abstractsyntax:env;
import edu:umn:cs:melt:ableC:abstractsyntax:overloadable;

abstract production sqliteDbTypeExpr
top::BaseTypeExpr ::= tables::[tbls:SqliteTable]
{
  top.typerep = sqliteDbType(nilQualifier(), tables);

  forwards to
    typedefTypeExpr(
      nilQualifier(),
      name("_sqlite_db", location=abs:builtin)
    );
}

abstract production sqliteDbType
top::Type ::= qs::Qualifiers tables::[tbls:SqliteTable]
{
  forwards to
    noncanonicalType(
      typedefType(
        qs,
        "_sqlite_db",
        pointerType(
          nilQualifier(),
          extType(
            nilQualifier(),
            refIdExtType(
              structSEU(),
              just("_sqlite_db_s"),
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
  top.typerep = sqliteQueryType(nilQualifier(), columns);

  forwards to
    typedefTypeExpr(
      nilQualifier(),
      name("_sqlite_query", location=abs:builtin)
    );
}

abstract production sqliteQueryType
top::Type ::= qs::Qualifiers columns::[abs:SqliteColumn]
{
  forwards to
    noncanonicalType(
      typedefType(
        qs,
        "_sqlite_query",
        pointerType(
          nilQualifier(),
          extType(
            nilQualifier(),
            refIdExtType(
              structSEU(),
              just("_sqlite_query_s"),
              "edu:umn:cs:melt:exts:ableC:sqlite:_sqlite_query_s"
            )
          )
        )
      )
    );
}
