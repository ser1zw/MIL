package lexicalAnalyzer {
  public class Token {
    private var _kind:int;
    private var _intValue:int;
    private var _stringValue:String;
    private var _identifier:String;

    /**
    int型の値を表すトークンオブジェクトを作成
    @param tokenKind トークンの種類(TokenKind)
    @param intValue 値
    @return tokenKindとintValueがセットされたトークンオブジェクト
    */
    public static function getIntToken(tokenKind:int, intValue:int):Token {
      var token:Token = new Token();
      token._kind = tokenKind;
      token._intValue = intValue;
      return token;
    }

    /**
    String型の値を表すトークンオブジェクトを作成
    @param tokenKind トークンの種類(TokenKind)
    @param stringValue 値
    @return tokenKindとstringValueがセットされたトークンオブジェクト
    */
    public static function getStringToken(tokenKind:int, stringValue:String):Token {
      var token:Token = new Token();
      token._kind = tokenKind;
      token._stringValue = stringValue;
      return token;
    }

    /**
    識別子を表すトークンオブジェクトを作成
    @param tokenKind トークンの種類(TokenKind)
    @param identifier 値
    @return tokenKindとidentifierがセットされたトークンオブジェクト
    */
    public static function getIdentifierToken(tokenKind:int, identifier:String):Token {
      var token:Token = new Token();
      token._kind = tokenKind;
      token._identifier = identifier
      return token;
    }

    public function get tokenKind():int {
      return _kind;
    }
    public function set tokenKind(kind:int):void {
      _kind = kind;
    }

    public function get intValue():int {
      return _intValue;
    }
    public function get stringValue():String {
      return _stringValue;
    }
    public function get identifier():String {
      return _identifier;
    }
  }
}

