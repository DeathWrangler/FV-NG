package Transactions
{
   import Classes.ZItem.FarmItem;
   import Managers.FeatureOptionsManager;
   
   public class TXmasCharityCongratsSeen extends TFarmTransaction
   {
      
      protected var m_item:FarmItem;
      
      public function TXmasCharityCongratsSeen(itemName:String)
      {
         super();
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
      }
      
      override public function perform() : void
      {
         signedCall("ChristmasCharityBundleService.congratsPopupSeen",this.m_item.name);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.CHRISTMAS_CHARITY_BUNDLES,this.m_item.name + "_congrats",2);
      }
   }
}

