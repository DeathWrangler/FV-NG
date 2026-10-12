package Widgets.Windows.FleaMarket
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FleaMarket.FleaMarketSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class FleaMarketWindow extends FarmWindow
   {
      
      private static const STATS_COUNTER:String = "trading";
      
      private static const STATS_KINGDOM:String = "dialog";
      
      private static const FLEA_MARKET_FTUE:String = "fleaMarket_ftue";
      
      public static const FLEA_MARKET_OPTION:String = "flea_market";
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_FleaMarket.swf";
      
      private static const COOLDOWN_CONSTANT:String = "fleaMarketCooldown";
      
      private static const DEFAULT_COOLDOWN:Number = 259200;
      
      private static const ICON_SIZE:int = 100;
      
      public static const STORAGE_ID:int = -1;
      
      private var m_items:Array;
      
      private var m_whatIsThisView:ZwFrame;
      
      private var m_welcomeFrame:ZwFrame;
      
      private var m_activeView:ZwBaseWidget;
      
      public function FleaMarketWindow()
      {
         var consignment:Object = null;
         var itemId:Number = NaN;
         var inventory:Dictionary = null;
         this.m_items = new Array();
         var consignmentList:Array = FeatureOptionsManager.getInstance().getFeatureOption(FLEA_MARKET_OPTION,"flea_market_requested") as Array;
         for(var i:int = 0; i < consignmentList.length; i++)
         {
            consignment = consignmentList[i];
            itemId = Number(consignment.id);
            if(itemId != STORAGE_ID && Global.world.getObjectById(itemId) != null)
            {
               this.m_items.push(consignment);
            }
            else if(itemId == STORAGE_ID)
            {
               inventory = Global.player.getInventory();
               if(inventory.hasOwnProperty(Global.farmGameSettingsManager.getFarmItemCodeByName(consignment.name)))
               {
                  this.m_items.push(consignment);
               }
            }
         }
         super(ASSET_PATH);
      }
      
      public static function getCurrencyFromVariant() : String
      {
         var result:String = Currency.CASH;
         var experimentVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FLEA_MARKET);
         if(experimentVariant == 3 || experimentVariant == 6)
         {
            result = Currency.CASH;
         }
         else if(experimentVariant == 4 || experimentVariant == 7)
         {
            result = Currency.COCONUTS;
         }
         else if(experimentVariant == 5 || experimentVariant == 8)
         {
            result = Currency.COINS;
         }
         return result;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var lastSaleEvent:Number;
         var cooldown:Number;
         var serverTime:Number;
         var welcomeScreenShown:Boolean;
         var whatIsThis:FarmAnimatedTextButton = null;
         var slotContainer:FleaMarketSlotFrame = null;
         var lastSale:Object = null;
         var currency:String = null;
         var currencyString:String = null;
         var farmItem:FarmItem = null;
         super.onLoadComplete(event);
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","fleaMarket_title")));
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"view","sell_item_number",this.m_items.length.toString());
         if(m_window.hasOwnProperty("whatisthis_bt"))
         {
            whatIsThis = new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t("Dialogs","WhatIsThis"),this.onToggleTutorial);
            addWidget(whatIsThis);
         }
         addWidget(this.m_whatIsThisView = new ZwFrame(m_window.whatisthis_mc),false);
         this.m_whatIsThisView.addWidget(new ZwTextField(m_window.whatisthis_mc.whatisthis_tf,ZLocUtils.t("Dialogs","fleaMarket_welcomeTitle")));
         this.m_whatIsThisView.addWidget(new ZwTextField(m_window.whatisthis_mc.body_tf,ZLocUtils.t("Dialogs","fleaMarket_welcomeText")));
         this.m_whatIsThisView.addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onToggleTutorial));
         lastSaleEvent = FeatureOptionsManager.getInstance().getFeatureOption(FLEA_MARKET_OPTION,"flea_market_last_time") as Number;
         cooldown = Global.farmGameSettingsManager.getNumber(COOLDOWN_CONSTANT,DEFAULT_COOLDOWN);
         serverTime = GlobalEngine.serverTime;
         if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND > lastSaleEvent + cooldown)
         {
            if(this.m_items != null && this.m_items.length > 0)
            {
               slotContainer = new FleaMarketSlotFrame(m_window.main_mc,this);
               addWidget(slotContainer);
               slotContainer.items = this.m_items;
               this.m_activeView = slotContainer;
            }
            else
            {
               addWidget(this.m_activeView = new ZwBaseWidget(m_window.closed_mc));
               addWidget(new ZwTextField(m_window.closed_mc.closed_tf,ZLocUtils.t("Dialogs","fleaMarket_closedTitle")));
               addWidget(new ZwTextField(m_window.closed_mc.body_tf,ZLocUtils.t("Dialogs","fleaMarket_closedText")));
               addWidget(new FarmAnimatedTextButton(m_window.closed_mc.okay_bt,"Okay",this.onClose));
            }
         }
         else
         {
            lastSale = FeatureOptionsManager.getInstance().getFeatureOption(FLEA_MARKET_OPTION,"flea_market_last_item");
            if(lastSale != null && lastSale.hasOwnProperty("name") && lastSale.hasOwnProperty("price"))
            {
               addWidget(this.m_activeView = new ZwBaseWidget(m_window.thankyou_mc));
               addWidget(new ZwTextField(m_window.thankyou_mc.thankyou_tf,ZLocUtils.t("Dialogs","fleaMarket_thankYouTitle")));
               addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc));
               m_closeButton.visible = false;
               whatIsThis.visible = false;
               currency = FleaMarketWindow.getCurrencyFromVariant();
               currencyString = "";
               switch(currency)
               {
                  case Currency.CASH:
                     addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc.mc_coinIcon),false);
                     addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc.cocoIcon_mc),false);
                     addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc.cashIcon_mc),true);
                     addWidget(new ZwTextField(m_window.thankyou_mc.number_tf,"+" + Utilities.formatNumber(lastSale.price)));
                     addWidget(new ZwTextField(m_window.thankyou_mc.number2_tf),false);
                     currencyString = ZLocUtils.t("FarmGame","Currency_FarmCash");
                     break;
                  case Currency.COCONUTS:
                     addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc.mc_coinIcon),false);
                     addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc.cocoIcon_mc),true);
                     addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc.cashIcon_mc),false);
                     addWidget(new ZwTextField(m_window.thankyou_mc.number_tf),false);
                     addWidget(new ZwTextField(m_window.thankyou_mc.number2_tf,"+" + Utilities.formatNumber(lastSale.price)));
                     currencyString = ZLocUtils.t("FarmGame","Currency_Coconuts");
                     break;
                  case Currency.COINS:
                     addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc.mc_coinIcon),true);
                     addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc.cocoIcon_mc),false);
                     addWidget(new ZwBaseWidget(m_window.thankyou_mc.price_mc.cashIcon_mc),false);
                     addWidget(new ZwTextField(m_window.thankyou_mc.number_tf),false);
                     addWidget(new ZwTextField(m_window.thankyou_mc.number2_tf,"+" + Utilities.formatNumber(lastSale.price)));
                     currencyString = ZLocUtils.t("FarmGame","Currency_Gold");
                     break;
                  default:
                     close();
               }
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(lastSale.name);
               if(farmItem != null)
               {
                  addWidget(new ZwTextField(m_window.thankyou_mc.body_tf,ZLocUtils.t("Dialogs","fleaMarket_thankYouText",{
                     "itemName":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName),
                     "currency":currencyString,
                     "amount":Utilities.formatNumber(lastSale.price as int)
                  })));
               }
               addWidget(new FarmAnimatedTextButton(m_window.thankyou_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onOpenMarket));
               FeatureOptionsManager.getInstance().setFeatureOption(FleaMarketWindow.FLEA_MARKET_OPTION,"flea_market_last_item",{});
            }
            else
            {
               addWidget(this.m_activeView = new ZwBaseWidget(m_window.comeBack_mc));
               addWidget(new ZwTextField(m_window.comeBack_mc.comeBack_tf,ZLocUtils.t("Dialogs","fleaMarket_comeBackTitle")));
               addWidget(new ZwTextField(m_window.comeBack_mc.body_tf,ZLocUtils.t("Dialogs","fleaMarket_comeBackText")));
               addWidget(new FarmAnimatedTextButton(m_window.comeBack_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onClose));
            }
         }
         welcomeScreenShown = Global.player.getSeenFlag(FleaMarketWindow.FLEA_MARKET_FTUE);
         if(!welcomeScreenShown)
         {
            Global.player.setSeenFlag(FleaMarketWindow.FLEA_MARKET_FTUE,false);
            this.m_welcomeFrame = new ZwFrame(m_window.welcome_mc);
            addWidget(this.m_welcomeFrame);
            this.m_welcomeFrame.addWidget(new ZwTextField(m_window.welcome_mc.welcome_tf,ZLocUtils.t("Dialogs","fleaMarket_introTitle")));
            this.m_welcomeFrame.addWidget(new ZwTextField(m_window.welcome_mc.body_tf,ZLocUtils.t("Dialogs","fleaMarket_introText")));
            this.m_welcomeFrame.addWidget(new FarmAnimatedTextButton(m_window.welcome_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),function():void
            {
               m_activeView.visible = true;
               m_welcomeFrame.visible = false;
            }));
            this.m_activeView.visible = false;
         }
         else
         {
            addWidget(this.m_welcomeFrame = new ZwFrame(m_window.welcome_mc),false);
         }
      }
      
      private function onOpenMarket(event:Event) : void
      {
         close();
         FarmStatsManager.count(STATS_COUNTER,"mkt_interstitial","view");
         UI.displayMarketDialog(FleaMarketWindow.FLEA_MARKET_OPTION,"limited");
      }
      
      private function onToggleTutorial(event:Event) : void
      {
         if(this.m_welcomeFrame.visible == true)
         {
            this.m_welcomeFrame.visible = false;
            this.m_activeView.visible = false;
            this.m_whatIsThisView.visible = true;
         }
         else
         {
            this.m_activeView.visible = !this.m_activeView.visible;
            this.m_whatIsThisView.visible = !this.m_whatIsThisView.visible;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"cancel");
         super.onClose(event);
      }
   }
}

