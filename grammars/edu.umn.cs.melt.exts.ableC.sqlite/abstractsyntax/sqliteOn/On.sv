grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:foreach as foreach;
imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports silver:langutil;
imports silver:langutil:pp;

abstract production sqliteQueryDb
top::Stmt ::= db::Expr query::SqliteQuery queryName::Name
{
  -- TODO: add pp to query
  top.pp = ppConcat([
--    db.pp, space(), query.pp, space(), queryName.pp
    db.pp, space(), queryName.pp
  ]);
  propagate controlStmtContext;
  top.functionDefs := [];
  top.labelDefs := [];
  db.env = top.env;

  local dbTables :: [SqliteTable] =
    case db.typerep of
      abs:sqliteDbType(_, dbTables) -> dbTables
    | _                             -> []
    end;

  local selectedTables :: [SqliteTable] =
    filterSelectedTables(dbTables, query.selectedTables);

  local selectedTablesWithAliases :: [SqliteTable] =
    addAliasColumns(selectedTables, query.resultColumns);

  local usedTableErrors :: [Message] =
    case db.typerep of
      abs:sqliteDbType(_, _) ->
        checkTablesExist(query.usedTables, selectedTablesWithAliases)
    | errorType()            -> []
    | _                      -> [errFromOrigin(db, "expected _sqlite_db type")]
    end;

  local modTableErrors :: [Message] =
    case db.typerep of
      abs:sqliteDbType(_, _) ->
        checkTablesExist(query.modTables, dbTables)
    | errorType()            -> []
    | _                      -> [errFromOrigin(db, "expected _sqlite_db type")]
    end;

  local columnErrors :: [Message] =
    case db.typerep of
      abs:sqliteDbType(_, _) ->
        checkColumnsExist(query.usedColumns, selectedTablesWithAliases)
    | errorType()            -> []
    | _                      -> [errFromOrigin(db, "expected _sqlite_db type")]
    end;

  local localErrors :: [Message] =
    usedTableErrors ++ modTableErrors ++ columnErrors;

  local resultColumns :: [SqliteColumn] =
    makeResultColumns(query.resultColumns, selectedTables);

  {-- want to forward to:
    _sqlite_query ${queryName} = _new_sqlite_query();
    sqlite3_prepare(${db}.db, _query, sizeof(_query), &${queryName}.query, NULL);
    // for each expression parameter:
      sqlite3_bind_int(${queryName}, i, <expr>);
      OR
      sqlite3_bind_text(${queryName}, i, <expr>, -1, NULL);
  -}

  -- _new_sqlite_query();
  local callNew :: Expr =
    directCallExpr(
      name("_new_sqlite_query"),
      nilExpr()
    );

  -- _sqlite_query ${queryName} = _new_sqlite_query();
  local queryDecl :: Stmt =
    declStmt(
      variableDecls(
        nilStorageClass(),
        nilAttribute(),
        abs:sqliteQueryTypeExpr(resultColumns),
        foldDeclarator([
          declarator(
            ^queryName,
            baseTypeExpr(),
            nilAttribute(),
            justInitializer(exprInitializer(^callNew))
          )
        ])
      )
    );

  -- sqlite3_prepare(${db}.db, _query, sizeof(_query), &${queryName}.query, NULL);
  local callPrepare :: Expr =
    directCallExpr(
      name("sqlite3_prepare_v2"),
      foldExpr([
        memberExpr(^db, true, name("db")),
        stringLiteral(quote(query.queryStr)),
        mkIntConst(length(query.queryStr)+1),
        addressOfExpr(
          memberExpr(
            declRefExpr(^queryName),
            true,
            name("query")
          )
        ),
        mkIntConst(0)
      ])
    );

  forwards to seqStmt(
    @queryDecl,
    seqStmt(
      exprStmt(mkErrorCheck(localErrors, @callPrepare)),
      makeBinds(@query, @queryName)));
}

abstract production sqliteCommitDb
top::Expr ::= db::Expr query::SqliteQuery
{
  local queryName :: Name =
    name("_commit_stmt");

  local stepStmt :: Stmt =
    foreach:sqliteForeach(
      name("_insert_step"),
      declRefExpr(^queryName),
      nullStmt()
    );

  local callFinalize :: Expr =
    directCallExpr(
      name("finalize"),
      foldExpr([
        declRefExpr(^queryName)
      ])
    );

  forwards to
    stmtExpr(
      seqStmt(
        sqliteQueryDb(@db, @query, @queryName),
        @stepStmt
      ),
      @callFinalize
    );
}

abstract production makeBinds
top::Stmt ::= query::SqliteQuery queryName::Name
{
  forwards to makeBindsHelper(query.exprParams, @queryName, 1);
}

abstract production makeBindsHelper
top::Stmt ::= exprParams::[Expr] queryName::Name i::Integer
{
  {-- want to forward to:
    // for each expression parameter:
      sqlite3_bind_int(${queryName}, i, <expr>);
      OR
      sqlite3_bind_text(${queryName}, i, <expr>, -1, NULL);
  -}
  forwards to
    if   null(exprParams)
    then nullStmt()
    else seqStmt(
           exprStmt(
             makeBind(head(exprParams), @queryName, i)
           ),
           makeBindsHelper(tail(exprParams), @queryName, i+1)
         );
}

abstract production makeBind
top::Expr ::= exprParam::Expr queryName::Name i::Integer
{
  top.pp = ppImplode(space(), [exprParam.pp, queryName.pp, text(toString(i))]);
  propagate env, controlStmtContext;

  forwards to
    if isTextType(exprParam.typerep)
    then makeBindText(@exprParam, @queryName, i)
    else makeBindInt(@exprParam, @queryName, i);
}

function isTextType
Boolean ::= t::Type
{
  return
    case t of
      pointerType(_, builtinType(_, t2))     ->
        case t2 of
          signedType(charType())   -> true
        | unsignedType(charType()) -> true
        | _                        -> false
        end
    | arrayType(builtinType(_, t2), _, _, _) ->
        case t2 of
          signedType(charType())   -> true
        | unsignedType(charType()) -> true
        | _                        -> false
        end
    | _                                      ->
        false
    end;
}

abstract production makeBindText
top::Expr ::= exprParam::Expr queryName::Name i::Integer
{
  forwards to
    directCallExpr(
      name("sqlite3_bind_text"),
      foldExpr([
        memberExpr(
          declRefExpr(^queryName),
          true,
          name("query")
        ),
        mkIntConst(i),
        ^exprParam,
        mkIntConst(-1),
        mkIntConst(0)
      ])
    );
}

abstract production makeBindInt
top::Expr ::= exprParam::Expr queryName::Name i::Integer
{
  forwards to
    directCallExpr(
      name("sqlite3_bind_int"),
      foldExpr([
        memberExpr(
          declRefExpr(^queryName),
          true,
          name("query")
        ),
        mkIntConst(i),
        ^exprParam
      ])
    );
}

-- TODO: can this be used from ableC:abstractsyntax instead of copied?
function fromId
Name ::= n::cnc:Identifier_t
{
  return name(n.lexeme);
}

function quote
String ::= s::String
{
  return "\"" ++ s ++ "\"";
}

