package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.feed.TurkeyRoostShareFeed;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.TurkeyRoostDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TCancelFriendReward;
   import Transactions.TGetAskForTurkeyRequestFeed;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TurkeyRoostBuilding extends AnimalStorageBuilding
   {
      
      private static const INITIAL_CAPACITY:int = 20;
      
      private static const EXPAND_SEEN_FLAG:String = "ExpandTurkeyRoost";
      
      public static const EXPAND_IMAGE_ICON_URL:String = "assets/buildings/building_turkeyroost_icon.png";
      
      private static const HALF_IMAGE_URL:String = "assets/buildings/building_turkeyroost_construct1_icon.png";
      
      public static const EXPAND_PART_IMAGE_ICON_PREFIX:String = "assets/newsfeed/turkeyroost_";
      
      public static const BUILDING_NAME:String = "TurkeyRoost";
      
      private static const ASK_TURKEYS:String = "AskForTurkeys";
      
      private static const FEATURE_ASK_TURKEYS:String = "AskForTurkeysFeature";
      
      public static const ASK_FOR_TURKEY_IMG_URL:String = "assets/animals/animal_turkey_icon.png";
      
      protected var m_harvestResult:Object = null;
      
      private const ADULT_FOUND_ICON_SCALE:Number = 0.7;
      
      private const TURKEY_ASK_BUNDLEID:String = "TurkeyRoostAskForTurkeys";
      
      protected var m_bundleData:Object = null;
      
      protected var m_feedAction:String = "";
      
      protected var m_callbackFunction:Function = null;
      
      private var m_turkeyRoostDialog:TurkeyRoostDialog;
      
      public function TurkeyRoostBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function showMenu() : void
      {
         if(this.busy)
         {
            showObjectBusy();
         }
         else
         {
            if(this.count != TurkeyRoostDialog.MAX_CAPACITY && this.isBuilt())
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("Dialogs","TurkeyRoostAskForTurkeys"),
                  "action":ASK_TURKEYS
               });
            }
            super.showMenu();
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         super.onMenuClick(event);
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(item.action == HARVEST_OBJECT)
            {
               this.busy = true;
            }
            if(item.action == ASK_TURKEYS)
            {
               this.onAskClick();
            }
         }
      }
      
      public function onAskClick(evt:MouseEvent = null) : void
      {
         var t:TGetAskForTurkeyRequestFeed = null;
         var canPublishFeed:Boolean = false;
         var lastShown:Number = Global.player.getFeatureLastShown(FEATURE_ASK_TURKEYS);
         var showInterval:Number = Global.farmGameSettingsManager.getNumber("TurkeyRoostAskForTurkeyFrequency",14400) * 1000;
         if(GlobalEngine.serverTime > lastShown + showInterval)
         {
            canPublishFeed = true;
         }
         if(canPublishFeed)
         {
            Global.player.setFeatureLastShown(FEATURE_ASK_TURKEYS,GlobalEngine.serverTime,true);
            t = new TGetAskForTurkeyRequestFeed(this,this.publishAskFeed);
            TransactionManager.addTransaction(t,true);
         }
         else
         {
            this.popCantAskForDialog();
         }
      }
      
      public function publishAskFeed(result:Object) : void
      {
         var feedAction:String = this.TURKEY_ASK_BUNDLEID;
         var feedImage:String = Global.getAssetURL(ASK_FOR_TURKEY_IMG_URL);
         var rewardLink:String = result.resultUrl;
         var bundleData:Object = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory(feedAction,bundleData,[],false);
      }
      
      private function popCantAskForDialog() : void
      {
         var time:Number = Global.farmGameSettingsManager.getNumber("TurkeyRoostAskForTurkeyFrequency",14400) / (60 * 60);
         var msg:String = ZLocUtils.t("Dialogs","TurkeyRoostFeedExpired",{"quantity":time});
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false,"Okay",null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(dialog,false);
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         this.m_turkeyRoostDialog = new TurkeyRoostDialog(this,TurkeyRoostDialog.ROOST_ENTRY);
         UI.displayPopup(this.m_turkeyRoostDialog,true,BUILDING_NAME + "MainDialog",true);
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var numTurkeys:int = 0;
         var cap:int = 0;
         var msg:String = null;
         var dialog:GenericXMLDialog = null;
         var success:Boolean = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         if(success)
         {
            numTurkeys = this.count;
            cap = this.capacity;
            if(cap == INITIAL_CAPACITY && Global.player.getSeenFlag(EXPAND_SEEN_FLAG) == false && numTurkeys == INITIAL_CAPACITY)
            {
               Global.player.setSeenFlag(EXPAND_SEEN_FLAG);
               msg = ZLocUtils.t("Dialogs","TurkeyRoostExpandNow");
               dialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,true,ZLocUtils.t("Dialogs","Okay"),this.onExpandNowAccept);
               UI.displayPopup(dialog,false);
            }
         }
         return success;
      }
      
      public function onExpandNowAccept(evt:Event = null) : void
      {
         this.m_turkeyRoostDialog = new TurkeyRoostDialog(this,TurkeyRoostDialog.EXPAND_ENTRY);
         UI.displayPopup(this.m_turkeyRoostDialog,true,BUILDING_NAME + "MainDialog",true);
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var feed:TurkeyRoostShareFeed = null;
         if(result.addGift)
         {
            this.displayStatus(ZLocUtils.t("FarmGame","TurkeyRoostHarvest",{"quantity":1}));
            Global.player.addGift("fruitcake");
         }
         if(Boolean(result.rewardUrl) && Boolean(result.itemCode))
         {
            feed = new TurkeyRoostShareFeed(Global.farmGameSettingsManager.getFarmItemByCode(result.itemCode),result.rewardUrl);
            feed.startFeedFlow();
         }
      }
      
      override protected function onCompleteExpansion(rewardLink:String, itemName:String) : void
      {
         this.reloadImage();
         var iconUrl:String = EXPAND_IMAGE_ICON_URL;
         this.m_feedAction = BUILDING_NAME + "ExpandComplete";
         var feedImage:String = Global.getAssetURL(iconUrl);
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var message:String = ZLocUtils.t("Dialogs",BUILDING_NAME + "ExpandComplete",{"item":ZLocUtils.tk_pk(itemFriendlyName)});
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,feedImage);
         dialog.setTrackerKey("feed-turkeyroost-upgrade_complete");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteHalfExpansion(rewardLink:String) : void
      {
         var iconUrl:String = EXPAND_IMAGE_ICON_URL;
         this.m_feedAction = BUILDING_NAME + "ExpandHalfComplete";
         var feedImage:String = Global.getAssetURL(iconUrl);
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var message:String = ZLocUtils.t("Dialogs",BUILDING_NAME + "ExpandHalfComplete");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,feedImage);
         dialog.setTrackerKey("feed-turkeyroost-upgrade_halfway");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteExpansionPart(rewardLink:String, itemName:String) : void
      {
         this.m_feedAction = BUILDING_NAME + "ExpandCompletePart";
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var itemFriendlyName:String = farmItem.friendlyName;
         var feedImage:String = Global.getAssetURL(EXPAND_PART_IMAGE_ICON_PREFIX + itemName + ".png");
         var partImage:String = farmItem.iconUrl;
         var dialogImage:String = partImage;
         this.m_bundleData = {
            "item":itemFriendlyName,
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var message:String = ZLocUtils.t("Dialogs",BUILDING_NAME + "ExpandPartComplete",{"item":ZLocUtils.tk_pk(itemFriendlyName)});
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,dialogImage);
         dialog.setTrackerKey("feed-turkeyroost-upgrade_material_complete");
         UI.displayPopup(dialog,false);
      }
      
      private function onShareExpansionReward(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            GlobalEngine.socialNetwork.publishFeedStory(this.m_feedAction,this.m_bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_bundleData["reward_link"]]));
         }
      }
   }
}

