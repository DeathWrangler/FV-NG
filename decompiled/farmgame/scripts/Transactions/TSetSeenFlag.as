package Transactions
{
   public class TSetSeenFlag extends TFarmTransaction
   {
      
      public static const METHOD_SET_SEEN_FLAG:String = "setSeenFlag";
      
      private var m_flagName:String;
      
      public function TSetSeenFlag(flagName:String)
      {
         super();
         this.m_flagName = flagName;
      }
      
      override public function perform() : void
      {
         signedCall("UserService." + METHOD_SET_SEEN_FLAG,this.m_flagName);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_SET_SEEN_FLAG;
         result.flagName = this.m_flagName;
         return result;
      }
   }
}

