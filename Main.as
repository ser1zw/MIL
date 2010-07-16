package {
  import flash.display.Sprite;
  
  [SWF(width="400", height="300", backgroundColor="#eeffee")] 
  public class Main extends Sprite {
    public function Main() {
      lexSample();
    }

    private function lexSample():void {
      var token:Token;
      var src:String = "if a == 0 print \"hoge\" # This is a comment";
      var lex:LexicalAnalyzer = new LexicalAnalyzer(src);
      log(src);
      do {
	token = lex.lexGetToken();
	if (token.tokenKind == TokenKind.INT_VALUE_TOKEN) {
	  log(token.intValue + " 整数");
	}
	else if (token.tokenKind == TokenKind.IDENTIFIER_TOKEN) {
	  log(token.identifier + " 識別子");
	}
	else if (token.tokenKind == TokenKind.STRING_LITERAL_TOKEN) {
	  log(token.stringValue + " 文字列リテラル");
	}
	else if (token.tokenKind >= TokenKind.EQ_TOKEN && token.tokenKind <= TokenKind.SEMICOLON_TOKEN) {
	  log(token.tokenKind + " 演算子または区切り子");
	}
	else if (token.tokenKind != TokenKind.END_OF_FILE_TOKEN && token.tokenKind >= TokenKind.IF_TOKEN) {
	  // log(keywordTable[token.tokenKind - TokenKind.IF_TOKEN] + " 予約語");
	  log("予約語");
	}
      } while(token.tokenKind != TokenKind.END_OF_FILE_TOKEN);
    }
  }
}

