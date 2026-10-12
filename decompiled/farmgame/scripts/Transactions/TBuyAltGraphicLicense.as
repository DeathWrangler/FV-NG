package Transactions
{
   import Managers.AltGraphicUtility;
   
   public class TBuyAltGraphicLicense extends TFarmTransaction
   {
      
      private var m_itemName:String;
      
      public function TBuyAltGraphicLicense(itemName:String)
      {
         super();
         this.m_itemName = itemName;
         var graphicKey:String = AltGraphicUtility.getAltGraphicCreditKey(itemName);
         Global.player.setUnlimitedAltGraphicsCredits(graphicKey,true);
      }
      
      override public function perform() : void
      {
         signedCall("FarmService.buyUnlimitedAltGraphicLicense",this.m_itemName);
      }
   }
}

