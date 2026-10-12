package Transactions
{
   public class TBuyCurrency extends TFarmTransaction
   {
      
      protected var m_itemName:String;
      
      protected var m_sourceTrackingString:String = "";
      
      public function TBuyCurrency(itemName:String, sourceTrackingString:String = "")
      {
         super();
         this.m_itemName = itemName;
         this.m_sourceTrackingString = sourceTrackingString;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyCurrency",this.m_itemName,this.m_sourceTrackingString);
      }
   }
}

