package Managers
{
   import Classes.Constants.Experiments;
   import Classes.HarvestableResource;
   import Classes.MapResource;
   import Classes.Plot;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Events.UIEvent;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.OrganicFertilizerWindow;
   import Widgets.Windows.ShareButtonToasterWindow;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class OrganicFertilizerHelper extends MapResourceHelper
   {
      
      private static const PURGE_REMINDER:String = "organicFertPurge";
      
      public static const FEATURE_NAME:String = "superFertilizer";
      
      private static const FEATURE_BACKOFF_NAME:String = "organicFertilizerBackoff";
      
      private static const FINAL_BACKOFF_INTERVAL:int = 7;
      
      private static const PLAYER_CAN_SEE_FEATURE_PREREQ_NAME:String = "allow_organic_fertilizer";
      
      private static const ITEM_NAME_ORGANIC_FERTILIZER:String = "consume_organic_fertilizer";
      
      protected static var m_msgDialog:FarmDynamicDialog = null;
      
      private static var m_hasSeenReminderToaster:Boolean = false;
      
      public function OrganicFertilizerHelper()
      {
         super();
      }
      
      public static function showMainWindow(freeUse:Boolean = false) : void
      {
         var organicFertilizerHelper:OrganicFertilizerHelper = null;
         var hasResourcesToActOn:Boolean = false;
         if(OrganicFertilizerHelper.playerCanSeeFeature())
         {
            organicFertilizerHelper = new OrganicFertilizerHelper();
            hasResourcesToActOn = organicFertilizerHelper.hasResourcesToActOn();
            if(!hasResourcesToActOn)
            {
               m_msgDialog = UI.showMessage(ZLocUtils.t("Dialogs","OrganicFertilizer_NoCropsBody"),UI.BUTTON_LAYOUT_OK,null,null,false,onNoCropsDialogClick);
            }
            else
            {
               UI.displayPopup(new OrganicFertilizerWindow(organicFertilizerHelper,freeUse),true,"OrganicFertilizerWindow",true);
            }
         }
      }
      
      public static function onNoCropsDialogClick(event:Event) : void
      {
         if(m_msgDialog)
         {
            m_msgDialog.destroy();
         }
         OrganicFertilizerHelper.showToasterFreeInGiftbox();
      }
      
      public static function isInSuperFertExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SUPER_FERTILIZER) > 0;
      }
      
      private static function passesToasterBackoffLogic() : Boolean
      {
         var result:Boolean = false;
         var backPrereqString1:String = "super_fertilizer_backoff_1";
         var backPrereqString2:String = "super_fertilizer_backoff_2";
         if(BackoffLogicManager.checkAndUpdateBackoffPrereq(backPrereqString1) || BackoffLogicManager.checkAndUpdateBackoffPrereq(backPrereqString2))
         {
            result = true;
         }
         return result;
      }
      
      public static function playerCanSeeFeature() : Boolean
      {
         return PrerequisiteUtility.checkPrereqByName(PLAYER_CAN_SEE_FEATURE_PREREQ_NAME);
      }
      
      public static function playerHasOrganicFertilizerInGiftbox() : Boolean
      {
         return getNumOrganicFertilizerInGiftbox() > 0;
      }
      
      public static function getNumOrganicFertilizerInGiftbox() : int
      {
         var result:* = Global.player.getGiftCountForItem(OrganicFertilizerHelper.ITEM_NAME_ORGANIC_FERTILIZER);
         if(result > 0 && Global.ui.hasEventListener(UIEvent.GIFTBOX_UNLOCKED))
         {
            result--;
         }
         return result;
      }
      
      public static function consumeOrganicFertilizerInGiftbox() : Boolean
      {
         var itemCode:String = null;
         var result:Boolean = false;
         if(Global.player.getGiftCountForItem(OrganicFertilizerHelper.ITEM_NAME_ORGANIC_FERTILIZER) > 0)
         {
            itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(ITEM_NAME_ORGANIC_FERTILIZER);
            if(itemCode != "")
            {
               result = Global.player.removeGiftWithKey(itemCode);
            }
         }
         return result;
      }
      
      public static function showToasterFreeInGiftbox() : void
      {
         var onClick:Function = null;
         var onCancel:Function = null;
         if(OrganicFertilizerHelper.playerCanSeeFeature() && OrganicFertilizerHelper.playerHasOrganicFertilizerInGiftbox())
         {
            onClick = function():void
            {
               Global.player.resetBackoffInterval(FEATURE_BACKOFF_NAME);
               OrganicFertilizerHelper.showMainWindow();
            };
            onCancel = function():void
            {
               Global.player.incrementBackoffInterval(FEATURE_BACKOFF_NAME);
            };
            showToasterPopOrganicFertilizerWindow(ZLocUtils.t("Dialogs","Toaster_OrganicFertilizerCancelMOTD_title"),ZLocUtils.t("Dialogs","Toaster_OrganicFertilizerCancelMOTD_text"),ZLocUtils.t("Dialogs","Toaster_OrganicFertilizerCancelMOTD_buttonText"),onClick,onCancel);
         }
      }
      
      public static function showToasterPopOrganicFertilizerWindow(localizedTitle:String, localizedText:String, localizedButtonText:String, clickCallback:Function = null, cancelCallback:Function = null) : void
      {
         if(!OrganicFertilizerHelper.m_hasSeenReminderToaster && OrganicFertilizerHelper.playerCanSeeFeature() && Global.player.canShowFeatureWithBackoff(FEATURE_BACKOFF_NAME,FINAL_BACKOFF_INTERVAL))
         {
            ToasterManager.getInstance().add(new ShareButtonToasterWindow(localizedTitle,localizedText,"assets/newsfeed/feed_superfertilizer70.png","assets/dialogs/FV_OrganicFertilizer2013_BannerAd.swf",1,new Point(5,12),clickCallback,cancelCallback,localizedButtonText));
            OrganicFertilizerHelper.m_hasSeenReminderToaster = true;
         }
      }
      
      override protected function getValidTypes() : uint
      {
         var result:uint = 0;
         if(OrganicFertilizerHelper.playerCanSeeFeature())
         {
            result = MapResourceHelper.TYPE_PLOTS;
         }
         return result;
      }
      
      override protected function featureEnabled() : Boolean
      {
         return OrganicFertilizerHelper.playerCanSeeFeature();
      }
      
      override protected function executeOnSingleObject(object:MapResource) : void
      {
         if(OrganicFertilizerHelper.playerCanSeeFeature())
         {
            if(!(object is HarvestableResource))
            {
               throw new Error("OrganicFertilizerHelper.as :: executeOnSingleObject() object is not a HarvestableResource: " + object.getItemName());
            }
            (object as HarvestableResource).setOrganicFertilized(true);
         }
      }
      
      public function sendTransaction() : void
      {
         var titleText:String = null;
         var bodyText:String = null;
         var iconAssetpath:String = null;
         if(OrganicFertilizerHelper.playerCanSeeFeature())
         {
            TransactionManager.addTransaction(new TGenericTransaction("OrganicFertilizerService","executeOrganicFertilizer",null,[getType()]));
            if(Global.flashHotParams["ORGANIC_FERT_PURGE_TOASTER_REMINDER_ON"] === true && !Global.player.getSeenSessionFlag(PURGE_REMINDER))
            {
               titleText = ZLocUtils.t("Dialogs","organic_fertilizer_purge_title");
               bodyText = ZLocUtils.t("Dialogs","organic_fertilizer_purge_body");
               iconAssetpath = "assets/newsfeed/part_organiccertifiedbagoffertilzier.png";
               ToasterManager.getInstance().add(new IconTitleToasterWindow(titleText,bodyText,iconAssetpath,IconTitleToasterWindow.DIALOG_ASSET,IconTitleToasterWindow.DEFAULT_ICON_SCALE,null,null,IconTitleToasterWindow.ICON_SIZE_50));
               Global.player.setSeenSessionFlag(PURGE_REMINDER);
            }
         }
      }
      
      override protected function cullWorldObjectAsNotActionable(worldObject:WorldObject) : Boolean
      {
         var result:Boolean = false;
         var plot:Plot = worldObject as Plot;
         if(Boolean(plot) && !plot.isOrganicFertilizable())
         {
            result = true;
         }
         return result || Boolean(super.cullWorldObjectAsNotActionable(worldObject));
      }
      
      override protected function getPlotsPrice(time:Number) : Number
      {
         var FERTILIZER_MULTIPLYIER:Number = NaN;
         var numPlots:uint = 0;
         var variantMultiplier:Number = NaN;
         var variant:int = 0;
         var MIN_FERTILIZER_COST:uint = 0;
         var result:Number = 0;
         if(isTypeActionable(TYPE_PLOTS) && Boolean(m_plots))
         {
            FERTILIZER_MULTIPLYIER = 3;
            numPlots = m_plots.length;
            variantMultiplier = 1;
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ORGANIC_FERTILIZER);
            switch(variant)
            {
               case 3:
                  variantMultiplier = 0.001;
                  break;
               case 4:
                  variantMultiplier = 0.00125;
                  break;
               case 5:
                  variantMultiplier = 0.0015;
                  break;
               case 6:
                  variantMultiplier = 0.00175;
                  break;
               case 7:
                  variantMultiplier = 0.002;
                  break;
               case 8:
                  variantMultiplier = 0.00225;
                  break;
               case 9:
                  variantMultiplier = 0.0025;
                  break;
               case 10:
                  variantMultiplier = 0.00275;
            }
            result = FERTILIZER_MULTIPLYIER * numPlots * variantMultiplier;
            MIN_FERTILIZER_COST = 3;
            result = Math.max(MIN_FERTILIZER_COST,result);
         }
         return result;
      }
   }
}

