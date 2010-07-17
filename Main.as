package {
  import flash.display.Sprite;
  import milLexicalAnalyzer.*;
  import milParser.*;

  [SWF(width="400", height="300", backgroundColor="#eeffee")] 
  public class Main extends Sprite {
    public function Main() {
      parserSample();
    }

    private function parserSample():void {
      // var src:String = "if a == 0 print \"hoge\" # This is a comment";
      var parser:Parser = new Parser("");
      parser.test();
    }

    private function lexSample():void {
      var token:Token;
      var src:String = "if a == 0 print \"hoge\" # This is a comment";
      var lex:LexicalAnalyzer = new LexicalAnalyzer(src);
      log(src);
      do {
	token = lex.lexGetToken();
	if (token.kind == TokenKind.INT_VALUE_TOKEN) {
	  log(token.intValue + " 整数");
	}
	else if (token.kind == TokenKind.IDENTIFIER_TOKEN) {
	  log(token.identifier + " 識別子");
	}
	else if (token.kind == TokenKind.STRING_LITERAL_TOKEN) {
	  log(token.stringValue + " 文字列リテラル");
	}
	else if (token.kind >= TokenKind.EQ_TOKEN && token.kind <= TokenKind.SEMICOLON_TOKEN) {
	  log(token.kind + " 演算子または区切り子");
	  }
	  else if (token.kind != TokenKind.END_OF_FILE_TOKEN && token.kind >= TokenKind.IF_TOKEN) {
	  // log(keywordTable[token.kind - TokenKind.IF_TOKEN] + " 予約語");
	  log("予約語");
	  }
	  } while(token.kind != TokenKind.END_OF_FILE_TOKEN);
	  }
	}
      }

