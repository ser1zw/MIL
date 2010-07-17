package milParser {
  /** ラベル */
  public class Label {
    private var _identifier:String;
    public var address:int;
    public function get identifier():String {
      return _identifier;
    }

    /**
    コンストラクタ
    @param identifier 識別子
    @param address アドレス(default = 0)
    */
    public function Label(identifier:String, address:int = 0) {
      this._identifier = identifier;
      this.address = address;
    }
  }
}

