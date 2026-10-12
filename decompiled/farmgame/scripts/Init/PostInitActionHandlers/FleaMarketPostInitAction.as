package Init.PostInitActionHandlers
{
   import Classes.Constants.Experiments;
   import Classes.util.FarmGameUtil;
   import Display.FriendBar.DynamicNPCSlot;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Managers.ToasterManager;
   import Transactions.TFleaMarket;
   import Widgets.Windows.FleaMarket.FleaMarketToasterWindow;
   import Widgets.Windows.FleaMarket.FleaMarketWindow;
   
   public class FleaMarketPostInitAction extends AbstractPostInitAction
   {
      
      private static const REPROMPT_INTERVAL:String = "flea_market_toaster";
      
      private static const ACTIVE_EXPERIMENT_THRESHOLD:int = 2;
      
      private static var m_dynamicSlot:DynamicNPCSlot = null;
      
      public function FleaMarketPostInitAction(callback:Function = null)
      {
         super(callback);
      }
      
      private static function initFleaMakret(result:Object) : void
      {
         var slotConfig:Object = null;
         var repromptInterval:Number = NaN;
         var lastShown:Number = NaN;
         if(result.hasOwnProperty("items") && result.items.length > 0)
         {
            slotConfig = {
               "assetPath":"assets/dialogs/FV_Support/FV_FleaMarket/Neighbor_FleaMarket.swf",
               "action":"flea_market",
               "stat":"trading",
               "tooltip":"Dialogs:fleaMarketNPCTooltip",
               "refreshCallback":FleaMarketPostInitAction.refreshCallback
            };
            m_dynamicSlot = new DynamicNPCSlot(Global.ui.m_friendBar.slots.length,slotConfig);
            Global.ui.m_friendBar.addSlotAtBeginning(m_dynamicSlot);
            FeatureOptionsManager.getInstance().setFeatureOption(FleaMarketWindow.FLEA_MARKET_OPTION,"flea_market_requested",result.items);
            repromptInterval = Global.farmGameSettingsManager.getNumber("fleaMarketToasterReprompt",86400);
            lastShown = Global.player.getFeatureLastShown(REPROMPT_INTERVAL);
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND > lastShown + repromptInterval)
            {
               Global.player.setFeatureLastShown(REPROMPT_INTERVAL,GlobalEngine.serverTime,true);
               ToasterManager.getInstance().add(new FleaMarketToasterWindow());
            }
         }
      }
      
      public static function refreshCallback(extraData:Object = null) : void
      {
         var levelRequirement:Boolean = false;
         var cooldownInterval:Number = NaN;
         var lastSale:Number = NaN;
         var fleaMarketInit:TFleaMarket = null;
         if(m_dynamicSlot)
         {
            Global.ui.m_friendBar.removeSlotAtIndex(m_dynamicSlot.m_index);
            levelRequirement = Global.player.level >= Global.farmGameSettingsManager.getNumber("fleaMarketMinLevel",15);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FLEA_MARKET) > ACTIVE_EXPERIMENT_THRESHOLD && levelRequirement)
            {
               cooldownInterval = Global.farmGameSettingsManager.getNumber("fleaMarketCooldown",259200);
               lastSale = FeatureOptionsManager.getInstance().getFeatureOption(FleaMarketWindow.FLEA_MARKET_OPTION,"flea_market_last_time") as Number;
               if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND > lastSale + cooldownInterval)
               {
                  fleaMarketInit = new TFleaMarket(TFleaMarket.TYPE_INIT,initFleaMakret);
                  TransactionManager.addTransaction(fleaMarketInit);
               }
            }
         }
      }
      
      override public function execute() : void
      {
         var cooldownInterval:Number = NaN;
         var lastSale:Number = NaN;
         var fleaMarketInit:TFleaMarket = null;
         var levelRequirement:Boolean = Global.player.level >= Global.farmGameSettingsManager.getNumber("fleaMarketMinLevel",15);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FLEA_MARKET) > ACTIVE_EXPERIMENT_THRESHOLD && levelRequirement)
         {
            cooldownInterval = Global.farmGameSettingsManager.getNumber("fleaMarketCooldown",259200);
            lastSale = FeatureOptionsManager.getInstance().getFeatureOption(FleaMarketWindow.FLEA_MARKET_OPTION,"flea_market_last_time") as Number;
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND > lastSale + cooldownInterval)
            {
               fleaMarketInit = new TFleaMarket(TFleaMarket.TYPE_INIT,initFleaMakret);
               TransactionManager.addTransaction(fleaMarketInit);
            }
         }
         m_isFinished = true;
      }
   }
}

