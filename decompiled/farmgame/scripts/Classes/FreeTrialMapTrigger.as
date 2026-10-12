package Classes
{
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FreeTrialWindow;
   
   public class FreeTrialMapTrigger extends StationaryMapTrigger
   {
      
      private static const PAID_DIALOG_ACTION_COUNTER:String = "freeTrialPaidCount";
      
      private static const FREE_TRIAL_LAST_SEEN_KEY:String = "freeTrialLastSeen";
      
      public static const FREE_TRIAL_STATS_COUNTER:String = "free_trial";
      
      public static const FREE_TRIAL_ANNOUNCE_KINGDOM:String = "announce";
      
      public static const FREE_TRIAL_PURCHASE_KINGDOM:String = "purchase";
      
      public static const SESSION_SEEN_FLAGED_VIEWED_ASSET:String = "viewed_asset";
      
      protected var m_paid:Boolean = false;
      
      public function FreeTrialMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         this.m_paid = xmlData.paid[0].toString().toLowerCase() == "true";
         var kingdom:String = this.m_paid ? FREE_TRIAL_PURCHASE_KINGDOM : FREE_TRIAL_ANNOUNCE_KINGDOM;
         FarmStatsManager.count(FREE_TRIAL_STATS_COUNTER,kingdom,"npc_loaded");
      }
      
      override public function updateCulling() : void
      {
         var kingdom:String = null;
         super.updateCulling();
         if(Global.player.getSeenSessionFlag(SESSION_SEEN_FLAGED_VIEWED_ASSET) == false && isWithinViewport() == true)
         {
            Global.player.setSeenSessionFlag(SESSION_SEEN_FLAGED_VIEWED_ASSET);
            kingdom = this.m_paid ? FREE_TRIAL_PURCHASE_KINGDOM : FREE_TRIAL_ANNOUNCE_KINGDOM;
            FarmStatsManager.count(FREE_TRIAL_STATS_COUNTER,kingdom,"npc_view");
         }
      }
      
      override public function onClick() : void
      {
         var updateServerLastSeenTime:Boolean = false;
         if(!this.m_paid)
         {
            TransactionManager.addTransaction(new TGenericTransaction("FreeTrialService","grantItemPack"));
            Global.player.addGift(Global.farmGameSettingsManager.getFarmItemNameByCode(FreeTrialWindow.PAID_PACK_ITEM_CODE));
            Global.player.cash += FreeTrialWindow.PACK_FC_AMOUNT;
         }
         else
         {
            Global.player.incrementActionCount(PAID_DIALOG_ACTION_COUNTER);
            updateServerLastSeenTime = true;
         }
         Global.player.setFeatureLastShown(FREE_TRIAL_LAST_SEEN_KEY,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,updateServerLastSeenTime);
         UI.displayPopup(new FreeTrialWindow(this.m_paid));
         var kingdom:String = this.m_paid ? FREE_TRIAL_PURCHASE_KINGDOM : FREE_TRIAL_ANNOUNCE_KINGDOM;
         FarmStatsManager.count(FREE_TRIAL_STATS_COUNTER,kingdom,"npc_click");
         this.detach();
         this.cleanUp();
      }
   }
}

