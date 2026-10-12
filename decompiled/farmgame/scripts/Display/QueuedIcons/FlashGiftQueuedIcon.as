package Display.QueuedIcons
{
   import Classes.Constants.Experiments;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TShareFlashGiftFeed;
   import Widgets.Windows.MFSSendFlashGifts;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class FlashGiftQueuedIcon extends DynamicContentQueuedIcon
   {
      
      private static const FEATURE_FREQUENCY_KEY:String = "FlashGiftFeed";
      
      private static const VARIANT_REQUEST:int = 1;
      
      private static const VARIANT_FEED:int = 2;
      
      private var m_flashGiftItemName:String = null;
      
      private var m_flashGiftItem:FarmItem = null;
      
      private var m_dynamicIconQueueCallBack:Function = null;
      
      public function FlashGiftQueuedIcon(xml:XML)
      {
         super(xml);
      }
      
      public static function conditonallyAddFlashGiftIcon() : Boolean
      {
         var flashGiftItemName:String = null;
         var potentialFlashGiftItem:FarmItem = null;
         var shouldDisplayIcon:Boolean = false;
         var iconName:String = null;
         var timeInterval:int = 0;
         var currentCount:int = 0;
         var showFlashGiftOverride:Boolean = false;
         var result:Boolean = false;
         var flashGiftVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GIFTS);
         if(0 < flashGiftVariant)
         {
            flashGiftItemName = GlobalEngine.getFlashVar("flashGift") as String;
            if(flashGiftItemName != null)
            {
               potentialFlashGiftItem = Global.farmGameSettingsManager.getFarmItemByName(flashGiftItemName);
               if(potentialFlashGiftItem != null)
               {
                  if(potentialFlashGiftItem.code != null && potentialFlashGiftItem.code != "XX")
                  {
                     shouldDisplayIcon = false;
                     iconName = "";
                     if(flashGiftVariant == FlashGiftQueuedIcon.VARIANT_REQUEST)
                     {
                        if(potentialFlashGiftItem.isFlashGiftableViaRequest())
                        {
                           shouldDisplayIcon = true;
                        }
                        iconName = "FlashGiftSend";
                     }
                     else if(flashGiftVariant == FlashGiftQueuedIcon.VARIANT_FEED)
                     {
                        iconName = "FlashFeedGiftSend";
                        timeInterval = Global.farmGameSettingsManager.getInt(FlashGiftQueuedIcon.FEATURE_FREQUENCY_KEY + "TimeThrottle",7200);
                        currentCount = Global.player.getIntervalActionCount(FlashGiftQueuedIcon.FEATURE_FREQUENCY_KEY,timeInterval);
                        showFlashGiftOverride = GlobalEngine.getFlashVar("FLASHGIFTQUEUEDICON_CONDITIONALLYADDFLASHGIFTICON_OVERRIDE") as String == "true";
                        if(currentCount == 0 || showFlashGiftOverride)
                        {
                           shouldDisplayIcon = true;
                        }
                     }
                     if(shouldDisplayIcon == true && iconName != "")
                     {
                        Global.hud.iconQueue.addIconToTop(iconName,null,{"itemName":flashGiftItemName});
                        FarmStatsManager.count("flashgift",flashGiftItemName,"HUDicon","show",FlashGiftQueuedIcon.getExperimentVariantString());
                        result = true;
                     }
                  }
                  else
                  {
                     ErrorManager.addError("Item \'" + flashGiftItemName + "\' has non-unique item code.");
                  }
               }
            }
         }
         return result;
      }
      
      private static function getExperimentVariantString() : String
      {
         var result:String = "";
         var shareTypeVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GIFTS);
         if(shareTypeVariant == VARIANT_FEED)
         {
            result = "feed_variant";
         }
         else if(shareTypeVariant == VARIANT_REQUEST)
         {
            result = "request_variant";
         }
         return result;
      }
      
      override public function init() : void
      {
         var shareTypeVariant:int = 0;
         if(this.extraData != null)
         {
            if(this.extraData["itemName"] != null)
            {
               this.m_flashGiftItemName = this.extraData["itemName"];
               this.m_flashGiftItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_flashGiftItemName);
               if(this.m_flashGiftItem != null)
               {
                  shareTypeVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GIFTS);
                  if(shareTypeVariant == VARIANT_FEED)
                  {
                     this.extraData.iconTooltip = ZLocUtils.t("Dialogs","FlashGiftFeedSend_iconTooltip",{"item":ZLocUtils.tk_pk(this.m_flashGiftItem.friendlyName)});
                  }
                  else if(shareTypeVariant == VARIANT_REQUEST)
                  {
                     this.extraData.iconTooltip = ZLocUtils.t("Dialogs","FlashGiftSend_iconTooltip",{"item":ZLocUtils.tk_pk(this.m_flashGiftItem.friendlyName)});
                  }
               }
            }
         }
      }
      
      override public function displayPopup(callback:Function = null) : void
      {
         var shareTypeVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GIFTS);
         switch(shareTypeVariant)
         {
            case VARIANT_REQUEST:
               MFSRequestManager.getInstance().makeSendFlashGiftsRequest(this.m_flashGiftItemName,MFSSendFlashGifts.REF_FLASH_GIFT);
               break;
            case VARIANT_FEED:
               UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","FlashGiftFeed_share_prompt",{"item":ZLocUtils.tk_pk(this.m_flashGiftItem.friendlyName)}),GenericPopup.TYPE_SHARE,this.onShareFeed,this.m_flashGiftItem.icon,true));
         }
      }
      
      override public function finishClick(parent:DynamicIconQueue) : void
      {
         this.toolTip = "";
      }
      
      override protected function injectContent() : void
      {
         var imageLoader:ImageLoader = null;
         if(this.m_flashGiftItem != null)
         {
            imageLoader = ImageLoader.getInstance(this.m_flashGiftItem.icon);
            imageLoader.getContent(this.onItemIconLoaded);
         }
      }
      
      private function onItemIconLoaded(content:DisplayObject) : void
      {
         var mc:MovieClip = this.getContent() as MovieClip;
         if(mc)
         {
            if(mc.icon_mc)
            {
               content.scaleX = content.scaleY = 0.5;
               mc.icon_mc.addChild(content);
            }
         }
      }
      
      override public function doClickStats() : void
      {
         FarmStatsManager.count("flashgift",this.m_flashGiftItemName,"HUDicon","click",FlashGiftQueuedIcon.getExperimentVariantString());
      }
      
      private function onPopupClick(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("flashgift",this.m_flashGiftItemName,"dialog","accept",FlashGiftQueuedIcon.getExperimentVariantString());
         }
         else
         {
            FarmStatsManager.count("flashgift",this.m_flashGiftItemName,"dialog","cancel",FlashGiftQueuedIcon.getExperimentVariantString());
         }
         this.m_dynamicIconQueueCallBack(event);
      }
      
      private function onShareFeed(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("flashgift",this.m_flashGiftItemName,"dialog_share",FlashGiftQueuedIcon.getExperimentVariantString());
            TransactionManager.addTransaction(new TShareFlashGiftFeed(this.m_flashGiftItem,this.onShareFeedComplete),true);
         }
         else
         {
            FarmStatsManager.count("flashgift",this.m_flashGiftItemName,"dialog_cancel_share",FlashGiftQueuedIcon.getExperimentVariantString());
         }
      }
      
      private function onShareFeedComplete(transactionResult:Object) : void
      {
         var creativeBundleName:String = null;
         var rewardLink:String = null;
         var feedIcon:String = null;
         var bundleData:Object = null;
         if(transactionResult != null && transactionResult.successfulPost != null && transactionResult.successfulPost == true && transactionResult.rewardLink != null)
         {
            creativeBundleName = "flashGiftFeed";
            rewardLink = transactionResult.rewardLink;
            if(this.m_flashGiftItem != null)
            {
               feedIcon = this.m_flashGiftItem.icon;
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
               {
                  feedIcon = this.m_flashGiftItem.getImageByName("feed",true);
               }
               bundleData = {
                  "actor":Global.player.firstName,
                  "reward_link":rewardLink,
                  "reward_name":this.m_flashGiftItem.friendlyName,
                  "images":[{
                     "src":feedIcon,
                     "href":Config.SN_APP_URL + rewardLink
                  }]
               };
               if(GlobalEngine.socialNetwork.userHasStreamPermissions() && Boolean(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_INFEED_MINIGAME)))
               {
                  creativeBundleName = "flashGiftFeedMiniGame";
                  bundleData.images = [{
                     "src":Global.getAssetURL("assets/_hackathon/Mole_feedIcon.png"),
                     "href":Config.SN_APP_URL + rewardLink
                  }];
                  bundleData.source = Global.getAssetURL("assets/dialogs/FV_whack_feed.swf");
               }
               GlobalEngine.socialNetwork.publishFeedStory(creativeBundleName,bundleData,[],false);
            }
         }
      }
   }
}

