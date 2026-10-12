package Classes
{
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.HalloweenBasketDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.utils.Dictionary;
   
   public class HalloweenBasket extends RewardCreditsBuilding
   {
      
      public static const DIALOG_SIDE_ICON:String = "assets/decorations/deco_halloweencandy_icon.png";
      
      public static const ASK_FOR_CREDITS_FEATURE_NAME:String = "halloweenBasket";
      
      public static const HALLOWEEN_CANDY_5:String = "halloween_candy_5pack";
      
      private static const FLAG_HAS_OPENED_BASKET:String = "halloweenBasketOpen";
      
      private static const FLAG_HAS_PLACED_BASKET:String = "halloweenBasketPlaced";
      
      private const PASS_NEIGHBOR_FEED_ICON:String = "assets/decorations/deco_halloweenbasket_2_icon.png";
      
      private const CHANGE_FEED_ICON:String = "assets/decorations/deco_halloweenbasket_2_icon.png";
      
      private const INTERVAL_FEED_ICON:String = "assets/decorations/deco_halloweenbasket_1_icon.png";
      
      private const FIRST_TIME_FEED_ICON:String = "assets/decorations/deco_halloweenbasket_0_icon.png";
      
      private const LOCALE_PREFIX:String = "HalloweenBasket_";
      
      private const BUNDLE_PREFIX:String = "HalloweenBasket";
      
      private const NEIGHBOR_PASS_FEED_FLAG_NAME:String = "halloweenPassNeighbor";
      
      private const CENTER_ICON_VERTICAL_DISPLACE:int = 15;
      
      public function HalloweenBasket(buildingType:String = null)
      {
         super(buildingType,"halloweenBasket");
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         FarmStatsManager.count("halloweenbasket","open_basket");
         if(!Global.player.getSeenFlag(FLAG_HAS_OPENED_BASKET))
         {
            Global.player.setSeenFlag(FLAG_HAS_OPENED_BASKET);
            UI.displayStorageDialog(new HalloweenBasketDialog(this,true));
         }
         else
         {
            UI.displayStorageDialog(new HalloweenBasketDialog(this,false));
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         this.displayFirstTimePlaceDialog();
      }
      
      protected function displayFirstTimePlaceDialog() : void
      {
         var message:String = ZLocUtils.t("Dialogs","HalloweenBasket_FirstTimePlace");
         var iconPopup:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShare,Global.getAssetURL(this.PASS_NEIGHBOR_FEED_ICON));
         if(!Global.player.getSeenFlag(FLAG_HAS_PLACED_BASKET))
         {
            Global.player.setSeenFlag(FLAG_HAS_PLACED_BASKET);
            iconPopup.setTrackerKey("feed-halloween_basket-first_placement");
            UI.displayPopup(iconPopup,false);
         }
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         var messageType:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "reward_link":"gifts.php",
               "images":[{
                  "href":"{SN_APP_URL}" + "gifts.php",
                  "src":Global.getAssetURL(this.FIRST_TIME_FEED_ICON)
               }]
            };
            FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r1FlowCalled","halloween_basket");
            messageType = "HalloweenBasketFirstTimePlace";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
         this.displayStorageDialog();
      }
      
      override protected function getCenterIconVerticalDisplace() : int
      {
         return this.CENTER_ICON_VERTICAL_DISPLACE;
      }
      
      override public function getLocKeyPrefix() : String
      {
         return this.LOCALE_PREFIX;
      }
      
      override public function getBundlePrefix() : String
      {
         return this.BUNDLE_PREFIX;
      }
      
      override public function getDialogSideIconUrl() : String
      {
         return DIALOG_SIDE_ICON;
      }
      
      override public function getLevelIconUrl() : String
      {
         return "assets/decorations/deco_halloweenbasket_" + this.getCurrentSuffix() + "_icon.png";
      }
      
      override public function getCurrentSuffix() : int
      {
         var levelInfo:Dictionary = null;
         var suffix:uint = 0;
         var totalCreditsReceived:int = int(getTotalCreditsReceived());
         for(var index:uint = 0; index < m_levels.length; index++)
         {
            levelInfo = m_levels[index];
            if(totalCreditsReceived >= levelInfo["credits"])
            {
               suffix = index + 1;
               if(suffix > 4)
               {
                  suffix = 4;
               }
            }
         }
         return suffix;
      }
      
      override public function getChangeFeedIconUrl() : String
      {
         return this.CHANGE_FEED_ICON;
      }
      
      override public function getIntervalFeedIconUrl() : String
      {
         return this.INTERVAL_FEED_ICON;
      }
      
      override public function getPassNeighborFeedIconUrl() : String
      {
         return this.PASS_NEIGHBOR_FEED_ICON;
      }
      
      override protected function getNeighborPassFeedFlagName() : String
      {
         return this.NEIGHBOR_PASS_FEED_FLAG_NAME;
      }
      
      override protected function getOwnerToolTipText() : String
      {
         var currentCredits:uint = getCurrentCredits();
         return ZLocUtils.t("Items",m_item.name + "_capacity",{"quantity":currentCredits});
      }
      
      override protected function setStateStat() : void
      {
         FarmStatsManager.count("halloweenbasket","state_change",super.getTitle());
      }
      
      override protected function showStateChangeFeedPrompt() : void
      {
         var title:String = getTitle();
         var dialogTextTop:String = ZLocUtils.t("Dialogs",this.getLocKeyPrefix() + "StateChange_TopText",{"levelName":ZLocUtils.t_pk(title)});
         var dialogText:String = ZLocUtils.t("Dialogs",this.getLocKeyPrefix() + "StateChange_BodyText");
         var imageSize:Number = 100;
         var iconUrl:String = this.getDialogSideIconUrl();
         var centerIconUrl:String = this.getLevelIconUrl();
         var dialog:GenericXMLDialog = new GenericXMLDialog("Congratulations",dialogTextTop,null,centerIconUrl,imageSize,imageSize,dialogText,onCloseFeedPrompt,true,"Share",null,null,null,[imageSize.toString(),imageSize.toString(),iconUrl],GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM,"RewardCreditsBuildingFeedPrompt");
         UI.displayPopup(dialog,false);
      }
   }
}

