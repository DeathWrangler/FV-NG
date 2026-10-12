package Classes.MOTD
{
   import Managers.FarmStatsManager;
   import Managers.LimitedQuantityBundleManager;
   
   public class LimitedQuantityBundleMOTDHandler extends CustomWindowMOTDHandler
   {
      
      private var m_featureName:String;
      
      private var m_bundleNames:Array;
      
      public function LimitedQuantityBundleMOTDHandler(currentMOTD:Object)
      {
         var count:int = 0;
         var i:int = 0;
         super(currentMOTD);
         this.m_bundleNames = new Array();
         if(Boolean(currentMOTD) && Boolean(currentMOTD.customWindowParams))
         {
            if(currentMOTD.customWindowParams["itemList"])
            {
               count = int(currentMOTD.customWindowParams.itemList.item.length);
               for(i = 0; i < count; i++)
               {
                  this.m_bundleNames[i] = currentMOTD.customWindowParams.itemList.item[i];
               }
            }
            else if(currentMOTD.customWindowParams.item)
            {
               this.m_bundleNames[0] = currentMOTD.customWindowParams.item;
            }
         }
         if(Boolean(currentMOTD) && Boolean(currentMOTD.customActionParams))
         {
            if(currentMOTD.customActionParams["featureName"])
            {
               this.m_featureName = currentMOTD.customActionParams.featureName;
            }
         }
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         this.buyLimitedBundle();
      }
      
      private function buyLimitedBundle() : void
      {
         var LQManager:LimitedQuantityBundleManager = LimitedQuantityBundleManager.getInstance();
         LQManager.startBuyTransaction(this.m_featureName);
         this.logButtonClick();
      }
      
      private function logButtonClick(itemName:String = "") : void
      {
         FarmStatsManager.count("limited_qty_bundle","button_clicked",itemName);
      }
   }
}

