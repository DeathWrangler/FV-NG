package Classes
{
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.HaitiBackpackDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.utils.Dictionary;
   
   public class HaitiBackpack extends RewardCreditsBuilding
   {
      
      public static const DIALOG_SIDE_ICON:String = "assets/hud/haitiSchool_icon.png";
      
      public static const ASK_FOR_CREDITS_FEATURE_NAME:String = "haitiBackpack";
      
      public static const HAITI_BACKPACK_5:String = "haitibackpack_itempack_5";
      
      private const PASS_NEIGHBOR_FEED_ICON:String = "assets/decorations/haitibackpack_2_icon.png";
      
      private const CHANGE_FEED_ICON:String = "assets/newsfeed/haitiKid3.png";
      
      private const INTERVAL_FEED_ICON:String = "assets/newsfeed/haitiKid2.png";
      
      private const FIRST_TIME_FEED_ICON:String = "assets/newsfeed/haitiKid1.png";
      
      private const LOCALE_PREFIX:String = "HaitiBackpack_";
      
      private const BUNDLE_PREFIX:String = "HaitiBackpack";
      
      private const NEIGHBOR_PASS_FEED_FLAG_NAME:String = "haitiPassNeighbor";
      
      private const CENTER_ICON_VERTICAL_DISPLACE:int = 15;
      
      public function HaitiBackpack(buildingType:String = null)
      {
         super(buildingType,"haitiBackpack");
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         FarmStatsManager.count("haitibackpack","open_basket");
         if(!Global.player.getSeenFlag("haitiBackpackOpen"))
         {
            Global.player.setSeenFlag("haitiBackpackOpen");
            UI.displayStorageDialog(new HaitiBackpackDialog(this,true));
         }
         else
         {
            UI.displayStorageDialog(new HaitiBackpackDialog(this));
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         this.displayFirstTimePlaceDialog();
         this.displayStorageDialog();
      }
      
      protected function displayFirstTimePlaceDialog() : void
      {
         var message:String = ZLocUtils.t("Dialogs","HaitiBackpack_FirstTimePlace");
         var iconPopup:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShare,Global.getAssetURL(this.PASS_NEIGHBOR_FEED_ICON));
         iconPopup.setTrackerKey("feed-haiti_backpack-first_placement");
         UI.displayPopup(iconPopup);
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
            FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r1FlowCalled","haiti_backpack");
            messageType = "HaitiBackpackFirstTimePlace";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
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
         return "assets/decorations/schoolsupplies_icon.png";
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
               suffix = index;
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
         FarmStatsManager.count("haitibackpack","state_change",super.getTitle());
      }
   }
}

