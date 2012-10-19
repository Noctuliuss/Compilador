package analisador.lexico;

import ErrorMsg;
import java.io.InputStream;
import java_cup.runtime.Symbol;

%%

%implements Lexer
%function nextToken
%type Symbol
%char
%unicode
%notunix

%{
        private ErrorMsg errorMsg;
        private int commentDepth;
        private StringBuilder stringBuilder;

        private void newline() {
                errorMsg.newline(yychar);
        }

        private void err(int pos, String s) {
                errorMsg.error(pos, s);
        }

        private void err(String s) {
                err(yychar, s);
        }

        private Symbol tok(int kind, Object value) {
                return new Symbol(kind, yychar, yychar + yylength(), value);
        }

        Yylex(InputStream s, ErrorMsg e) {
                this(s);
                errorMsg = e;
        }
%}

%init{
        commentDepth = 0;
%init}

%eofval{
        if (commentDepth != 0) {
                err("Unclosed comments");
        }
        return tok(sym.EOF, null);
%eofval}

uppercase=[A-Z]
lowercase=[a-z]
letter={uppercase}|{lowercase}
digit=[0-9]
       
%state COMMENT, STRING, STRING_ESCAPE, STRING_IGNORE

%%

<YYINITIAL, COMMENT, STRING_IGNORE> \n|\r\n {
        newline();
}

<STRING> \n|\r\n {
        stringBuilder = null;
        err("Unclosed strings");
        yybegin(YYINITIAL);
        newline();
}

<STRING_ESCAPE> \n|\r\n {
        newline();
        yybegin(STRING_IGNORE);
}

<YYINITIAL> " "|\t|\f {}
<YYINITIAL> while { return tok(sym.WHILE, null); }
<YYINITIAL> for { return tok(sym.FOR, null); }
<YYINITIAL> to { return tok(sym.TO, null); }
<YYINITIAL> break { return tok(sym.BREAK, null); }
<YYINITIAL> let { return tok(sym.LET, null); }
<YYINITIAL> in { return tok(sym.IN, null); }
<YYINITIAL> end { return tok(sym.END, null); }
<YYINITIAL> function { return tok(sym.FUNCTION, null); }
<YYINITIAL> var { return tok(sym.VAR, null); }
<YYINITIAL> type { return tok(sym.TYPE, null); }
<YYINITIAL> array { return tok(sym.ARRAY, null); }
<YYINITIAL> if { return tok(sym.IF, null); }
<YYINITIAL> then { return tok(sym.THEN, null); }
<YYINITIAL> else { return tok(sym.ELSE, null); }
<YYINITIAL> do { return tok(sym.DO, null); }
<YYINITIAL> of { return tok(sym.OF, null); }
<YYINITIAL> nil { return tok(sym.NIL, null); }
<YYINITIAL> "," { return tok(sym.COMMA, null); }
<YYINITIAL> ":" { return tok(sym.COLON, null); }
<YYINITIAL> ";" { return tok(sym.SEMICOLON, null); }
<YYINITIAL> "(" { return tok(sym.LPAREN, null); }
<YYINITIAL> ")" { return tok(sym.RPAREN, null); }
<YYINITIAL> "[" { return tok(sym.LBRACK, null); }
<YYINITIAL> "]" { return tok(sym.RBRACK, null); }
<YYINITIAL> "{" { return tok(sym.LBRACE, null); }
<YYINITIAL> "}" { return tok(sym.RBRACE, null); }
<YYINITIAL> "." { return tok(sym.DOT, null); }
<YYINITIAL> "+" { return tok(sym.PLUS, null); }
<YYINITIAL> "-" { return tok(sym.MINUS, null); }
<YYINITIAL> "*" { return tok(sym.TIMES, null); }
<YYINITIAL> "/" { return tok(sym.DIVIDE, null); }
<YYINITIAL> "=" { return tok(sym.EQ, null); }
<YYINITIAL> "<>" { return tok(sym.NEQ, null); }
<YYINITIAL> "<" { return tok(sym.LT, null); }
<YYINITIAL> "<=" { return tok(sym.LE, null); }
<YYINITIAL> ">" { return tok(sym.GT, null); }
<YYINITIAL> ">=" { return tok(sym.GE, null); }
<YYINITIAL> "&" { return tok(sym.AND, null); }
<YYINITIAL> "|" { return tok(sym.OR, null); }
<YYINITIAL> ":=" { return tok(sym.ASSIGN, null); }

<YYINITIAL> {letter}({letter}|{digit}|_)* {
        return tok(sym.ID, yytext());
}

<YYINITIAL> {digit}+ {
        return tok(sym.INT, new Integer(yytext()));
}

<YYINITIAL> "\"" {
        yybegin(STRING);
        stringBuilder = new StringBuilder();
}

<YYINITIAL> "/*" {
        yybegin(COMMENT);
        commentDepth = 1;
}

<YYINITIAL> . {
        return tok(sym.error, null);
}

<STRING> \" {
        String s = stringBuilder.toString();
        stringBuilder = null;
        yybegin(YYINITIAL);
        return tok(sym.STRING, s);
}

<STRING> \\ {
        yybegin(STRING_ESCAPE);
}

<STRING> . {
        stringBuilder.append(yytext());
}

<STRING_ESCAPE> n {
        stringBuilder.append('\n');
        yybegin(STRING);
}

<STRING_ESCAPE> t {
        stringBuilder.append('\t');
        yybegin(STRING);
}

<STRING_ESCAPE> "^"{lowercase} {
        stringBuilder.append((char)(yytext().charAt(1) - 'a' + 1));
        yybegin(STRING);
}

<STRING_ESCAPE> {digit}{digit}{digit} {
        int i = Integer.parseInt(yytext());
        if (i < 256) {
                stringBuilder.append((char)i);
        } else {
                err("Out of ascii range");
        }
        yybegin(STRING);
}

<STRING_ESCAPE> \" {
        stringBuilder.append('\"');
        yybegin(STRING);
}

<STRING_ESCAPE> \\ {
        stringBuilder.append('\\');
        yybegin(STRING);
}

<STRING_ESCAPE> " "|\t|\f {
        yybegin(STRING_IGNORE);
}

<STRING_IGNORE> " "|\t|\f {}

<STRING_IGNORE> \\ {
        yybegin(STRING);
}

<STRING_ESCAPE, STRING_IGNORE> . {
        err("Illegal escape sequence");
        yybegin(STRING);
}

<COMMENT> "/*" {
        commentDepth += 1;
}

<COMMENT> "*/" {
        if (--commentDepth == 0) {
                yybegin(YYINITIAL);
        }
}

<COMMENT> . {}

