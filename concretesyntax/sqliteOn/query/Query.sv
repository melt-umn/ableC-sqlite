grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:sqliteOn:query;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
import silver:langutil;

-- see https://www.sqlite.org/lang.html for grammar of SQLite queries

lexer class SqliteKeyword dominates cnc:Identifier_t;

terminal SqliteWith_t 'WITH' lexer classes {SqliteKeyword};
terminal SqliteRecursive_t 'RECURSIVE' lexer classes {SqliteKeyword};
terminal SqliteAs_t 'AS' lexer classes {SqliteKeyword};
terminal SqliteSelect_t 'SELECT' lexer classes {SqliteKeyword};
terminal SqliteDistinct_t 'DISTINCT' lexer classes {SqliteKeyword};
terminal SqliteAll_t 'ALL' lexer classes {SqliteKeyword};
terminal SqliteFrom_t 'FROM' lexer classes {SqliteKeyword};
terminal SqliteGroup_t 'GROUP' lexer classes {SqliteKeyword};
terminal SqliteBy_t 'BY' lexer classes {SqliteKeyword};
terminal SqliteHaving_t 'HAVING' lexer classes {SqliteKeyword};
terminal SqliteNatural_t 'NATURAL' lexer classes {SqliteKeyword};
terminal SqliteLeft_t 'LEFT' lexer classes {SqliteKeyword};
terminal SqliteOuter_t 'OUTER' lexer classes {SqliteKeyword};
terminal SqliteInner_t 'INNER' lexer classes {SqliteKeyword};
terminal SqliteCross_t 'CROSS' lexer classes {SqliteKeyword};
terminal SqliteJoin_t 'JOIN' lexer classes {SqliteKeyword};
terminal SqliteOnConstraint_t 'ON' lexer classes {SqliteKeyword};
terminal SqliteUsing_t 'USING' lexer classes {SqliteKeyword};
terminal SqliteWhere_t 'WHERE' lexer classes {SqliteKeyword};
terminal SqliteValues_t 'VALUES' lexer classes {SqliteKeyword};
terminal SqliteOrder_t 'ORDER' lexer classes {SqliteKeyword};
terminal SqliteAsc_t 'ASC' lexer classes {SqliteKeyword};
terminal SqliteDesc_t 'DESC' lexer classes {SqliteKeyword};
terminal SqliteLimit_t 'LIMIT' lexer classes {SqliteKeyword};
terminal SqliteOffset_t 'OFFSET' lexer classes {SqliteKeyword};
terminal SqliteNull_t 'NULL' lexer classes {SqliteKeyword};
terminal SqliteCurrentTime_t 'CURRENT_TIME' lexer classes {SqliteKeyword};
terminal SqliteCurrentDate_t 'CURRENT_DATE' lexer classes {SqliteKeyword};
terminal SqliteCurrentTimestamp_t 'CURRENT_TIMESTAMP' lexer classes {SqliteKeyword};
terminal SqliteCast_t 'CAST' lexer classes {SqliteKeyword};
terminal SqliteBetween_t 'BETWEEN' lexer classes {SqliteKeyword};
terminal SqliteInsert_t 'INSERT' lexer classes {SqliteKeyword};
terminal SqliteReplace_t 'REPLACE' lexer classes {SqliteKeyword};
terminal SqliteRollback_t 'ROLLBACK' lexer classes {SqliteKeyword};
terminal SqliteAbort_t 'ABORT' lexer classes {SqliteKeyword};
terminal SqliteFail_t 'FAIL' lexer classes {SqliteKeyword};
terminal SqliteIgnore_t 'IGNORE' lexer classes {SqliteKeyword};
terminal SqliteInto_t 'INTO' lexer classes {SqliteKeyword};
terminal SqliteDefault_t 'DEFAULT' lexer classes {SqliteKeyword};
terminal SqliteDelete_t 'DELETE' lexer classes {SqliteKeyword};
terminal SqliteIndexed_t 'INDEXED' lexer classes {SqliteKeyword};

--terminal SqliteDecimalLiteral_t /(([0-9]+(\.[0-9]+)?)|(\.[0-9]+))(E[+-]?[0-9]+)?/;
terminal SqliteDecimalLiteral_t /[0-9]+(\.[0-9]+)?/;
terminal SqliteHexLiteral_t /0x[0-9a-fA-f]+/;
terminal SqliteStringLiteral_t /'.*'/;
terminal SqliteBlobLiteral_t /[xX]'.*'/;

terminal SqliteCollate_t 'COLLATE' precedence = 8, association = left, lexer classes {SqliteKeyword};
terminal SqliteOr_t 'OR' precedence = 10, association = left, lexer classes {SqliteKeyword};
terminal SqliteAnd_t 'AND' precedence = 12, association = left, lexer classes {SqliteKeyword};
terminal SqliteEquals_t '=' precedence = 14, association = left;
terminal SqliteEquals2_t '==' precedence = 14, association = left;
terminal SqliteNotEqual_t '!=' precedence = 14, association = left;
terminal SqliteNotEqual2_t '<>' precedence = 14, association = left;
terminal SqliteIs_t 'IS' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteIn_t 'IN' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteLike_t 'LIKE' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteGlob_t 'GLOB' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteMatch_t 'MATCH' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteRegexp_t 'REGEXP' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteLt_t '<' precedence = 16, association = left;
terminal SqliteLe_t '<=' precedence = 16, association = left;
terminal SqliteGt_t '>' precedence = 16, association = left;
terminal SqliteGe_t '>=' precedence = 16, association = left;
terminal SqliteSl_t '<<' precedence = 18, association = left;
terminal SqliteSr_t '>>' precedence = 18, association = left;
terminal SqliteAndBit_t '&' precedence = 18, association = left;
terminal SqliteOrBit_t '|' precedence = 18, association = left;
terminal SqlitePlus_t '+' precedence = 20, association = left;
terminal SqliteMinus_t '-' precedence = 20, association = left;
terminal SqliteTimes_t '*' precedence = 22, association = left;
terminal SqliteDiv_t '/' precedence = 22, association = left;
terminal SqliteMod_t '%' precedence = 22, association = left;
terminal SqliteConcat_t '||' precedence = 24, association = left;
terminal SqliteUnaryMinus_t '-' precedence = 26;
terminal SqliteUnaryPlus_t '+' precedence = 26;
terminal SqliteUnaryCollate_t '~' precedence = 26;
terminal SqliteNot_t 'NOT' precedence = 26, lexer classes {SqliteKeyword};
terminal SqliteDollar_t '$' lexer classes {SqliteKeyword};

nonterminal SqliteQuery_c with location, ast<abs:SqliteQuery>;
concrete productions top::SqliteQuery_c
| s::SqliteSelectStmt_c
  {
    top.ast = abs:sqliteSelectQuery(s.ast, s.unparse);
  }
| i::SqliteInsertStmt_c
  {
    top.ast = abs:sqliteInsertQuery(i.ast, i.unparse);
  }
| d::SqliteDeleteStmt_c
  {
    top.ast = abs:sqliteDeleteQuery(d.ast, d.unparse);
  }

-- TODO: implement the full Select statement, this only supports Simple Select
nonterminal SqliteSelectStmt_c with location, ast<abs:SqliteSelectStmt>, unparse;
synthesized attribute unparse :: String;
concrete productions top::SqliteSelectStmt_c
| w::SqliteOptWith_c s::SqliteSelectCore_c o::SqliteOptOrder_c l::SqliteOptLimit_c
  {
    top.ast = abs:sqliteSelectStmt(w.ast, s.ast, o.ast, l.ast);
    top.unparse = w.unparse ++ s.unparse ++ o.unparse ++ l.unparse;
  }

nonterminal SqliteOptWith_c with location, ast<Maybe<abs:SqliteWith>>, unparse;
concrete productions top::SqliteOptWith_c
| w::SqliteWith_c
  {
    top.ast = just(w.ast);
    top.unparse = w.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteWith_c with location, ast<abs:SqliteWith>, unparse;
concrete productions top::SqliteWith_c
| SqliteWith_t r::SqliteOptRecursive_c cs::SqliteCommonTableExprList_c
  {
    top.ast = abs:sqliteWith(r.ast, cs.ast);
    top.unparse = r.unparse ++ "WITH " ++ cs.unparse;
  }

nonterminal SqliteOptRecursive_c with location, ast<Boolean>, unparse;
concrete productions top::SqliteOptRecursive_c
| SqliteRecursive_t
  {
    top.ast = true;
    top.unparse = "RECURSIVE ";
  }
|
  {
    top.ast = false;
    top.unparse = "";
  }

nonterminal SqliteCommonTableExprList_c with location, ast<abs:SqliteCommonTableExprList>, unparse;
concrete productions top::SqliteCommonTableExprList_c
| cs::SqliteCommonTableExprList_c ',' c::SqliteCommonTableExpr_c
  {
    top.ast = abs:sqliteCommonTableExprList(c.ast, cs.ast);
    top.unparse = cs.unparse ++ ", " ++ c.unparse;
  }
| c::SqliteCommonTableExpr_c
  {
    top.ast = abs:sqliteCommonTableExprList(c.ast, abs:sqliteNilCommonTableExprList());
    top.unparse = c.unparse;
  }

nonterminal SqliteCommonTableExpr_c with location, ast<abs:SqliteCommonTableExpr>, unparse;
concrete productions top::SqliteCommonTableExpr_c
| tableName::cnc:Identifier_t cs::SqliteOptColumnNameList_c SqliteAs_t '(' s::SqliteSelectStmt_c ')'
  {
    top.ast = abs:sqliteCommonTableExpr(abs:fromId(tableName), s.ast, cs.ast);
    top.unparse = tableName.lexeme ++ cs.unparse ++ " AS (" ++ s.unparse ++ ")";
  }

nonterminal SqliteSelectCore_c with location, ast<abs:SqliteSelectCore>, unparse;
concrete productions top::SqliteSelectCore_c
| s::SqliteSelect_c
  {
    top.ast = abs:sqliteSelectCoreSelect(s.ast);
    top.unparse = s.unparse;
  }
| v::SqliteValues_c
  {
    top.ast = abs:sqliteSelectCoreValues(v.ast);
    top.unparse = v.unparse;
  }

nonterminal SqliteSelect_c with location, ast<abs:SqliteSelect>, unparse;
concrete productions top::SqliteSelect_c
| SqliteSelect_t d::SqliteOptDistinctOrAll_c rs::SqliteResultColumnList_c f::SqliteOptFrom_c
      w::SqliteOptWhere_c g::SqliteOptGroup_c
  {
    top.ast = abs:sqliteSelect(d.ast, rs.ast, f.ast, w.ast, g.ast);
    top.unparse = "SELECT " ++ d.unparse ++ rs.unparse ++ f.unparse ++ w.unparse ++ g.unparse;
  }

nonterminal SqliteOptDistinctOrAll_c with location, ast<Maybe<abs:SqliteDistinctOrAll>>, unparse;
concrete productions top::SqliteOptDistinctOrAll_c
| SqliteDistinct_t
  {
    top.ast = just(abs:sqliteDistinct());
    top.unparse = "DISTINCT ";
  }
| SqliteAll_t
  {
    top.ast = just(abs:sqliteAll());
    top.unparse = "ALL ";
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteResultColumnList_c with location, ast<abs:SqliteResultColumnList>, unparse;
concrete productions top::SqliteResultColumnList_c
| rs::SqliteResultColumnList_c ',' r::SqliteResultColumn_c
  {
    top.ast = abs:sqliteResultColumnList(r.ast, rs.ast);
    top.unparse = rs.unparse ++ ", " ++ r.unparse;
  }
| r::SqliteResultColumn_c
  {
    top.ast = abs:sqliteResultColumnList(r.ast, abs:sqliteNilResultColumnList());
    top.unparse = r.unparse;
  }

nonterminal SqliteResultColumn_c with location, ast<abs:SqliteResultColumn>, unparse;
concrete productions top::SqliteResultColumn_c
| e::SqliteExpr_c c::SqliteOptAsColumnAlias_c
  {
    top.ast = abs:sqliteResultColumnExpr(e.ast, c.ast);
    top.unparse = e.unparse ++ c.unparse;
  }
| '*'
  {
    top.ast = abs:sqliteResultColumnStar();
    top.unparse = "*";
  }
| tableName::cnc:Identifier_t '.' '*'
  {
    top.ast = abs:sqliteResultColumnTableStar(abs:fromId(tableName));
    top.unparse = tableName.lexeme ++ ".*";
  }

nonterminal SqliteOptAsColumnAlias_c with location, ast<Maybe<abs:SqliteAsColumnAlias>>, unparse;
concrete productions top::SqliteOptAsColumnAlias_c
| a::SqliteAsColumnAlias_c
  {
    top.ast = just(a.ast);
    top.unparse = a.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteAsColumnAlias_c with location, ast<abs:SqliteAsColumnAlias>, unparse;
concrete productions top::SqliteAsColumnAlias_c
| a::SqliteOptAs_c columnAlias::cnc:Identifier_t
  {
    top.ast = abs:sqliteAsColumnAlias(abs:fromId(columnAlias));
    top.unparse = a.unparse ++ columnAlias.lexeme;
  }

nonterminal SqliteOptAs_c with location, unparse;
concrete productions top::SqliteOptAs_c
| SqliteAs_t
  {
    top.unparse = " AS ";
  }
|
  {
    top.unparse = "";
  }

nonterminal SqliteOptFrom_c with location, ast<Maybe<abs:SqliteFrom>>, unparse;
concrete productions top::SqliteOptFrom_c
| f::SqliteFrom_c
  {
    top.ast = just(f.ast);
    top.unparse = f.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteFrom_c with location, ast<abs:SqliteFrom>, unparse;
concrete productions top::SqliteFrom_c
| SqliteFrom_t t::SqliteTableOrSubqueryListOrJoin_c
  {
    top.ast = abs:sqliteFrom(t.ast);
    top.unparse = " FROM " ++ t.unparse;
  }

nonterminal SqliteTableOrSubqueryListOrJoin_c with location, ast<abs:SqliteTableOrSubqueryListOrJoin>, unparse;
concrete productions top::SqliteTableOrSubqueryListOrJoin_c
-- This seems to be ambiguous with SqliteJoinClause_c?
--| SqliteTableOrSubqueryList_c
--  {
--  }
| j::SqliteJoinClause_c
  {
    top.ast = abs:sqliteTableOrSubqueryListOrJoin(j.ast);
    top.unparse = j.unparse;
  }

--nonterminal SqliteTableOrSubqueryList_c with location;
--concrete productions top::SqliteTableOrSubqueryList_c
--| SqliteTableOrSubqueryList_c ',' SqliteTableOrSubquery_c
--  {
--  }
--| SqliteTableOrSubquery_c
--  {
--  }

-- TODO: complete
nonterminal SqliteTableOrSubquery_c with location, ast<abs:SqliteTableOrSubquery>, unparse;
concrete productions top::SqliteTableOrSubquery_c
| tableName::cnc:Identifier_t
  {
    top.ast = abs:sqliteTableOrSubquery(abs:fromId(tableName));
    top.unparse = tableName.lexeme;
  }

nonterminal SqliteJoinClause_c with location, ast<abs:SqliteJoinClause>, unparse;
concrete productions top::SqliteJoinClause_c
| t::SqliteTableOrSubquery_c j::SqliteOptJoinList_c
  {
    top.ast = abs:sqliteJoinClause(t.ast, j.ast);
    top.unparse = t.unparse ++ j.unparse;
  }

nonterminal SqliteOptJoinList_c with location, ast<Maybe<abs:SqliteJoinList>>, unparse;
concrete productions top::SqliteOptJoinList_c
| js::SqliteJoinList_c
  {
    top.ast = just(js.ast);
    top.unparse = js.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteJoinList_c with location, ast<abs:SqliteJoinList>, unparse;
concrete productions top::SqliteJoinList_c
| js::SqliteJoinList_c j::SqliteJoin_c
  {
    top.ast = abs:sqliteJoinList(j.ast, js.ast);
    top.unparse = js.unparse ++ j.unparse;
  }
| j::SqliteJoin_c
  {
    top.ast = abs:sqliteJoinList(j.ast, abs:sqliteNilJoinList());
    top.unparse = j.unparse;
  }

nonterminal SqliteJoin_c with location, ast<abs:SqliteJoin>, unparse;
concrete productions top::SqliteJoin_c
| o::SqliteJoinOperator_c t::SqliteTableOrSubquery_c c::SqliteJoinConstraint_c
  {
    top.ast = abs:sqliteJoin(o.ast, t.ast, c.ast);
    top.unparse = o.unparse ++ t.unparse ++ c.unparse;
  }

nonterminal SqliteJoinOperator_c with location, ast<abs:SqliteJoinOperator>, unparse;
concrete productions top::SqliteJoinOperator_c
| ','
  {
    top.ast = abs:sqliteJoinOperator(false, nothing());
    top.unparse = ", ";
  }
| n::SqliteOptNatural_c l::SqliteOptLeftOrInnerOrCross_c j::SqliteJoin_t
  {
    top.ast = abs:sqliteJoinOperator(n.ast, l.ast);
    top.unparse = n.unparse ++ l.unparse ++ " JOIN ";
  }

nonterminal SqliteOptNatural_c with location, ast<Boolean>, unparse;
concrete productions top::SqliteOptNatural_c
| SqliteNatural_t
  {
    top.ast = true;
    top.unparse = " NATURAL";
  }
|
  {
    top.ast = false;
    top.unparse = "";
  }

nonterminal SqliteOptLeftOrInnerOrCross_c with location, ast<Maybe<abs:SqliteLeftOrInnerOrCross>>, unparse;
concrete productions top::SqliteOptLeftOrInnerOrCross_c
| SqliteLeft_t o::SqliteOptOuter_c
  {
    top.ast = just(abs:sqliteLeft(o.ast));
    top.unparse = " LEFT" ++ o.unparse;
  }
| SqliteInner_t
  {
    top.ast = just(abs:sqliteInner());
    top.unparse = " INNER";
  }
| SqliteCross_t
  {
    top.ast = just(abs:sqliteCross());
    top.unparse = " CROSS";
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteOptOuter_c with location, ast<Boolean>, unparse;
concrete productions top::SqliteOptOuter_c
| SqliteOuter_t
  {
    top.ast = true;
    top.unparse = " OUTER";
  }
|
  {
    top.ast = false;
    top.unparse = "";
  }

nonterminal SqliteJoinConstraint_c with location, ast<Maybe<abs:SqliteJoinConstraint>>, unparse;
concrete productions top::SqliteJoinConstraint_c
| SqliteOnConstraint_t e::SqliteExpr_c
  {
    top.ast = just(abs:sqliteOnConstraint(e.ast));
    top.unparse = " ON " ++ e.unparse;
  }
| SqliteUsing_t '(' cs::SqliteColumnNameList_c ')'
  {
    top.ast = just(abs:sqliteUsingConstraint(cs.ast));
    top.unparse = "(" ++ cs.unparse ++ ")";
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteOptWhere_c with location, ast<Maybe<abs:SqliteWhere>>, unparse;
concrete productions top::SqliteOptWhere_c
| w::SqliteWhere_c
  {
    top.ast = just(w.ast);
    top.unparse = w.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteWhere_c with location, ast<abs:SqliteWhere>, unparse;
concrete productions top::SqliteWhere_c
| SqliteWhere_t e::SqliteExpr_c
  {
    top.ast = abs:sqliteWhere(e.ast);
    top.unparse = " WHERE " ++ e.unparse;
  }

nonterminal SqliteOptGroup_c with location, ast<Maybe<abs:SqliteGroup>>, unparse;
concrete productions top::SqliteOptGroup_c
| g::SqliteGroup_c
  {
    top.ast = just(g.ast);
    top.unparse = g.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteGroup_c with location, ast<abs:SqliteGroup>, unparse;
concrete productions top::SqliteGroup_c
| SqliteGroup_t SqliteBy_t es::SqliteExprList_c h::SqliteOptHaving_c
  {
    top.ast = abs:sqliteGroup(es.ast, h.ast);
    top.unparse = "GROUP BY " ++ es.unparse ++ h.unparse;
  }

nonterminal SqliteOptHaving_c with location, ast<Maybe<abs:SqliteHaving>>, unparse;
concrete productions top::SqliteOptHaving_c
| h::SqliteHaving_c
  {
    top.ast = just(h.ast);
    top.unparse = h.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteHaving_c with location, ast<abs:SqliteHaving>, unparse;
concrete productions top::SqliteHaving_c
| SqliteHaving_t e::SqliteExpr_c
  {
    top.ast = abs:sqliteHaving(e.ast);
    top.unparse = " HAVING " ++ e.unparse;
  }

nonterminal SqliteValues_c with location, ast<abs:SqliteValues>, unparse;
concrete productions top::SqliteValues_c
| SqliteValues_t es::SqliteExprListList_c
  {
    top.ast = abs:sqliteValues(es.ast);
    top.unparse = " VALUES " ++ es.unparse;
  }

nonterminal SqliteExprListList_c with location, ast<abs:SqliteExprListList>, unparse;
concrete productions top::SqliteExprListList_c
| es::SqliteExprListList_c ',' '(' e::SqliteExprList_c ')'
  {
    top.ast = abs:sqliteExprListList(e.ast, es.ast);
    top.unparse = es.unparse ++ ", (" ++ e.unparse ++ ")";
  }
| '(' e::SqliteExprList_c ')'
  {
    top.ast = abs:sqliteExprListList(e.ast, abs:sqliteNilExprListList());
    top.unparse = "(" ++ e.unparse ++ ")";
  }

nonterminal SqliteExprList_c with location, ast<abs:SqliteExprList>, unparse;
concrete productions top::SqliteExprList_c
| es::SqliteExprList_c ',' e::SqliteExpr_c
  {
    top.ast = abs:sqliteExprList(e.ast, es.ast);
    top.unparse = es.unparse ++ ", " ++ e.unparse;
  }
| e::SqliteExpr_c
  {
    top.ast = abs:sqliteExprList(e.ast, abs:sqliteNilExprList());
    top.unparse = e.unparse;
  }

-- TODO: fully implement expressions
nonterminal SqliteExpr_c with location, ast<abs:SqliteExpr>, unparse;
concrete productions top::SqliteExpr_c
| l::SqliteLiteralValue_c
  {
    top.ast = abs:sqliteLiteralValueExpr();
    top.unparse = l.unparse;
  }
--| SqliteBindParameter_c
--  {
--  }
| n::SqliteSchemaTableColumnName_c
  {
    top.ast = abs:sqliteSchemaTableColumnNameExpr(n.ast);
    top.unparse = n.unparse;
  }
| e1::SqliteExpr_c SqliteOr_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " OR " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteAnd_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " AND " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteEquals_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " = " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteEquals2_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " == " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteNotEqual_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " != " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteNotEqual2_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " <> " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteIs_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " IS " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteIn_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " IN " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteLike_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " LIKE " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteGlob_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " GLOB " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteMatch_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " MATCH " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteRegexp_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " REGEXP " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteLt_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " < " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteLe_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " <= " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteGt_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " > " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteGe_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " >= " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteSl_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " << " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteSr_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " >> " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteAndBit_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " & " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteOrBit_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " | " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqlitePlus_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " + " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteMinus_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " - " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteTimes_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " * " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteDiv_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " / " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteMod_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " % " ++ e2.unparse;
  }
| e1::SqliteExpr_c SqliteConcat_t e2::SqliteExpr_c
  {
    top.ast = abs:sqliteBinaryExpr(e1.ast, e2.ast);
    top.unparse = e1.unparse ++ " || " ++ e2.unparse;
  }
| SqliteUnaryMinus_t e::SqliteExpr_c
  {
    top.ast = abs:sqliteUnaryExpr(e.ast);
    top.unparse = "-" ++ e.unparse;
  }
| SqliteUnaryPlus_t e::SqliteExpr_c
  {
    top.ast = abs:sqliteUnaryExpr(e.ast);
    top.unparse = "+" ++ e.unparse;
  }
| SqliteUnaryCollate_t e::SqliteExpr_c
  {
    top.ast = abs:sqliteUnaryExpr(e.ast);
    top.unparse = "~" ++ e.unparse;
  }
| SqliteNot_t e::SqliteExpr_c
  {
    top.ast = abs:sqliteUnaryExpr(e.ast);
    top.unparse = "NOT " ++ e.unparse;
  }
| functionName::cnc:Identifier_t '(' a::SqliteOptFunctionArgs_c ')'
  {
    top.ast = abs:sqliteFunctionCallExpr(abs:fromId(functionName), a.ast);
    top.unparse = functionName.lexeme ++ "(" ++ a.unparse ++ ")";
  }
| '(' e::SqliteExpr_c ')'
  {
    top.ast = e.ast;
    top.unparse = "(" ++ e.unparse ++ ")";
  }
--| SqliteCast_t '(' SqliteExpr_c SqliteAs_t SqliteTypeName_c ')'
--  {
--  }
--| SqliteExpr_c SqliteCollate_t collationName::cnc:Identifier_t
--  {
--  }
--| SqliteExpr_c SqliteOptNot_c SqliteLikeGlobRegExpOrMatch_c SqliteExpr_c SqliteOptEscapedExpr_c
--  {
--  }
--| SqliteExpr_c SqliteIsOrNotNull_c
--  {
--  }
--| SqliteExpr_c SqliteOptNot_c SqliteBetween_t SqliteExpr_c SqliteAnd_t SqliteExpr_c
--  {
--  }
--| SqliteExpr_c SqliteOptNot_c SqliteIn_t SqliteSelectOrExprOrSchemaTableName_c
--  {
--  }
--| SqliteOptOptNotExists_c '(' SqliteSelectStmt_c ')'
--  {
--  }
--| SqliteCase_t SqliteOptExpr_c SqliteWhenThenList_c SqliteOptElseExpr_c SqliteEnd_t
--  {
--  }
--| SqliteRaiseFunction_c
--  {
--  }
|  '$' '{' e::cnc:Expr_c '}'
  {
    top.ast = abs:sqliteCExpr(e.ast);
    top.unparse = "?";
  }

nonterminal SqliteSchemaTableColumnName_c with location, ast<abs:SqliteSchemaTableColumnName>, unparse;
concrete productions top::SqliteSchemaTableColumnName_c
| schemaName::cnc:Identifier_t '.' tableName::cnc:Identifier_t '.' columnName::cnc:Identifier_t
  {
    top.ast = abs:sqliteSchemaTableColumnName(abs:fromId(schemaName), abs:fromId(tableName), abs:fromId(columnName));
    top.unparse = schemaName.lexeme ++ "." ++ tableName.lexeme ++ "." ++ columnName.lexeme;
  }
| tableName::cnc:Identifier_t '.' columnName::cnc:Identifier_t
  {
    top.ast = abs:sqliteTableColumnName(abs:fromId(tableName), abs:fromId(columnName));
    top.unparse = tableName.lexeme ++ "." ++ columnName.lexeme;
  }
| columnName::cnc:Identifier_t
  {
    top.ast = abs:sqliteSColumnName(abs:fromId(columnName));
    top.unparse = columnName.lexeme;
  }

nonterminal SqliteLiteralValue_c with location, unparse;
concrete productions top::SqliteLiteralValue_c
| l::SqliteNumericLiteral_c
  {
    top.unparse = l.unparse;
  }
| l::SqliteStringLiteral_t
  {
    top.unparse = l.lexeme;
  }
| l::SqliteBlobLiteral_t
  {
    top.unparse = l.lexeme;
  }
| SqliteNull_t
  {
    top.unparse = "NULL";
  }
| SqliteCurrentTime_t
  {
    top.unparse = "CURRENT_TIME";
  }
| SqliteCurrentDate_t
  {
    top.unparse = "CURRENT_DATE";
  }
| SqliteCurrentTimestamp_t
  {
    top.unparse = "CURRENT_TIMESTAMP";
  }

nonterminal SqliteNumericLiteral_c with location, unparse;
concrete productions top::SqliteNumericLiteral_c
| l::SqliteDecimalLiteral_t
  {
    top.unparse = l.lexeme;
  }
| l::SqliteHexLiteral_t
  {
    top.unparse = l.lexeme;
  }

nonterminal SqliteOptFunctionArgs_c with location, ast<Maybe<abs:SqliteFunctionArgs>>, unparse;
concrete productions top::SqliteOptFunctionArgs_c
| d::SqliteOptDistinct_c es::SqliteExprList_c
  {
    top.ast = just(abs:sqliteFunctionArgs(d.ast, es.ast));
    top.unparse = d.unparse ++ es.unparse;
  }
| '*'
  {
    top.ast = just(abs:sqliteFunctionArgsStar());
    top.unparse = "*";
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteOptDistinct_c with location, ast<Boolean>, unparse;
concrete productions top::SqliteOptDistinct_c
| SqliteDistinct_t
  {
    top.ast = true;
    top.unparse = "DISTINCT ";
  }
|
  {
    top.ast = false;
    top.unparse = "";
  }

nonterminal SqliteOptColumnNameList_c with location, ast<Maybe<abs:SqliteColumnNameList>>, unparse;
concrete productions top::SqliteOptColumnNameList_c
| '(' cs::SqliteColumnNameList_c ')'
  {
    top.ast = just(cs.ast);
    top.unparse = "(" ++ cs.unparse ++ ")";
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteColumnNameList_c with location, ast<abs:SqliteColumnNameList>, unparse;
concrete productions top::SqliteColumnNameList_c
| cs::SqliteColumnNameList_c ',' c::cnc:Identifier_t
  {
    top.ast = abs:sqliteColumnNameList(abs:fromId(c), cs.ast);
    top.unparse = cs.unparse ++ ", " ++ c.lexeme;
  }
| c::cnc:Identifier_t
  {
    top.ast = abs:sqliteColumnNameList(abs:fromId(c), abs:sqliteNilColumnNameList());
    top.unparse = c.lexeme;
  }

nonterminal SqliteOptOrder_c with location, ast<Maybe<abs:SqliteOrder>>, unparse;
concrete productions top::SqliteOptOrder_c
| o::SqliteOrder_c
  {
    top.ast = just(o.ast);
    top.unparse = o.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteOrder_c with location, ast<abs:SqliteOrder>, unparse;
concrete productions top::SqliteOrder_c
| SqliteOrder_t SqliteBy_t os::SqliteOrderingTermList_c
  {
    top.ast = abs:sqliteOrder(os.ast);
    top.unparse = " ORDER BY " ++ os.unparse;
  }

nonterminal SqliteOrderingTermList_c with location, ast<abs:SqliteOrderingTermList>, unparse;
concrete productions top::SqliteOrderingTermList_c
| os::SqliteOrderingTermList_c ',' o::SqliteOrderingTerm_c
  {
    top.ast = abs:sqliteOrderingTermList(o.ast, os.ast);
    top.unparse = os.unparse ++ ", " ++ o.unparse;
  }
| o::SqliteOrderingTerm_c
  {
    top.ast = abs:sqliteOrderingTermList(o.ast, abs:sqliteNilOrderingTermList());
    top.unparse = o.unparse;
  }

nonterminal SqliteOrderingTerm_c with location, ast<abs:SqliteOrderingTerm>, unparse;
concrete productions top::SqliteOrderingTerm_c
| e::SqliteExpr_c c::SqliteOptCollate_c a::SqliteOptAscOrDesc_c
  {
    top.ast = abs:sqliteOrderingTerm(e.ast, c.ast);
    top.unparse = e.unparse ++ c.unparse ++ a.unparse;
  }

nonterminal SqliteOptCollate_c with location, ast<Maybe<abs:SqliteCollate>>, unparse;
concrete productions top::SqliteOptCollate_c
| c::SqliteCollate_c
  {
    top.ast = just(c.ast);
    top.unparse = c.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteCollate_c with location, ast<abs:SqliteCollate>, unparse;
concrete productions top::SqliteCollate_c
| SqliteCollate_t collationName::cnc:Identifier_t
  {
    top.ast = abs:sqliteCollate(abs:fromId(collationName));
    top.unparse = " COLLATE " ++ collationName.lexeme;
  }

nonterminal SqliteOptAscOrDesc_c with location, unparse;
concrete productions top::SqliteOptAscOrDesc_c
| a::SqliteAscOrDesc_c
  {
    top.unparse = a.unparse;
  }
|
  {
    top.unparse = "";
  }

nonterminal SqliteAscOrDesc_c with location, unparse;
concrete productions top::SqliteAscOrDesc_c
| SqliteAsc_t
  {
    top.unparse = " ASC";
  }
| SqliteDesc_t
  {
    top.unparse = " DESC";
  }

nonterminal SqliteOptLimit_c with location, ast<Maybe<abs:SqliteLimit>>, unparse;
concrete productions top::SqliteOptLimit_c
| l::SqliteLimit_c
  {
    top.ast = just(l.ast);
    top.unparse = l.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteLimit_c with location, ast<abs:SqliteLimit>, unparse;
concrete productions top::SqliteLimit_c
| SqliteLimit_t e::SqliteExpr_c o::SqliteOptOffsetExpr_c
  {
    top.ast = abs:sqliteLimit(e.ast, o.ast);
    top.unparse = " LIMIT " ++ e.unparse ++ o.unparse;
  }

nonterminal SqliteOptOffsetExpr_c with location, ast<Maybe<abs:SqliteOffsetExpr>>, unparse;
concrete productions top::SqliteOptOffsetExpr_c
| o::SqliteOffsetExpr_c
  {
    top.ast = just(o.ast);
    top.unparse = o.unparse;
  }
|
  {
    top.ast = nothing();
    top.unparse = "";
  }

nonterminal SqliteOffsetExpr_c with location, ast<abs:SqliteOffsetExpr>, unparse;
concrete productions top::SqliteOffsetExpr_c
| o::SqliteOffsetOrComma_c e::SqliteExpr_c
  {
    top.ast = abs:sqliteOffsetExpr(e.ast);
    top.unparse = o.unparse ++ e.unparse;
  }

nonterminal SqliteOffsetOrComma_c with location, unparse;
concrete productions top::SqliteOffsetOrComma_c
| SqliteOffset_t
  {
    top.unparse = " OFFSET ";
  }
| ','
  {
    top.unparse = ", ";
  }

nonterminal SqliteInsertStmt_c with location, ast<abs:SqliteInsertStmt>, unparse;
concrete productions top::SqliteInsertStmt_c
| w::SqliteOptWith_c i::SqliteInsertOrReplace_c SqliteInto_t
    s::SqliteSchemaTableName_c cs::SqliteOptColumnNameList_c
    v::SqliteValuesOrSelectOrDefault_c
  {
    top.ast = abs:sqliteInsertStmt(w.ast, s.ast, cs.ast, v.ast);
    top.unparse = w.unparse ++ i.unparse ++ " INTO " ++ s.unparse ++ cs.unparse ++ v.unparse;
  }

nonterminal SqliteInsertOrReplace_c with location, unparse;
concrete productions top::SqliteInsertOrReplace_c
| SqliteInsert_t
  {
    top.unparse = "INSERT";
  }
| SqliteReplace_t
  {
    top.unparse = "REPLACE";
  }
| SqliteInsert_t SqliteOr_t SqliteReplace_t
  {
    top.unparse = "INSERT OR REPLACE";
  }
| SqliteInsert_t SqliteOr_t SqliteRollback_t
  {
    top.unparse = "INSERT OR ROLLBACK";
  }
| SqliteInsert_t SqliteOr_t SqliteAbort_t
  {
    top.unparse = "INSERT OR ABORT";
  }
| SqliteInsert_t SqliteOr_t SqliteFail_t
  {
    top.unparse = "INSERT OR FAIL";
  }
| SqliteInsert_t SqliteOr_t SqliteIgnore_t
  {
    top.unparse = "INSERT OR IGNORE";
  }

nonterminal SqliteSchemaTableName_c with location, ast<abs:SqliteSchemaTableName>, unparse;
concrete productions top::SqliteSchemaTableName_c
| schemaName::cnc:Identifier_t '.' tableName::cnc:Identifier_t
  {
    top.ast = abs:sqliteSchemaTableName(abs:fromId(schemaName), abs:fromId(tableName));
    top.unparse = schemaName.lexeme ++ "." ++ tableName.lexeme;
  }
| tableName::cnc:Identifier_t
  {
    top.ast = abs:sqliteTableName(abs:fromId(tableName));
    top.unparse = tableName.lexeme;
  }

nonterminal SqliteValuesOrSelectOrDefault_c with location, ast<abs:SqliteValues>, unparse;
concrete productions top::SqliteValuesOrSelectOrDefault_c
-- This is ambiguous because SqliteSelectStmt_c can just be SqliteValues_c?
--| v::SqliteValues_c
--  {
--    top.ast = v.ast;
--    top.unparse = v.unparse;
--  }
| s::SqliteSelectStmt_c
  {
    top.ast = abs:sqliteSelectValues(s.ast);
    top.unparse = s.unparse;
  }
| SqliteDefault_t SqliteValues_t
  {
    top.ast = abs:sqliteDefaultValues();
    top.unparse = " DEFAULT VALUES";
  }

nonterminal SqliteDeleteStmt_c with location, ast<abs:SqliteDeleteStmt>, unparse;
concrete productions top::SqliteDeleteStmt_c
| w::SqliteOptWith_c SqliteDelete_t SqliteFrom_t t::SqliteQualifiedTableName_c
    wh::SqliteOptWhere_c
  {
    top.ast = abs:sqliteDeleteStmt(w.ast, t.ast, wh.ast);
    top.unparse = w.unparse ++ "DELETE FROM " ++ t.unparse ++ wh.unparse;
  }

nonterminal SqliteQualifiedTableName_c with location, ast<abs:SqliteSchemaTableName>, unparse;
concrete productions top::SqliteQualifiedTableName_c
| s::SqliteSchemaTableName_c i::SqliteOptIndexed_c
  {
    top.ast = s.ast;
    top.unparse = s.unparse ++ i.unparse;
  }

nonterminal SqliteOptIndexed_c with location, unparse;
concrete productions top::SqliteOptIndexed_c
| SqliteIndexed_t SqliteBy_t indexName::cnc:Identifier_t
  {
    top.unparse = " INDEXED BY " ++ indexName.lexeme;
  }
| SqliteNot_t SqliteIndexed_t
  {
    top.unparse = " NOT INDEXED";
  }
|
  {
    top.unparse = "";
  }

