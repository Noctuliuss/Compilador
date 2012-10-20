package analisador.sintatico;
import Absyn.*;
import analisador.lexico.Yylex;
import error.ErrorMsg;
import java_cup.runtime.Symbol;

public class Parse {

  public ErrorMsg errorMsg;

  public Parse(String filename) {
       errorMsg = new ErrorMsg(filename);
       java.io.InputStream inp;
       try {inp=new java.io.FileInputStream(filename);
       } catch (java.io.FileNotFoundException e) {
	 throw new Error("File not found: " + filename);
       }
       Yylex lex = new Yylex(inp,errorMsg);
       Grm parser = new Grm(lex, errorMsg);

      try {
          Symbol node = parser./*debug_*/parse();
          Print print = new Print(System.out);
          print.prExp((Exp)node.value, 0);
      } catch (Throwable e) {
	e.printStackTrace();
	throw new Error(e.toString());
      } 
      finally {
         try {inp.close();} catch (java.io.IOException e) {}
      }
  }
}
   

