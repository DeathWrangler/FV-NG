package Classes.ZItem
{
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.MultiRewardTreasurePayerBundleConstructionBuilding;
   import Classes.MultiRewardTreasurePayerLandBundleConstructionBuilding;
   import DataSources.BaseDataSource;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Managers.ItemFinderManager;
   import Managers.SubscriptionsManager;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MultiRewardTreasureConstructionBuildingItem extends BuildingItem
   {
      
      private static const OPEN_UI_DELAY:int = 3200;
      
      private var m_timer:Timer;
      
      public function MultiRewardTreasureConstructionBuildingItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         UI.closeMarketDialog();
         ItemFinderManager.getInstance().highlightWorldItems(this.name);
         this.m_timer = new Timer(OPEN_UI_DELAY,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.showUI);
         this.m_timer.start();
         InputManager.disableInput();
         UI.stopPopups(true);
         return false;
      }
      
      override public function get saleCash() : int
      {
         var result:int = super.saleCash;
         if(SubscriptionsManager.isEligibleForVIPBenifit())
         {
            result -= cash * SubscriptionsManager.RUBY_LAND_EXPANSIONS_DISCOUNT / 100;
         }
         if(SubscriptionsManager.enableTileForOneFc())
         {
            result = 1;
         }
         return result;
      }
      
      private function showUI(event:Event = null) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.showUI);
         }
         InputManager.enableInput();
         UI.stopPopups(false);
         var tempObj:Array = Global.world.getObjectsByCode(this.code);
         if(Boolean(tempObj.length > 0) && Boolean(tempObj[0]) && tempObj[0] is MultiRewardTreasureConstructionBuilding)
         {
            (tempObj[0] as MultiRewardTreasureConstructionBuilding).onClick();
         }
         else if(Boolean(tempObj.length > 0) && Boolean(tempObj[0]) && tempObj[0] is MultiRewardTreasurePayerBundleConstructionBuilding)
         {
            (tempObj[0] as MultiRewardTreasurePayerBundleConstructionBuilding).onClick();
         }
         else if(Boolean(tempObj.length > 0) && Boolean(tempObj[0]) && tempObj[0] is MultiRewardTreasurePayerLandBundleConstructionBuilding)
         {
            (tempObj[0] as MultiRewardTreasurePayerLandBundleConstructionBuilding).onClick();
         }
      }
      
      override public function get hasSale() : Boolean
      {
         var result:Boolean = false;
         if(SubscriptionsManager.enableTileForOneFc())
         {
            result = true;
         }
         else
         {
            result = super.hasSale;
         }
         return result;
      }
   }
}

