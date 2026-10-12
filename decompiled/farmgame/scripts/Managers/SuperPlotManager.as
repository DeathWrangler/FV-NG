package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FarmGameWorld;
   import Classes.Plot;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.MOTD;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.UIEvent;
   import Transactions.TGenericTransaction;
   import Transactions.TGetMOTD;
   import Transactions.TRefreshGifts;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.ShareButtonToasterWindow;
   
   public class SuperPlotManager
   {
      
      public static const CONSUMABLE_ITEM_NAME:String = "consume_superplot";
      
      public static const PACKAGE_ITEM_NAMES:Array = ["pkg_superplot","pkg_superplot_10","pkg_superplot_25","pkg_superplot_50"];
      
      public static const MOTD_NAME_HOME_FARM:String = "MOTD_SUPER_PLOTS_HOME_FARM";
      
      public static const MOTD_NAME_NOT_HOME_FARM:String = "MOTD_SUPER_PLOTS_NOT_HOME_FARM";
      
      public static const SUPER_PLOT_MULTIPLIER:uint = 5;
      
      public static const WHAT_IS_THIS_DIALOG_NAME:String = "superplots";
      
      private static const WORLD_LIMIT_KEY:String = "superPlotsWorldLimit";
      
      private static const DEFAULT_WORLD_LIMIT:int = 104;
      
      private static const SERVICE_NAME:String = "SuperPlotService";
      
      private static const ONBOARD_GIFT_SEEN_FLAG:String = "superPlotsOnboardGift";
      
      private static const ONBOARD_GIFT_ITEM_NAME:String = "pkg_superplot_4";
      
      private static const STAT_COUNTER:String = "superplots";
      
      private static const ACTION_TOASTER_URL:String = "assets/dialogs/FV_superplots2013_toaster.swf";
      
      private static const ERROR_TOASTER_URL:String = "assets/dialogs/FV_superplots2013_sorry_toaster.swf";
      
      private static var m_isExperimentInitialized:Boolean = false;
      
      private static var m_isInExperiment:Boolean = false;
      
      private static var m_worldLimit:Number = Number.NaN;
      
      private static var m_showGiftBoxOnTutorialClose:Boolean = false;
      
      public function SuperPlotManager()
      {
         super();
      }
      
      public static function get isFeatureEnabled() : Boolean
      {
         if(!m_isExperimentInitialized && Global.experimentManager.initialized)
         {
            m_isExperimentInitialized = true;
            m_isInExperiment = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_SUPERPLOTS) == 2;
         }
         return m_isInExperiment;
      }
      
      public static function isSuperPlot(plot:Plot) : Boolean
      {
         return Global.world.getExtraItemFlag(plot.getId(),FarmGameWorld.EXTRA_ITEM_FLAG_SUPER_PLOT);
      }
      
      public static function applyToPlot(plot:Plot) : void
      {
         var plotId:Number = NaN;
         if(isFeatureEnabled)
         {
            plotId = plot.getId();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"applyToPlot",null,[plotId]),true);
            Global.world.setExtraItemFlag(plotId,FarmGameWorld.EXTRA_ITEM_FLAG_SUPER_PLOT,true);
            plot.conditionallyAttachSuperPlotOverlay();
            if(plot.isPlanted() || plot.isWithered())
            {
               plot.setFullGrown();
            }
            consumeSuperPlotInGiftbox();
         }
      }
      
      public static function getNumSuperPlotsInGiftbox() : int
      {
         return Global.player.getGiftCountForItem(CONSUMABLE_ITEM_NAME);
      }
      
      public static function consumeSuperPlotInGiftbox() : Boolean
      {
         var itemCode:String = null;
         var result:Boolean = false;
         if(getNumSuperPlotsInGiftbox() > 0)
         {
            itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(CONSUMABLE_ITEM_NAME);
            if(itemCode)
            {
               result = Global.player.removeGiftWithKey(itemCode);
            }
         }
         return result;
      }
      
      public static function getSuperPlots() : Array
      {
         var plot:Plot = null;
         var result:Array = [];
         var allPlots:Array = Global.world.getObjectsByType(WorldObjectTypes.PLOT);
         for each(plot in allPlots)
         {
            if(isSuperPlot(plot))
            {
               result.push(plot);
            }
         }
         return result;
      }
      
      public static function getNumSuperPlots() : Number
      {
         var result:Number = 0;
         var superPlots:Array = getSuperPlots();
         if(superPlots)
         {
            result = superPlots.length;
         }
         return result;
      }
      
      public static function getNonSuperPlots() : Array
      {
         var plot:Plot = null;
         var result:Array = [];
         var allPlots:Array = Global.world.getObjectsByType(WorldObjectTypes.PLOT);
         for each(plot in allPlots)
         {
            if(!isSuperPlot(plot))
            {
               result.push(plot);
            }
         }
         return result;
      }
      
      public static function getWorldLimit() : Number
      {
         if(isNaN(m_worldLimit))
         {
            m_worldLimit = Global.farmGameSettingsManager.getNumber(WORLD_LIMIT_KEY,DEFAULT_WORLD_LIMIT);
         }
         return m_worldLimit;
      }
      
      public static function hasReachedWorldLimit() : Boolean
      {
         var result:Boolean = false;
         if(getNumSuperPlots() >= getWorldLimit())
         {
            result = true;
         }
         return result;
      }
      
      public static function canPurchase(numToPurchase:Number) : Boolean
      {
         var result:Boolean = false;
         var numSuperPlots:Number = getNumSuperPlots();
         var numInGiftBox:Number = getNumSuperPlotsInGiftbox();
         if(numSuperPlots + numInGiftBox + numToPurchase <= getWorldLimit())
         {
            result = true;
         }
         return result;
      }
      
      public static function getMultiplier(plot:Plot) : int
      {
         var result:int = 1;
         if(isFeatureEnabled && isSuperPlot(plot))
         {
            result = int(SUPER_PLOT_MULTIPLIER);
         }
         return result;
      }
      
      public static function startOnboardFlow() : void
      {
         if(!TRefreshGifts.isRefreshing())
         {
            if(!Global.player.getSeenFlag(ONBOARD_GIFT_SEEN_FLAG))
            {
               Global.player.setSeenFlag(ONBOARD_GIFT_SEEN_FLAG,false,true);
               Global.player.addGift(ONBOARD_GIFT_ITEM_NAME);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantOnboardGift"),false);
               m_showGiftBoxOnTutorialClose = true;
               showTutorial();
            }
         }
         else
         {
            Global.ui.addEventListener(UIEvent.GIFTBOX_UNLOCKED,onGiftBoxUnlocked);
         }
      }
      
      private static function onGiftBoxUnlocked(event:UIEvent) : void
      {
         if(!TRefreshGifts.isRefreshing())
         {
            Global.ui.removeEventListener(UIEvent.GIFTBOX_UNLOCKED,onGiftBoxUnlocked);
            startOnboardFlow();
         }
      }
      
      public static function showTutorial() : void
      {
         TutorialUI.displayBundleTutorialWindow(ZLocConstants.DIALOG_UTIL_PKG,"SuperPlots","assets/dialogs/4d_elements/SuperPlots2013/FV_superplots2013",false,onTutorialClose);
      }
      
      private static function onTutorialClose() : void
      {
         var item:FarmItem = null;
         if(m_showGiftBoxOnTutorialClose)
         {
            m_showGiftBoxOnTutorialClose = false;
            item = Global.farmGameSettingsManager.getFarmItemByName(CONSUMABLE_ITEM_NAME);
            if(item)
            {
               UI.displayGiftBoxWindow(false,item.friendlyTitle);
            }
         }
      }
      
      public static function conditionallyShowMOTD() : void
      {
         var motdName:String = null;
         if(!Global.player.getSeenFlag(ONBOARD_GIFT_SEEN_FLAG))
         {
            motdName = Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME ? MOTD_NAME_HOME_FARM : MOTD_NAME_NOT_HOME_FARM;
            TransactionManager.addTransaction(new TGetMOTD(motdName,onGetMOTD));
         }
      }
      
      private static function onGetMOTD(result:Object) : void
      {
         if(result)
         {
            MOTD.displayMOTD(result,false,null,null,false);
         }
      }
      
      public static function conditionallyShowBuyInMarketToaster() : void
      {
         var title:String = null;
         var message:String = null;
         var actionButtonText:String = null;
         if(canPurchase(1))
         {
            title = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SuperPlotsBuyInMarketToaster_Title");
            message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SuperPlotsBuyInMarketToaster_Message");
            actionButtonText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SuperPlotsBuyInMarketToaster_ActionButton");
            ToasterManager.getInstance().add(new ShareButtonToasterWindow(title,message,"",ACTION_TOASTER_URL,1,null,onBuyInMarketToasterClick,null,actionButtonText));
         }
      }
      
      private static function onBuyInMarketToasterClick() : void
      {
         showMiniMarket();
      }
      
      public static function showMiniMarket() : void
      {
         UI.displayMiniMarketDialog(PACKAGE_ITEM_NAMES,"toaster","aide",null,false,false,false,true);
      }
      
      public static function showErrorToaster(message:String) : void
      {
         var title:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SuperPlotsErrorToaster_Title");
         ToasterManager.getInstance().add(new IconTitleToasterWindow(title,message,"",ERROR_TOASTER_URL));
      }
      
      public static function countGiftBox() : void
      {
         var numInGiftBox:Number = getNumSuperPlotsInGiftbox();
         FarmStatsManager.featureSample(STAT_COUNTER,"giftboxCount",String(numInGiftBox));
      }
   }
}

