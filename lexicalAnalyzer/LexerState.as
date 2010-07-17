package lexicalAnalyzer {
  /** 読み取っているトークンの種類 */
  public class LexerState {
    public static const INITIAL_STATE:int = 1;
    public static const INT_VALUE_STATE:int = 2;
    public static const IDENTIFIER_STATE:int = 3;
    public static const STRING_STATE:int = 4;
    public static const OPERATOR_STATE:int = 5;
    public static const COMMENT_STATE:int = 6;
  }
}

