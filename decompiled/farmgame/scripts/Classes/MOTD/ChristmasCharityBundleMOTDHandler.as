package Classes.MOTD
{
   import Classes.ZItem.FarmItem;
   import Managers.ChristmasCharityBundleManager;
   import Managers.FarmStatsManager;
   
   public class ChristmasCharityBundleMOTDHandler extends CustomWindowMOTDHandler
   {
      
      private var m_itemName:String;
      
      private var m_itemPrice:int;
      
      public function ChristmasCharityBundleMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         if(Boolean(currentMOTD) && Boolean(currentMOTD.customWindowParams) && Boolean(currentMOTD.customWindowParams.item))
         {
            this.m_itemName = currentMOTD.customWindowParams.item;
         }
         if(Boolean(currentMOTD) && Boolean(currentMOTD.customWindowParams) && Boolean(currentMOTD.customWindowParams.cost))
         {
            this.m_itemPrice = currentMOTD.customWindowParams.cost;
         }
      }
      
      override protected function acceptMOTD() : void
      {
         var item:FarmItem = null;
         var CCManager:ChristmasCharityBundleManager = null;
         super.acceptMOTD();
         if(this.m_itemName)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            if(item)
            {
               CCManager = ChristmasCharityBundleManager.getInstance();
               CCManager.startBuyTransaction(this.m_itemName,this.m_itemPrice);
               this.logButtonClick();
            }
         }
      }
      
      private function logButtonClick() : void
      {
         FarmStatsManager.count("xmas_charity_bundle","button_clicked");
      }
   }
}

