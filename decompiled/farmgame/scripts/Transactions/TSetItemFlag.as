package Transactions
{
   public class TSetItemFlag extends TFarmTransaction
   {
      
      private var m_attrName:String;
      
      private var m_attrValue:String;
      
      public function TSetItemFlag(attrName:String, attrValue:String)
      {
         super();
         this.m_attrName = attrName;
         this.m_attrValue = attrValue;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setItemFlag",this.m_attrName,this.m_attrValue);
      }
   }
}

