package analisador.sintatico;
import analisador.lexico.Yylex;
import error.ErrorMsg;

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
          parser.debug_parse();
      } catch (Throwable e) {
	e.printStackTrace();
	throw new Error(e.toString());
      } 
      finally {
         try {inp.close();} catch (java.io.IOException e) {}
      }
  }
}
   

