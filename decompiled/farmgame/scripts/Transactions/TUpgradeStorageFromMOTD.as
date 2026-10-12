package Transactions
{
   import Classes.StorageBuilding;
   
   public class TUpgradeStorageFromMOTD extends TUpgradeStorage
   {
      
      public static const ACTION_COMPLETE_BUILDING:String = "PurchaseStorageUpgradeFromMOTD";
      
      public function TUpgradeStorageFromMOTD(building:StorageBuilding, callback:Function = null, discount:Number = 0)
      {
         super(building,null,"purchase",callback);
         m_discount = discount;
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_COMPLETE_BUILDING,m_params);
      }
   }
}

