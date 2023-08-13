grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax;

import silver:langutil;

import edu:umn:cs:melt:ableC:concretesyntax as host_cnc;
import edu:umn:cs:melt:ableC:abstractsyntax:host as host_abs;
import edu:umn:cs:melt:ableC:abstractsyntax:construction as host_abs;

import edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;

marking terminal SqliteOn_t 'on' lexer classes {host_cnc:Keyword, host_cnc:Global};
terminal SqliteCommit_t 'commit' lexer classes {host_cnc:Keyword};
terminal SqliteQuery_t 'query' lexer classes {host_cnc:Keyword};

concrete production sqliteQueryDb_c
top::host_cnc:Stmt_c ::= 'on' q::QueryBit_c
{
  top.ast = q.ast;
}

concrete production sqliteCommitDb_c
top::host_cnc:Expr_c ::= 'on' c::CommitBit_c
{
  top.ast = c.ast;
}

tracked nonterminal QueryBit_c with ast<host_abs:Stmt>, location ;

concrete production sqliteQueryBitStmt_c
top::QueryBit_c ::= '(' db::host_cnc:Expr_c ')' 'query' query::SqliteQueryBlock_c
                    'as' queryName::host_cnc:Identifier_t
{
  top.ast = abs:sqliteQueryDb(db.ast, query.ast, host_abs:fromId(queryName));
}

concrete production sqliteQueryIdDb_c
top::QueryBit_c ::= id::host_cnc:Identifier_t 'query' query::SqliteQueryBlock_c
                    'as' queryName::host_cnc:Identifier_t
{
  top.ast = abs:sqliteQueryDb(
              host_abs:declRefExpr(host_abs:fromId(id)),
	      query.ast, host_abs:fromId(queryName));
}

tracked nonterminal CommitBit_c with ast<host_abs:Expr>, location ;

concrete production sqliteCommitBitExpr_c
top::CommitBit_c ::= '(' db::host_cnc:Expr_c ')' 'commit' query::SqliteQueryBlock_c
{
  top.ast = abs:sqliteCommitDb(db.ast, query.ast);
}

concrete production sqliteCommitBitVar_c
top::CommitBit_c ::= id::host_cnc:Identifier_t 'commit' query::SqliteQueryBlock_c
{
  top.ast = abs:sqliteCommitDb(
              host_abs:declRefExpr(host_abs:fromId(id)),
              query.ast);
}


