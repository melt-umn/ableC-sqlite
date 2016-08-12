grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn:query;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports silver:langutil;

nonterminal SqliteQuery with queryStr, usedTables, usedColumns, selectedTables, resultColumns, exprParams, modTables;
synthesized attribute queryStr :: String;
synthesized attribute usedTables :: [Name];
synthesized attribute usedColumns :: [SqliteResultColumnName];
synthesized attribute selectedTables :: [Name];
synthesized attribute resultColumns :: [SqliteResultColumnName];
synthesized attribute exprParams :: [Expr];
synthesized attribute modTables :: [Name];
abstract production sqliteSelectQuery
top::SqliteQuery ::= s::SqliteSelectStmt queryStr::String
{
  top.queryStr = queryStr;
  top.usedTables = s.usedTables;
  top.usedColumns = s.usedColumns;
  top.selectedTables = s.selectedTables;
  top.resultColumns = s.resultColumns;
  top.exprParams = s.exprParams;
  top.modTables = [];
}
abstract production sqliteInsertQuery
top::SqliteQuery ::= i::SqliteInsertStmt queryStr::String
{
  top.queryStr = queryStr;
  top.usedTables = i.usedTables;
  top.usedColumns = i.usedColumns;
  top.selectedTables = i.selectedTables;
  top.resultColumns = [];
  top.exprParams = i.exprParams;
  top.modTables = [i.modTable];
}
abstract production sqliteDeleteQuery
top::SqliteQuery ::= d::SqliteDeleteStmt queryStr::String
{
  top.queryStr = queryStr;
  top.usedTables = d.usedTables;
  top.usedColumns = d.usedColumns;
  top.selectedTables = d.selectedTables;
  top.resultColumns = [];
  top.exprParams = d.exprParams;
  -- modified table will be in selectedTables because Where clause might
  --   reference it
  top.modTables = [];
}

nonterminal SqliteSelectStmt with usedTables, usedColumns, selectedTables, resultColumns, exprParams;
abstract production sqliteSelectStmt
top::SqliteSelectStmt ::= mw::Maybe<SqliteWith> s::SqliteSelectCore mo::Maybe<SqliteOrder> ml::Maybe<SqliteLimit>
{
  local attribute wtables :: [Name] =
    case mw of just(w) -> w.usedTables | nothing() -> [] end;
  local attribute otables :: [Name] =
    case mo of just(o) -> o.usedTables | nothing() -> [] end;
  local attribute ltables :: [Name] =
    case ml of just(l) -> l.usedTables | nothing() -> [] end;
  local attribute wcolumns :: [SqliteResultColumnName] =
    case mw of just(w) -> w.usedColumns | nothing() -> [] end;
  local attribute ocolumns :: [SqliteResultColumnName] =
    case mo of just(o) -> o.usedColumns | nothing() -> [] end;
  local attribute lcolumns :: [SqliteResultColumnName] =
    case ml of just(l) -> l.usedColumns | nothing() -> [] end;
  local attribute wExprParams :: [Expr] =
    case mw of just(w) -> w.exprParams | nothing() -> [] end;
  local attribute oExprParams :: [Expr] =
    case mo of just(o) -> o.exprParams | nothing() -> [] end;
  local attribute lExprParams :: [Expr] =
    case ml of just(l) -> l.exprParams | nothing() -> [] end;

  top.usedTables = wtables ++ s.usedTables ++ otables ++ ltables;
  top.usedColumns = wcolumns ++ s.usedColumns ++ ocolumns ++ lcolumns;
  top.selectedTables = s.selectedTables;
  top.resultColumns = s.resultColumns;
  top.exprParams = wExprParams ++ s.exprParams ++ oExprParams ++ lExprParams;
}

nonterminal SqliteWith with usedTables, usedColumns, exprParams;
abstract production sqliteWith
top::SqliteWith ::= isRecursive::Boolean cs::SqliteCommonTableExprList
{
  top.usedTables = cs.usedTables;
  top.usedColumns = cs.usedColumns;
  top.exprParams = cs.exprParams;
}

nonterminal SqliteCommonTableExprList with usedTables, usedColumns, exprParams;
abstract production sqliteCommonTableExprList
top::SqliteCommonTableExprList ::= c::SqliteCommonTableExpr cs::SqliteCommonTableExprList
{
  top.usedTables = cs.usedTables ++ c.usedTables;
  top.usedColumns = cs.usedColumns ++ c.usedColumns;
  top.exprParams = cs.exprParams ++ c.exprParams;
}
abstract production sqliteNilCommonTableExprList
top::SqliteCommonTableExprList ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [];
}

nonterminal SqliteCommonTableExpr with usedTables, usedColumns, exprParams;
abstract production sqliteCommonTableExpr
top::SqliteCommonTableExpr ::= tableName::Name s::SqliteSelectStmt mcs::Maybe<SqliteColumnNameList>
{
  top.usedTables = cons(tableName, s.usedTables);
  top.usedColumns =
    case mcs of
      just(cs) -> s.usedColumns ++ cs.usedColumns
    | nothing() -> s.usedColumns
    end;
  top.exprParams = s.exprParams;
}

nonterminal SqliteSelectCore with usedTables, usedColumns, selectedTables, resultColumns, exprParams;
abstract production sqliteSelectCoreSelect
top::SqliteSelectCore ::= s::SqliteSelect
{
  top.usedTables = s.usedTables;
  top.usedColumns = s.usedColumns;
  top.selectedTables = s.selectedTables;
  top.resultColumns = s.resultColumns;
  top.exprParams = s.exprParams;
}
abstract production sqliteSelectCoreValues
top::SqliteSelectCore ::= v::SqliteValues
{
  top.usedTables = v.usedTables;
  top.usedColumns = v.usedColumns;
  top.selectedTables = v.selectedTables;
  top.resultColumns = v.resultColumns;
  top.exprParams = v.exprParams;
}

nonterminal SqliteSelect with usedTables, usedColumns, selectedTables, resultColumns, exprParams;
abstract production sqliteSelect
top::SqliteSelect ::= md::Maybe<SqliteDistinctOrAll> rs::SqliteResultColumnList mf::Maybe<SqliteFrom>
                      mw::Maybe<SqliteWhere> mg::Maybe<SqliteGroup>
{
  local attribute ftables :: [Name] =
    case mf of just(f) -> f.usedTables | nothing() -> [] end;
  local attribute wtables :: [Name] =
    case mw of just(w) -> w.usedTables | nothing() -> [] end;
  local attribute gtables :: [Name] =
    case mg of just(g) -> g.usedTables | nothing() -> [] end;
  local attribute fcolumns :: [SqliteResultColumnName] =
    case mf of just(f) -> f.usedColumns | nothing() -> [] end;
  local attribute wcolumns :: [SqliteResultColumnName] =
    case mw of just(w) -> w.usedColumns | nothing() -> [] end;
  local attribute gcolumns :: [SqliteResultColumnName] =
    case mg of just(g) -> g.usedColumns | nothing() -> [] end;
  local attribute fExprParams :: [Expr] =
    case mf of just(f) -> f.exprParams | nothing() -> [] end;
  local attribute wExprParams :: [Expr] =
    case mw of just(w) -> w.exprParams | nothing() -> [] end;
  local attribute gExprParams :: [Expr] =
    case mg of just(g) -> g.exprParams | nothing() -> [] end;

  top.usedTables = rs.usedTables ++ ftables ++ wtables ++ gtables;
  top.usedColumns = rs.usedColumns ++ fcolumns ++ wcolumns ++ gcolumns;
  top.selectedTables = ftables;
  top.resultColumns = rs.resultColumns;
  top.exprParams = rs.exprParams ++ fExprParams ++ wExprParams ++ gExprParams;
}

nonterminal SqliteDistinctOrAll;
abstract production sqliteDistinct
top::SqliteDistinctOrAll ::=
{
}
abstract production sqliteAll
top::SqliteDistinctOrAll ::=
{
}

nonterminal SqliteResultColumnList with usedTables, usedColumns, resultColumns, exprParams;
abstract production sqliteResultColumnList
top::SqliteResultColumnList ::= r::SqliteResultColumn rs::SqliteResultColumnList
{
  top.usedTables = rs.usedTables ++ r.usedTables;
  top.usedColumns = rs.usedColumns ++ r.usedColumns;
  top.resultColumns = cons(r.resultColumn, rs.resultColumns);
  top.exprParams = rs.exprParams ++ r.exprParams;
}
abstract production sqliteNilResultColumnList
top::SqliteResultColumnList ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.resultColumns = [];
  top.exprParams = [];
}

nonterminal SqliteResultColumn with usedTables, usedColumns, resultColumn, exprParams;
synthesized attribute resultColumn :: SqliteResultColumnName;
abstract production sqliteResultColumnExpr
top::SqliteResultColumn ::= e::SqliteExpr mc::Maybe<SqliteAsColumnAlias>
{
  local attribute colName :: Maybe<Name> =
    case e of
      sqliteSchemaTableColumnNameExpr(n) ->
        case n.colName of
          sqliteResultColumnName(mName, _, _) -> mName
        | sqliteResultColumnNameStar()        -> nothing()
        | sqliteResultColumnNameTableStar(_)  -> nothing()
        end
    | _                                  -> nothing()
    end;
  local attribute columnAlias :: Maybe<Name> =
    case mc of
      just(c)   -> just(c.columnAlias)
    | nothing() -> nothing()
  end;
  local attribute mTableName :: Maybe<Name> =
    case e of
      sqliteSchemaTableColumnNameExpr(n) ->
        case n.colName of
          sqliteResultColumnName(_, _, mTableName)   -> mTableName
        | sqliteResultColumnNameStar()               -> nothing()
        | sqliteResultColumnNameTableStar(tableName) -> just(tableName)
        end
    | _                                  -> nothing()
    end;

  top.usedTables = e.usedTables;
  top.usedColumns = e.usedColumns;
  top.resultColumn = sqliteResultColumnName(colName, columnAlias, mTableName);
  top.exprParams = e.exprParams;
}
abstract production sqliteResultColumnStar
top::SqliteResultColumn ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.resultColumn = sqliteResultColumnNameStar();
  top.exprParams = [];
}
abstract production sqliteResultColumnTableStar
top::SqliteResultColumn ::= tableName::Name
{
  top.usedTables = [tableName];
  top.usedColumns = [];
  top.resultColumn = sqliteResultColumnNameTableStar(tableName);
  top.exprParams = [];
}

nonterminal SqliteAsColumnAlias with columnAlias;
synthesized attribute columnAlias :: Name;
abstract production sqliteAsColumnAlias
top::SqliteAsColumnAlias ::= columnAlias::Name
{
  top.columnAlias = columnAlias;
}

nonterminal SqliteFrom with usedTables, usedColumns, exprParams;
abstract production sqliteFrom
top::SqliteFrom ::= t::SqliteTableOrSubqueryListOrJoin
{
  top.usedTables = t.usedTables;
  top.usedColumns = t.usedColumns;
  top.exprParams = t.exprParams;
}

nonterminal SqliteTableOrSubqueryListOrJoin with usedTables, usedColumns, exprParams;
abstract production sqliteTableOrSubqueryListOrJoin
top::SqliteTableOrSubqueryListOrJoin ::= j::SqliteJoinClause
{
  top.usedTables = j.usedTables;
  top.usedColumns = j.usedColumns;
  top.exprParams = j.exprParams;
}

nonterminal SqliteJoinClause with usedTables, usedColumns, exprParams;
abstract production sqliteJoinClause
top::SqliteJoinClause ::= t::SqliteTableOrSubquery mj::Maybe<SqliteJoinList>
{
  top.usedTables =
    case mj of
      just(j)   -> cons(t.table, j.usedTables)
    | nothing() -> [t.table]
    end;
  top.usedColumns = case mj of just(j) -> j.usedColumns | nothing() -> [] end;
  top.exprParams = case mj of just(j) -> j.exprParams | nothing() -> [] end;
}

nonterminal SqliteTableOrSubquery with table;
synthesized attribute table :: Name;
abstract production sqliteTableOrSubquery
top::SqliteTableOrSubquery ::= tableName::Name
{
  top.table = tableName;
}

nonterminal SqliteJoinList with usedTables, usedColumns, exprParams;
abstract production sqliteJoinList
top::SqliteJoinList ::= j::SqliteJoin js::SqliteJoinList
{
  top.usedTables = js.usedTables ++ j.usedTables;
  top.usedColumns = js.usedColumns ++ j.usedColumns;
  top.exprParams = js.exprParams ++ j.exprParams;
}

abstract production sqliteNilJoinList
top::SqliteJoinList ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [];
}

nonterminal SqliteJoin with usedTables, usedColumns, exprParams;
abstract production sqliteJoin
top::SqliteJoin ::= o::SqliteJoinOperator t::SqliteTableOrSubquery mc::Maybe<SqliteJoinConstraint>
{
  local attribute ctables :: [Name] =
    case mc of just(c) -> c.usedTables | nothing() -> [] end;

  top.usedTables = cons(t.table, ctables);
  top.usedColumns = case mc of just(c) -> c.usedColumns | nothing() -> [] end;
  top.exprParams = case mc of just(c) -> c.exprParams | nothing() -> [] end;
}

nonterminal SqliteJoinOperator;
abstract production sqliteJoinOperator
top::SqliteJoinOperator ::= isNatural::Boolean ml::Maybe<SqliteLeftOrInnerOrCross>
{
}

nonterminal SqliteLeftOrInnerOrCross;
abstract production sqliteLeft
top::SqliteLeftOrInnerOrCross ::= isOuter::Boolean
{
}
abstract production sqliteInner
top::SqliteLeftOrInnerOrCross ::=
{
}
abstract production sqliteCross
top::SqliteLeftOrInnerOrCross ::=
{
}

nonterminal SqliteJoinConstraint with usedTables, usedColumns, exprParams;
abstract production sqliteOnConstraint
top::SqliteJoinConstraint ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
  top.usedColumns = e.usedColumns;
  top.exprParams = e.exprParams;
}
abstract production sqliteUsingConstraint
top::SqliteJoinConstraint ::= cs::SqliteColumnNameList
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [];
}

nonterminal SqliteWhere with usedTables, usedColumns, exprParams;
abstract production sqliteWhere
top::SqliteWhere ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
  top.usedColumns = e.usedColumns;
  top.exprParams = e.exprParams;
}

nonterminal SqliteGroup with usedTables, usedColumns, exprParams;
abstract production sqliteGroup
top::SqliteGroup ::= es::SqliteExprList mh::Maybe<SqliteHaving>
{
  top.usedTables =
    case mh of
      just(h) -> es.usedTables ++ h.usedTables
    | nothing() -> es.usedTables
    end;
  top.usedColumns =
    case mh of
      just(h) -> es.usedColumns ++ h.usedColumns
    | nothing() -> es.usedColumns
    end;
  top.exprParams =
    case mh of
      just(h) -> es.exprParams ++ h.exprParams
    | nothing() -> es.exprParams
    end;
}

nonterminal SqliteHaving with usedTables, usedColumns, exprParams;
abstract production sqliteHaving
top::SqliteHaving ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
  top.usedColumns = e.usedColumns;
  top.exprParams = e.exprParams;
}

nonterminal SqliteValues with usedTables, usedColumns, selectedTables, resultColumns, exprParams;
abstract production sqliteValues
top::SqliteValues ::= es::SqliteExprListList
{
  top.usedTables = es.usedTables;
  top.usedColumns = es.usedColumns;
  top.exprParams = es.exprParams;
  top.selectedTables = [];
  top.resultColumns = [];
}
abstract production sqliteSelectValues
top::SqliteValues ::= s::SqliteSelectStmt
{
  top.usedTables = s.usedTables;
  top.usedColumns = s.usedColumns;
  top.exprParams = s.exprParams;
  top.selectedTables = s.selectedTables;
  top.resultColumns = s.resultColumns;
}
abstract production sqliteDefaultValues
top::SqliteValues ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [];
  top.selectedTables = [];
  top.resultColumns = [];
}

nonterminal SqliteExprListList with usedTables, usedColumns, exprParams;
abstract production sqliteExprListList
top::SqliteExprListList ::= e::SqliteExprList es::SqliteExprListList
{
  top.usedTables = es.usedTables ++ e.usedTables;
  top.usedColumns = es.usedColumns ++ e.usedColumns;
  top.exprParams = es.exprParams ++ e.exprParams;
}
abstract production sqliteNilExprListList
top::SqliteExprListList ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [];
}

nonterminal SqliteExprList with usedTables, usedColumns, exprParams;
abstract production sqliteExprList
top::SqliteExprList ::= e::SqliteExpr es::SqliteExprList
{
  top.usedTables = es.usedTables ++ e.usedTables;
  top.usedColumns = es.usedColumns ++ e.usedColumns;
  top.exprParams = es.exprParams ++ e.exprParams;
}
abstract production sqliteNilExprList
top::SqliteExprList ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [];
}

nonterminal SqliteExpr with usedTables, usedColumns, exprParams;
abstract production sqliteLiteralValueExpr
top::SqliteExpr ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [];
}
abstract production sqliteSchemaTableColumnNameExpr
top::SqliteExpr ::= n::SqliteSchemaTableColumnName
{
  top.usedTables =
    case n.colName of
      sqliteResultColumnName(_, _, mTableName) ->
        case mTableName of just(t) -> [t] | nothing() -> [] end
    | sqliteResultColumnNameStar() -> []
    | sqliteResultColumnNameTableStar(tableName) -> [tableName]
    end;
  top.usedColumns = [n.colName];
  top.exprParams = [];
}
abstract production sqliteBinaryExpr
top::SqliteExpr ::= e1::SqliteExpr e2::SqliteExpr
{
  top.usedTables = e1.usedTables ++ e2.usedTables;
  top.usedColumns = e1.usedColumns ++ e2.usedColumns;
  top.exprParams = e1.exprParams ++ e2.exprParams;
}
abstract production sqliteUnaryExpr
top::SqliteExpr ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
  top.usedColumns = e.usedColumns;
  top.exprParams = e.exprParams;
}
abstract production sqliteFunctionCallExpr
top::SqliteExpr ::= functionName::Name ma::Maybe<SqliteFunctionArgs>
{
  top.usedTables = case ma of just(a) -> a.usedTables | nothing() -> [] end;
  top.usedColumns = case ma of just(a) -> a.usedColumns | nothing() -> [] end;
  top.exprParams = case ma of just(a) -> a.exprParams | nothing() -> [] end;
}
abstract production sqliteCExpr
top::SqliteExpr ::= e::Expr
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [e];
}

nonterminal SqliteSchemaTableColumnName with colName;
synthesized attribute colName :: SqliteResultColumnName;
abstract production sqliteSchemaTableColumnName
top::SqliteSchemaTableColumnName ::= schemaName::Name tableName::Name colName::Name
{
  top.colName = sqliteResultColumnName(just(colName), nothing(), just(tableName));
}
abstract production sqliteTableColumnName
top::SqliteSchemaTableColumnName ::= tableName::Name colName::Name
{
  top.colName = sqliteResultColumnName(just(colName), nothing(), just(tableName));
}
abstract production sqliteSColumnName
top::SqliteSchemaTableColumnName ::= colName::Name
{
  top.colName = sqliteResultColumnName(just(colName), nothing(), nothing());
}

nonterminal SqliteFunctionArgs with usedTables, usedColumns, exprParams;
abstract production sqliteFunctionArgs
top::SqliteFunctionArgs ::= isDistinct::Boolean es::SqliteExprList
{
  top.usedTables = es.usedTables;
  top.usedColumns = es.usedColumns;
  top.exprParams = es.exprParams;
}
abstract production sqliteFunctionArgsStar
top::SqliteFunctionArgs ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [];
}

nonterminal SqliteColumnNameList with usedColumns;
abstract production sqliteColumnNameList
top::SqliteColumnNameList ::= c::Name cs::SqliteColumnNameList
{
  top.usedColumns =
    cons(
      sqliteResultColumnName(just(c), nothing(), nothing()),
      cs.usedColumns
    );
}
abstract production sqliteNilColumnNameList
top::SqliteColumnNameList ::=
{
  top.usedColumns = [];
}

nonterminal SqliteOrder with usedTables, usedColumns, exprParams;
abstract production sqliteOrder
top::SqliteOrder ::= os::SqliteOrderingTermList
{
  top.usedTables = os.usedTables;
  top.usedColumns = os.usedColumns;
  top.exprParams = os.exprParams;
}

nonterminal SqliteOrderingTermList with usedTables, usedColumns, exprParams;
abstract production sqliteOrderingTermList
top::SqliteOrderingTermList ::= o::SqliteOrderingTerm os::SqliteOrderingTermList
{
  top.usedTables = os.usedTables ++ o.usedTables;
  top.usedColumns = os.usedColumns ++ o.usedColumns;
  top.exprParams = os.exprParams ++ o.exprParams;
}
abstract production sqliteNilOrderingTermList
top::SqliteOrderingTermList ::=
{
  top.usedTables = [];
  top.usedColumns = [];
  top.exprParams = [];
}

nonterminal SqliteOrderingTerm with usedTables, usedColumns, exprParams;
abstract production sqliteOrderingTerm
top::SqliteOrderingTerm ::= e::SqliteExpr mc::Maybe<SqliteCollate>
{
  top.usedTables = e.usedTables;
  top.usedColumns = e.usedColumns;
  top.exprParams = e.exprParams;
}

nonterminal SqliteCollate;
abstract production sqliteCollate
top::SqliteCollate ::= collationName::Name
{
}

nonterminal SqliteLimit with usedTables, usedColumns, exprParams;
abstract production sqliteLimit
top::SqliteLimit ::= e::SqliteExpr mo::Maybe<SqliteOffsetExpr>
{
  top.usedTables =
    case mo of
      just(o) -> e.usedTables ++ o.usedTables
    | nothing() -> e.usedTables
    end;
  top.usedColumns =
    case mo of
      just(o) -> e.usedColumns ++ o.usedColumns
    | nothing() -> e.usedColumns
    end;
  top.exprParams =
    case mo of
      just(o) -> e.exprParams ++ o.exprParams
    | nothing() -> e.exprParams
    end;
}

nonterminal SqliteOffsetExpr with usedTables, usedColumns, exprParams;
abstract production sqliteOffsetExpr
top::SqliteOffsetExpr ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
  top.usedColumns = e.usedColumns;
  top.exprParams = e.exprParams;
}

nonterminal SqliteInsertStmt with usedTables, usedColumns, selectedTables, exprParams, modTable;
synthesized attribute modTable :: Name;
abstract production sqliteInsertStmt
top::SqliteInsertStmt ::= mw::Maybe<SqliteWith> s::SqliteSchemaTableName
                          mcs::Maybe<SqliteColumnNameList> v::SqliteValues
{
  local attribute wtables :: [Name] =
    case mw of just(w) -> w.usedTables | nothing() -> [] end;
  local attribute wcolumns :: [SqliteResultColumnName] =
    case mw of just(w) -> w.usedColumns | nothing() -> [] end;
  local attribute wExprParams :: [Expr] =
    case mw of just(w) -> w.exprParams | nothing() -> [] end;
  local attribute ccolumns :: [SqliteResultColumnName] =
    case mcs of just(cs) -> cs.usedColumns | nothing() -> [] end;
  top.usedTables = wtables ++ v.usedTables;
  top.usedColumns = wcolumns ++ ccolumns ++ v.usedColumns;
  top.selectedTables = v.selectedTables;
  top.exprParams = wExprParams ++ v.exprParams;
  top.modTable = s.tName;
}

nonterminal SqliteSchemaTableName with mSchemaName, tName;
synthesized attribute mSchemaName :: Maybe<Name>;
synthesized attribute tName :: Name;
abstract production sqliteSchemaTableName
top::SqliteSchemaTableName ::= schemaName::Name tableName::Name
{
  top.mSchemaName = just(schemaName);
  top.tName = tableName;
}
abstract production sqliteTableName
top::SqliteSchemaTableName ::= tableName::Name
{
  top.mSchemaName = nothing();
  top.tName = tableName;
}

nonterminal SqliteDeleteStmt with usedTables, usedColumns, selectedTables, exprParams;
abstract production sqliteDeleteStmt
top::SqliteDeleteStmt ::= mw::Maybe<SqliteWith> s::SqliteSchemaTableName
                          mwh::Maybe<SqliteWhere>
{
  local attribute wtables :: [Name] =
    case mw of just(w) -> w.usedTables | nothing() -> [] end;
  local attribute wcolumns :: [SqliteResultColumnName] =
    case mw of just(w) -> w.usedColumns | nothing() -> [] end;
  local attribute wExprParams :: [Expr] =
    case mw of just(w) -> w.exprParams | nothing() -> [] end;
  local attribute whtables :: [Name] =
    case mwh of just(wh) -> wh.usedTables | nothing() -> [] end;
  local attribute whcolumns :: [SqliteResultColumnName] =
    case mwh of just(wh) -> wh.usedColumns | nothing() -> [] end;
  local attribute whExprParams :: [Expr] =
    case mwh of just(wh) -> wh.exprParams | nothing() -> [] end;
  top.usedTables = wtables ++ [s.tName] ++ whtables;
  top.usedColumns = wcolumns ++ whcolumns;
  top.selectedTables = [s.tName];
  top.exprParams = wExprParams ++ whExprParams;
}

function checkTablesExist
[Message] ::= foundTables::[Name] expectedTables::[SqliteTable]
{
  local foundTable :: Name = head(foundTables);
  local localErrors :: [Message] =
    if tableExistsIn(expectedTables, foundTable) then []
    else [err(foundTable.location, "no such table: " ++ foundTable.name)];

  return if null(foundTables) then []
         else localErrors ++ checkTablesExist(tail(foundTables), expectedTables);
}

function tableExistsIn
Boolean ::= tables::[SqliteTable] table::Name
{
  return if null(tables) then false
         else (head(tables).tableName.name == table.name) || tableExistsIn(tail(tables), table);
}

function filterSelectedTables
[SqliteTable] ::= tables::[SqliteTable] selectedTables::[Name]
{
  local attribute table :: SqliteTable = head(tables);
  local attribute rest :: [SqliteTable] =
    filterSelectedTables(tail(tables), selectedTables);

  return if null(tables)
         then []
         else if containsTableName(table, selectedTables)
              then cons(table, rest)
              else rest;
}

function containsTableName
Boolean ::= t::SqliteTable names::[Name]
{
  return !null(names) &&
    (t.tableName.name == head(names).name || containsTableName(t, tail(names)));
}

-- TODO: also check if columns are ambiguous
function checkColumnsExist
[Message] ::= usedColumns::[SqliteResultColumnName] tables::[SqliteTable]
{
  local attribute unknownColumns :: [SqliteResultColumnName] =
    filterUnknownColumns(usedColumns, tables);
  return map(makeUnknownColumnError, unknownColumns);
}

function makeUnknownColumnError
Message ::= col::SqliteResultColumnName
{
  local attribute colName :: Name =
    case col of
      sqliteResultColumnName(mName, mAlias, _)   ->
        case mAlias of
          just(alias) -> alias
        | nothing()   -> case mName of
                           just(n)   -> n
                         | nothing() ->
                             error("selecting expressions as result column not supported yet")
                         end
        end
    -- FIXME: get the real * location
    | sqliteResultColumnNameStar()               -> name("*", location=builtIn())
    | sqliteResultColumnNameTableStar(tableName) -> name("*", location=tableName.location)
    end;
  local attribute mTableName :: Maybe<Name> =
    case col of
      sqliteResultColumnName(_, _, mTableName)   -> mTableName
    | sqliteResultColumnNameStar()               -> nothing()
    | sqliteResultColumnNameTableStar(tableName) -> just(tableName)
    end;
  local attribute fullName :: Name =
    case mTableName of
      just(tableName) -> name(tableName.name ++ "." ++ colName.name, location=tableName.location)
    | nothing()       -> colName
    end;
  return err(fullName.location, "no such column: " ++ fullName.name);
}

function filterUnknownColumns
[SqliteResultColumnName] ::= usedColumns::[SqliteResultColumnName] tables::[SqliteTable]
{
  local attribute col :: SqliteResultColumnName = head(usedColumns);
  local attribute rest :: [SqliteResultColumnName] =
    filterUnknownColumns(tail(usedColumns), tables);

  return if null(usedColumns)
         then []
         else if tablesContainColumn(tables, col)
              then rest
              else cons(col, rest);
}

function tablesContainColumn
Boolean ::= tables::[SqliteTable] col::SqliteResultColumnName
{
  local attribute nextTable :: SqliteTable = head(tables);
  local attribute mTableName :: Maybe<Name> =
    case col of
      sqliteResultColumnName(_, _, mTableName)   -> mTableName
    | sqliteResultColumnNameStar()               -> nothing()
    | sqliteResultColumnNameTableStar(tableName) -> just(tableName)
    end;
  local attribute doCheckNextTable :: Boolean =
    case mTableName of
      just(tableName) -> nextTable.tableName.name == tableName.name
    | nothing()       -> true
    end;
  return !null(tables) &&
    ((doCheckNextTable && containsColumn(head(tables).columns, col))
      || tablesContainColumn(tail(tables), col));
}

function containsColumn
Boolean ::= columns::[SqliteColumn] col::SqliteResultColumnName
{
  local attribute nameMatches :: Boolean =
    case col of
      sqliteResultColumnName(mName, mAlias, _) ->
        case mName of
          just(n)   -> head(columns).columnName.name == n.name
        | nothing() -> false
        end
    | sqliteResultColumnNameStar()             -> true
    | sqliteResultColumnNameTableStar(_)       -> true
    end;
  return !null(columns) &&
    (nameMatches || containsColumn(tail(columns), col));
}

function makeResultColumns
[SqliteColumn] ::= columnNames::[SqliteResultColumnName] tables::[SqliteTable]
{
  return reverse(makeResultColumnsHelper(expandColumnStars(columnNames, tables), tables));
}

function expandColumnStars
[SqliteResultColumnName] ::= columnNames::[SqliteResultColumnName] tables::[SqliteTable]
{
  local attribute nextColumnName :: SqliteResultColumnName =
    head(columnNames);
  local attribute rest :: [SqliteResultColumnName] =
    expandColumnStars(tail(columnNames), tables);
  return
    if null(columnNames) then []
    else
      case nextColumnName of
        sqliteResultColumnName(_, _, _)            ->
          cons(nextColumnName, rest)
      | sqliteResultColumnNameStar()               ->
          expandColumnStar(tables, nothing()) ++ rest
      | sqliteResultColumnNameTableStar(tableName) ->
          expandColumnStar(tables, just(tableName)) ++ rest
      end;
}

function expandColumnStar
[SqliteResultColumnName] ::= tables::[SqliteTable] mTableName::Maybe<Name>
{
  local attribute nextTable :: SqliteTable = head(tables);
  local attribute doExpandNextTable :: Boolean =
    case mTableName of
      just(tableName) -> nextTable.tableName.name == tableName.name
    | nothing()       -> true
    end;
  local attribute rest :: [SqliteResultColumnName] =
    expandColumnStar(tail(tables), mTableName);

  return
    if null(tables) then []
    else if doExpandNextTable
         then extractColumnNames(nextTable.columns, nextTable.tableName) ++ rest
         else rest;
}

function extractColumnNames
[SqliteResultColumnName] ::= columns::[SqliteColumn] tableName::Name
{
  return
    if null(columns) then []
    else
      cons(
        sqliteResultColumnName(
          just(head(columns).columnName), nothing(), just(tableName)
        ),
        extractColumnNames(tail(columns), tableName)
      );
}

function makeResultColumnsHelper
[SqliteColumn] ::= columnNames::[SqliteResultColumnName] tables::[SqliteTable]
{
  local attribute rest :: [SqliteColumn] =
    makeResultColumnsHelper(tail(columnNames), tables);
  return if null(columnNames) then []
         else
           case makeResultColumn(head(columnNames), tables) of
             just(c)   -> cons(c, rest)
           | nothing() -> rest
           end;
}

function makeResultColumn
Maybe<SqliteColumn> ::= columnName::SqliteResultColumnName tables::[SqliteTable]
{
  local attribute n :: Name =
    case columnName of
      sqliteResultColumnName(mName, alias, mTableName) ->
        case mName of
          just(n2)  -> n2
        | nothing() -> error("derefencing column name that does not exist")
        end
    | _                                                ->
        error("makeResultColumn() passed an unexpanded star")
    end;
  local attribute a :: Name =
    case columnName of
      sqliteResultColumnName(mName, alias, mTableName) ->
        case alias of
          just(a2)  -> a2
        | nothing() -> case mName of
                         just(n2)  -> n2
                       | nothing() -> error("derefencing column name that does not exist")
                       end
        end
    | _                                                ->
        error("makeResultColumn() passed an unexpanded star")
    end;
  local attribute mTableName :: Maybe<Name> =
    case columnName of
      sqliteResultColumnName(_, _, mTableName) -> mTableName
    | _                                        ->
        error("makeResultColumn() passed an unexpanded star")
    end;

  local attribute foundType :: Maybe<SqliteColumnType> =
    lookupColumnTypeInTables(n, tables, mTableName);

  return
    case foundType of
      just(t)   -> just(sqliteColumn(a, t))
    | nothing() -> nothing()
    end;
}

function lookupColumnTypeInTables
Maybe<SqliteColumnType> ::= n::Name tables::[SqliteTable] mTableName::Maybe<Name>
{
  local attribute nextTable :: SqliteTable = head(tables);
  local attribute doLookupNextTable :: Boolean =
    case mTableName of
      just(tableName) -> nextTable.tableName.name == tableName.name
    | nothing()       -> true
    end;
  local attribute rest :: Maybe<SqliteColumnType> =
    lookupColumnTypeInTables(n, tail(tables), mTableName);

  return
    if null(tables) then nothing()
    else if doLookupNextTable
         then case lookupColumnTypeInColumns(n, head(tables).columns) of
                just(t)   -> just(t)
              | nothing() -> rest
              end
         else rest;
}

function lookupColumnTypeInColumns
Maybe<SqliteColumnType> ::= n::Name columns::[SqliteColumn]
{
  local attribute nextColumn :: SqliteColumn = head(columns);

  return
    if null(columns) then nothing()
    else if n.name == nextColumn.columnName.name
         then just(nextColumn.typ)
         else lookupColumnTypeInColumns(n, tail(columns));
}

