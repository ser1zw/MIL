package {
  import flash.display.Sprite;
  import milParser.Parser;
  import milMvm.Mvm;
  import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;
  import com.bit101.components.PushButton;
  import com.bit101.components.RadioButton;
  import com.bit101.components.VScrollBar;
  import flash.events.Event;
  import flash.events.MouseEvent;
  
  [SWF(backgroundColor="#cccccc")] 
  /** MILのIDE */
  public class MilIDE extends Sprite {
    private var editor:TextField;
    private var stdout:TextField;
    private var format:TextFormat;
    private var button:PushButton;
    private var radio1:RadioButton;
    private var radio2:RadioButton;
    private var editorScrollBar:VScrollBar;
    private var stdoutScrollBar:VScrollBar;

    private const FIBONACCI:String = "f0 = 0;\nf1 = 1;\nf2 = 0;\nprint(f0);\nprint(f1);\nwhile(f2 < 10) {\n    f2 = f0 + f1;\n    print(f2);\n    f0 = f1;\n    f1 = f2;\n}\n";
    
    public function MilIDE() {
      format = new TextFormat();
      format.font ="_等幅";
      format.size = 10;

      editor = new TextField();
      editor.width = 400;
      editor.height = 200;
      editor.x = 0;
      editor.y = 20;
      editor.background = true;
      editor.backgroundColor = 0xffffff;
      editor.type = TextFieldType.INPUT;
      editor.multiline = true;
      editor.border = true;
      editor.defaultTextFormat = format;
      editor.text = FIBONACCI;
      addChild(editor);

      stdout = new TextField();
      stdout.width = editor.width;
      stdout.height = 120;
      stdout.x = editor.x;
      stdout.y = editor.y + editor.height + 10;
      stdout.background = true;
      stdout.backgroundColor = 0x000000;
      stdout.textColor = 0xffffff;
      stdout.multiline = true;
      stdout.border = true;
      stdout.defaultTextFormat = format;
      addChild(stdout);

      button = new PushButton(this, editor.x + editor.width + 20, editor.y, "Run",
	function(e:MouseEvent):void {
	  stdout.text = "";
	  run(editor.text, radio2.selected);
	});
      button.width = 50;

      radio1 = new RadioButton(this, button.x, button.y + button.height + 20)
      radio1.label = "Run Bytecode";
      radio1.selected = true;
      radio2 = new RadioButton(this, radio1.x, radio1.y + radio1.height + 5);
      radio2.label = "Dump Assembly Code";

      editorScrollBar = new VScrollBar(this, editor.x + editor.width, editor.y, function(e:Event):void {
	  editor.scrollV = editorScrollBar.value
	});
      editorScrollBar.height = editor.height;
      editor.addEventListener(Event.SCROLL, function(e:Event):void {
	  adjustScrollBar(editor, editorScrollBar);
	});
      adjustScrollBar(editor, editorScrollBar);

      stdoutScrollBar = new VScrollBar(this, stdout.x + stdout.width, stdout.y, function(e:Event):void {
	  stdout.scrollV = stdoutScrollBar.value
	});
      stdoutScrollBar.height = stdout.height;
      stdout.addEventListener(Event.SCROLL, function(e:Event):void {
	  adjustScrollBar(stdout, stdoutScrollBar);
	});
      adjustScrollBar(stdout, stdoutScrollBar);
    }

    /**
    TextFieldに合わせてスクロールバーの状態を設定
    @param textField 対象となるTextField
    @param scrollBar スクロールバー
    */
    private function adjustScrollBar(textField:TextField, scrollBar:VScrollBar):void {
      var visibleLines:int = textField.numLines - textField.maxScrollV + 1;
      var percent:Number = visibleLines / textField.numLines;
      scrollBar.setSliderParams(1, textField.maxScrollV, textField.scrollV);
      scrollBar.setThumbPercent(percent);
      scrollBar.value = textField.scrollV;
    }

    /**
    MILのコードを実行
    @param sourceCode ソースコード
    @param dumpAssemblyCodeMode バイトコードを実行するかわりにアセンブリコードを出力
    */
    private function run(sourceCode:String, dumpAssemblyCodeMode:Boolean = false):void {
      try {
	var parser:Parser = new Parser(sourceCode);
	var mvm:Mvm = new Mvm(parser.bytecode, parser.strPool, function(msg:String):void {
	    stdout.appendText(msg + "\n");
	  });
	
	if (dumpAssemblyCodeMode) {
	  stdout.appendText(mvm.dumpAsmCode().join("\n"));
	}
	else {
	  mvm.execute();
	}
      }
      catch (e:Error) {
	stdout.appendText(e.toString());
      }
    }
  }
}

