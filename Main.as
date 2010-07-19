package {
  import flash.display.Sprite;
  import milLexicalAnalyzer.*;
  import milParser.*;
  import flash.text.TextField;
  import com.bit101.components.*;
  import flash.events.*;


  [SWF(width="400", height="300", backgroundColor="#eeffee")] 
  public class Main extends Sprite {
    private var editor:TextField;
    private var button:PushButton;
    
    public function Main() {
      editor = new TextField();
      editor.width = 300;
      editor.height = 200;
      editor.x = 0;
      editor.y = 50;
      editor.backgroundColor = 0xffffff;
      editor.type = "input";
      editor.multiline = true;
      editor.border = true;
      // while文とif文、if-else文でbad statementが出るorz
      editor.text = "a = 1;\nif (a == 1) {\n  b = 1;\n} else {\n  c = 1;\n}\n";

      addChild(editor);

      button = new PushButton(this, 350, 50, "run", function(e:MouseEvent):void {
	  // lexSample(editor.text);
	  parserSample(editor.text);
	});
    }

    private function parserSample(src:String):void {
      try {
	var parser:Parser = new Parser(src);
	for each (var c:int in parser.bytecode) {
	  log(c);
	}
      }
      catch (e:Error) {
	log(e);
      }
    }

    private function lexSample(src:String):void {
      var token:Token;
      var lex:LexicalAnalyzer = new LexicalAnalyzer(src);
      // log(src);
      do {
	token = lex.lexGetToken();
	if (token.kind == TokenKind.INT_VALUE_TOKEN) {
	  log(token.intValue + " 整数");
	}
	else if (token.kind == TokenKind.IDENTIFIER_TOKEN) {
	  log(token.kind + " " + token.identifier + " 識別子");
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

