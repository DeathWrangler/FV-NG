package Display
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.ChangeFarmItem;
   import Classes.ZItem.FarmItemType;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Events.MarketEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.events.MouseEvent;
   
   public class ExpansionPromptPopup extends FarmWindow
   {
      
      public static const DIALOG_PATH:String = "assets/dialogs/FV_motd_Landexpansion.swf";
      
      public static const DIALOG_ACCEPT_BUTTON_TEXT_KEY:String = "EPIExpandNow";
      
      public static const IDLE_THROTTLE_NO_RESET:int = 7;
      
      public static const IDLE_THROTTLE_WITH_RESET:int = 1;
      
      protected var m_miniMarketWindow:MarketWindow;
      
      public function ExpansionPromptPopup()
      {
         super(DIALOG_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var dialogBodyTextKey:String = null;
         var experimentVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EXPANSION_PROMPT_IDLE);
         var bodyString:String = "";
         if(experimentVariant > Experiments.VARIANT_EXPANSION_PROMPT_IDLE_EMPTY_STRING)
         {
            switch(experimentVariant)
            {
               case Experiments.VARIANT_EXPANSION_PROMPT_IDLE_MESSAGE_1:
                  dialogBodyTextKey = "EPIBody_MESSAGE_1";
                  break;
               case Experiments.VARIANT_EXPANSION_PROMPT_IDLE_MESSAGE_2:
                  dialogBodyTextKey = "EPIBody_MESSAGE_2";
                  break;
               case Experiments.VARIANT_EXPANSION_PROMPT_IDLE_MESSAGE_3:
                  dialogBodyTextKey = "EPIBody_MESSAGE_3";
                  break;
               case Experiments.VARIANT_EXPANSION_PROMPT_IDLE_MESSAGE_4:
                  dialogBodyTextKey = "EPIBody_MESSAGE_4";
                  break;
               case Experiments.VARIANT_EXPANSION_PROMPT_IDLE_MESSAGE_5:
                  dialogBodyTextKey = "EPIBody_MESSAGE_5";
            }
            bodyString = ZLocUtils.t("Dialogs",dialogBodyTextKey);
         }
         addWidget(new ZwBaseWidget(m_window.mainWindow));
         addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs",DIALOG_ACCEPT_BUTTON_TEXT_KEY),this.onAccept));
         addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClickClose));
         addWidget(new FarmTextField(m_window.mainWindow.body_tf,bodyString));
         FarmStatsManager.count("expansion_prompt_exp","view");
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.EXPANSION_PROMPT_IDLE,FeatureOptionsManager.EXPANSION_PROMPT_IDLE_NEXT_TIME,Math.ceil(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND) + IDLE_THROTTLE_NO_RESET * FarmGameUtil.NUM_SECS_IN_DAY);
         FeatureOptionsManager.getInstance().saveSingleFeature(FeatureOptionsManager.EXPANSION_PROMPT_IDLE,FeatureOptionsManager.EXPANSION_PROMPT_IDLE_NEXT_TIME);
      }
      
      private function onAccept(event:MouseEvent) : void
      {
         var expansion:ChangeFarmItem = null;
         this.close();
         var expansionsForMiniMarket:Array = Global.worldManager.getAllLargerExpansions();
         var itemNames:Array = [];
         for each(expansion in expansionsForMiniMarket)
         {
            itemNames.push(expansion.name);
         }
         this.m_miniMarketWindow = UI.displayMiniMarketDialog(itemNames,UI.MINIMARKET_CONTEXT_EXPANSIONPROMPT,FarmItemType.SEED,this.onMiniMarketClose) as MarketWindow;
         this.m_miniMarketWindow.addEventListener(MarketEvent.MARKET_BUY,this.expansionPurchased);
         FarmStatsManager.count("expansion_prompt_exp","clicks");
      }
      
      private function expansionPurchased(event:MarketEvent) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.EXPANSION_PROMPT_IDLE,FeatureOptionsManager.EXPANSION_PROMPT_IDLE_NEXT_TIME,Math.ceil(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND) + IDLE_THROTTLE_WITH_RESET * FarmGameUtil.NUM_SECS_IN_DAY);
         FeatureOptionsManager.getInstance().saveSingleFeature(FeatureOptionsManager.EXPANSION_PROMPT_IDLE,FeatureOptionsManager.EXPANSION_PROMPT_IDLE_NEXT_TIME);
         var itemCurrency:String = event.m_extraData as String;
         if(itemCurrency == Currency.CASH)
         {
            FarmStatsManager.count("expansion_prompt_exp","expansion_minimarket_purchaseFC",event.item,"fc_price");
         }
         else if(itemCurrency == Currency.COINS)
         {
            FarmStatsManager.count("expansion_prompt_exp","expansion_minimarket_purchaseFC",event.item,"coin_price");
         }
      }
      
      private function onClickClose(event:MouseEvent) : void
      {
         FarmStatsManager.count("expansion_prompt_exp","close");
         this.close();
      }
      
      private function onMiniMarketClose(closeIsBuy:Boolean) : void
      {
         this.m_miniMarketWindow.removeEventListener(MarketEvent.MARKET_BUY,this.expansionPurchased);
         this.m_miniMarketWindow = null;
         FarmStatsManager.count("expansion_prompt_exp","expansionprompt_minimarket","close");
      }
   }
}

