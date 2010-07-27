// -*- mode: actionscript; coding: utf-8-unix -*- 
package {
  import flash.display.Sprite;
  import milIde.MilIDE;

  [SWF(width="400", height="300", backgroundColor="#cccccc")] 
  public class Mil extends Sprite {
    private const FIBONACCI:String = "f0 = 0;\nf1 = 1;\nf2 = 0;\nprint(f0);\nprint(f1);\nwhile(f2 < 10) {\n    f2 = f0 + f1;\n    print(f2);\n    f0 = f1;\n    f1 = f2;\n}\n";

    public function Mil() {
      var ide:MilIDE = new MilIDE();
      ide.editorText = FIBONACCI;
      addChild(ide);
    }
  }
}

