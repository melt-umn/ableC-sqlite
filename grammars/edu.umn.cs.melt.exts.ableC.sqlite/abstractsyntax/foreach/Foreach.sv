grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:foreach;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;
imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports silver:langutil;
imports silver:langutil:pp;

abstract production sqliteForeach
top::Stmt ::= row::Name query::Expr body::Stmt
{
  top.pp = ppConcat([
    row.pp, space(), query.pp, text("{"), line(), nestlines(2, body.pp), text("}")
  ]);
  top.functionDefs := body.functionDefs;
  top.labelDefs := body.labelDefs;

  local localErrors :: [Message] =
    case query.typerep of
      abs:sqliteQueryType(_, _) -> []
    | errorType()               -> []
    | _ -> [errFromOrigin(query, "expected _sqlite_query type in foreach loop")]
    end;

  local columns :: [SqliteColumn] =
    case query.typerep of
      abs:sqliteQueryType(_, cs) -> cs
    | _ -> []
    end;

  {-- want to forward to:
    sqlite3_reset(${query}.query);
    while (sqlite3_step(${query}.query) == SQLITE_ROW) {
      struct {
        <column declarations>;
      } ${row};
      <column initializations>;
      ${body};
    }
  -}

  -- sqlite3_reset(${query}.query)
  local callReset :: Expr =
    directCallExpr(
      name("sqlite3_reset"),
      consExpr(memberExpr(@query, true, name("query")), nilExpr())
    );

  -- sqlite3_step(${query}.query)
  local callStep :: Expr =
    directCallExpr(
      name("sqlite3_step"),
      consExpr(memberExpr(^query, true, name("query")), nilExpr())
    );

  -- SQLITE_ROW
  local sqliteRow :: Expr =
    -- TODO: don't hardcode value
    mkIntConst(100);
--    declRefExpr(
--      name("SQLITE_ROW"),
--      location=abs:builtin
--    );

  -- sqlite3_step(${query}.query) == SQLITE_ROW
  local hasRow :: Expr = equalsExpr(@callStep, @sqliteRow);

  -- for example: const unsigned char *name; int age;
  local columnDecls :: StructItemList = makeColumnDecls(columns);

  -- struct { <column declarations> }
  local rowTypeExpr :: BaseTypeExpr =
    structTypeExpr(
      foldQualifier([constQualifier()]),
      structDecl(
        nilAttribute(),
        nothingName(),
        @columnDecls
      )
    );

  {- for example:
      { sqlite3_column_text(${query}.query, 0),
        sqlite3_column_int(${query}.query, 1) }
  -}
  local rowInit :: Initializer =
    objectInitializer(
      makeRowInit(
        columns,
        memberExpr(^query, true, name("query"))
      )
    );
  -- struct { <column declarations> } ${row} = { <column initializations> } ;
  local rowDecl :: Stmt =
    declStmt(
      variableDecls(
        nilStorageClass(),
        nilAttribute(),
        @rowTypeExpr,
        consDeclarator(
          declarator(
            @row,
            baseTypeExpr(),
            nilAttribute(),
            justInitializer(@rowInit)
          ),
          nilDeclarator()
        )
      )
    );

  local whileHasRow :: Stmt =
    whileStmt(
      mkErrorCheck(localErrors, @hasRow),
      seqStmt(
        @rowDecl,
        @body
      )
    );

  local fullStmt :: Stmt =
    seqStmt(
      exprStmt(@callReset),
      @whileHasRow
    );

  forwards to @fullStmt;
}

function makeColumnDecls
StructItemList ::= columns::[SqliteColumn]
{
  return
    if null(columns)
      then nilStructItem()
      else consStructItem(
        makeColumnDecl(head(columns)),
        makeColumnDecls(tail(columns))
      )
    ;
}

function makeColumnDecl
StructItem ::= col::SqliteColumn
{
  local typeExpr :: BaseTypeExpr =
    case col.typ of
      sqliteVarchar() ->
        directTypeExpr(builtinType(foldQualifier([constQualifier()]), unsignedType(charType())))
    | sqliteInteger() ->
        directTypeExpr(builtinType(nilQualifier(), signedType(intType())))
    end;
  local mod :: TypeModifierExpr =
    case col.typ of
      sqliteVarchar() -> pointerTypeExpr(nilQualifier(), baseTypeExpr())
    | sqliteInteger() -> baseTypeExpr()
    end;

  return
      structItem(
        nilAttribute(),
        ^typeExpr,
        foldStructDeclarator([
          structField(col.columnName, ^mod, nilAttribute())
        ])
      );
}

function makeRowInit
InitList ::= columns::[SqliteColumn] query::Expr
{
  return makeRowInitHelper(columns, ^query, 0);
}

function makeRowInitHelper
InitList ::= columns::[SqliteColumn] query::Expr colIndex::Integer
{
  return
    if null(columns) then nilInit()
    else
      consInit(
        makeColumnInit(head(columns), ^query, colIndex),
        makeRowInitHelper(tail(columns), ^query, colIndex+1)
      );
}

function makeColumnInit
Init ::= col::SqliteColumn query::Expr colIndex::Integer
{
  local f :: String =
    case col.typ of
      sqliteVarchar() -> "sqlite3_column_text"
    | sqliteInteger() -> "sqlite3_column_int"
    end;

  return
    positionalInit(
      exprInitializer(
        directCallExpr(
          name(f),
          foldExpr([
            ^query,
            mkIntConst(colIndex)
          ])
        )
      )
    );
}

