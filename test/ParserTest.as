
package test {
  import milParser.*;
  public class ParserTest {
    public function ParserTest() {
    }

    public static function whileTest():Boolean {
      var src:String = "";
      var expected:Vector.<int> = Vector.<int>([]);
      return test(src, expected);
    }

    private static function test(src:String, expected:Vector.<int>):Boolean {
      try {
	var i:int;
	var parser:Parser = new Parser(src);
	var bytecode:Vector.<int> = parser.bytecode;
	if (expected.length != bytecode.length) {
	  return false;
	}
	for (i = 0; i < bytecode.length; i++) {
	  if (bytecode[i] != expected[i]) {
	    return false;
	  }
	}
      }
      catch (e:Error) {
	return false;
      }
      return true;
    }
  }
}


