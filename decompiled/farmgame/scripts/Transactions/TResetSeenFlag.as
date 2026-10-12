package Transactions
{
   public class TResetSeenFlag extends TFarmTransaction
   {
      
      public static const METHOD_SET_SEEN_FLAG:String = "resetSeenFlag";
      
      private var m_flagName:String;
      
      public function TResetSeenFlag(flagName:String)
      {
         super();
         this.m_flagName = flagName;
      }
      
      override public function perform() : void
      {
         signedCall("UserService." + METHOD_SET_SEEN_FLAG,this.m_flagName);
      }
   }
}

