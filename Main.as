// -*- mode: actionscript; coding: utf-8-unix -*- 
package {
  import flash.display.Sprite;
  import milLexicalAnalyzer.*;
  import milParser.*;
  import milMvm.Mvm;
  import milIde.MilIDE;
  import flash.text.TextField;
  import flash.text.TextFormat;

  [SWF(width="400", height="300", backgroundColor="#cccccc")] 
  public class Main extends Sprite {
    private const FIBONACCI:String = "f0 = 0;\nf1 = 1;\nf2 = 0;\nprint(f0);\nprint(f1);\nwhile(f2 < 10) {\n    f2 = f0 + f1;\n    print(f2);\n    f0 = f1;\n    f1 = f2;\n}\n";

    public function Main() {
      var ide:MilIDE = new MilIDE();
      ide.editorText = FIBONACCI;
      addChild(ide);
    }

    private function lexSample2(src:String):void {
      var token:Token;
      var lex:LexicalAnalyzer = new LexicalAnalyzer(src);
      var table:Array = ["dummy", "整数", "識別子", "文字列", "==", "!=", ">=", "<=", "+", "-", "*", "/", "=", ">", "<", "(", ")", "{", "}", ",", ";", "if", "else", "while", "goto", "gosub", "return", "print", "EOF"];
      do {
	token = lex.lexGetToken();
	if (token.kind == TokenKind.INT_VALUE_TOKEN) {
	  log(token.intValue + " 整数");
	}
	else if (token.kind == TokenKind.STRING_LITERAL_TOKEN) {
	  log(token.stringValue + " 文字列リテラル");
	}
	else if (token.kind == TokenKind.IDENTIFIER_TOKEN) {
	  log(token.identifier + " 識別子");
	}
	else {
	  log(table[token.kind]);
	}
      } while(token.kind != TokenKind.END_OF_FILE_TOKEN);
    }

    private function lexSample(src:String):void {
      var token:Token;
      var lex:LexicalAnalyzer = new LexicalAnalyzer(src);
      do {
	token = lex.lexGetToken();
	
	if (token.kind == TokenKind.INT_VALUE_TOKEN) {
	  log(token.intValue + " 整数");
	}
	else if (token.kind == TokenKind.IDENTIFIER_TOKEN) {
	  log(token + " 識別子");
	}
	else if (token.kind == TokenKind.STRING_LITERAL_TOKEN) {
	  log(token + " 文字列リテラル");
	}
	else if (token.kind >= TokenKind.EQ_TOKEN && token.kind <= TokenKind.SEMICOLON_TOKEN) {
	  log(token + " 演算子または区切り子");
	}
	else if (token.kind != TokenKind.END_OF_FILE_TOKEN && token.kind >= TokenKind.IF_TOKEN) {
	  log(token + "予約語");
	}
      } while(token.kind != TokenKind.END_OF_FILE_TOKEN);
    }
  }
}

