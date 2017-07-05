grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:foreach;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
import silver:langutil;

marking terminal SqliteForeach_t 'foreach' lexer classes {Ckeyword};

concrete production sqliteForeach_c
top::cnc:Stmt_c ::= 'foreach' '(' row::cnc:Identifier_t ':'
                           stmt::cnc:Expr_c ')' body::cnc:Stmt_c
{
  top.ast = abs:sqliteForeach(abs:fromId(row), stmt.ast, body.ast);
}

