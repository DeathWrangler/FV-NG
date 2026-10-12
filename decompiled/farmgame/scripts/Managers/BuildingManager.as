package Managers
{
   import Classes.Idle.BuildingRepromptIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericDynamicPopup;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.InventoryWithdrawal;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMBuild;
   import Transactions.TUpgradeStorage;
   
   public class BuildingManager
   {
      
      private static var m_instance:BuildingManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      public static const REPROMPT_DIALOG_ICON_WIDTH:int = 100;
      
      public static const REPROMPT_DIALOG_ICON_HEIGHT:int = 100;
      
      public static const REPROMPT_TO_FINISH:String = "prompt_to_complete";
      
      public static const REPROMPT_TO_PLACE:String = "prompt_to_place";
      
      public static const REPROMPT_TO_EXPAND_BUILDING:String = "prompt_to_upgrade_buildable";
      
      public static const REPROMPT_TO_BARNRAISE_BUILDING:String = "prompt_to_start_barn_raising";
      
      private var m_itemRepromptData:Object = null;
      
      private var m_itemRepromptedFor:FarmItem = null;
      
      protected var m_bundleData:Object = null;
      
      public function BuildingManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call constructor directly - use getInstance() instead.");
         }
      }
      
      public static function getInstance() : BuildingManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new BuildingManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function handlePostInitBuildingActions(buildingActionsData:Object) : void
      {
         var buildingRepromptIdleTask:BuildingRepromptIdleTask = null;
         var repromptData:Object = new Object();
         var repromptLag:int = 0;
         var mouseIdleSecs:int = 3;
         if(Boolean(buildingActionsData) && Boolean(buildingActionsData.repromptUserTo) && Boolean(buildingActionsData.buildingItemCode))
         {
            repromptData.repromptUserTo = buildingActionsData.repromptUserTo;
            repromptData.buildingItemCode = buildingActionsData.buildingItemCode;
            repromptData.buildingID = buildingActionsData.buildingID;
            if(buildingActionsData.publishFeedAction)
            {
               repromptData.publishFeedAction = buildingActionsData.publishFeedAction;
            }
            if(buildingActionsData.publishFeedHRef)
            {
               repromptData.publishFeedHRef = buildingActionsData.publishFeedHRef;
            }
            if(buildingActionsData.publishFeedIconURL)
            {
               repromptData.publishFeedIconURL = buildingActionsData.publishFeedIconURL;
            }
            if(buildingActionsData.addNameToGiftbox)
            {
               repromptData.addNameToGiftbox = buildingActionsData.addNameToGiftbox;
            }
            if(buildingActionsData.repromptTitleResource)
            {
               repromptData.repromptTitleResource = buildingActionsData.repromptTitleResource;
            }
            if(buildingActionsData.repromptTextResource)
            {
               repromptData.repromptTextResource = buildingActionsData.repromptTextResource;
            }
            if(buildingActionsData.repromptLag)
            {
               repromptLag = int(buildingActionsData.repromptLag);
            }
            if(buildingActionsData.mouseIdleSecs)
            {
               mouseIdleSecs = int(buildingActionsData.mouseIdleSecs);
            }
            buildingRepromptIdleTask = new BuildingRepromptIdleTask(repromptData,repromptLag,mouseIdleSecs);
            IdleTaskQueue.getInstance().addTask(buildingRepromptIdleTask);
         }
      }
      
      public function doBuildingReprompt(repromptData:Object) : void
      {
         var dialogWidth:Number = NaN;
         var dialogCloseCallback:Function = null;
         var dialogTitle:String = null;
         var dialogText:String = null;
         var dialogIconURL:String = null;
         var dialogIconWidth:Number = NaN;
         var dialogIconHeight:Number = NaN;
         var dialogButtonText:String = null;
         var showDialog:Boolean = false;
         this.m_itemRepromptData = repromptData;
         if(Boolean(!(this.m_itemRepromptData is String)) && Boolean(this.m_itemRepromptData.repromptUserTo) && Boolean(this.m_itemRepromptData.buildingItemCode))
         {
            this.m_itemRepromptedFor = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemRepromptData.buildingItemCode);
            if(this.m_itemRepromptedFor)
            {
               dialogIconURL = this.m_itemRepromptedFor.iconRelativeUrl;
               dialogIconWidth = BuildingManager.REPROMPT_DIALOG_ICON_WIDTH;
               dialogIconHeight = BuildingManager.REPROMPT_DIALOG_ICON_HEIGHT;
               dialogTitle = ZLocUtils.t("Dialogs",this.m_itemRepromptData.repromptTitleResource);
               dialogText = ZLocUtils.t("Dialogs",this.m_itemRepromptData.repromptTextResource);
               switch(this.m_itemRepromptData.repromptUserTo)
               {
                  case BuildingManager.REPROMPT_TO_FINISH:
                     dialogWidth = GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM;
                     dialogCloseCallback = this.onCloseFinishABuildingPrompt;
                     dialogButtonText = ZLocUtils.t("Dialogs","GenericShareButton");
                     showDialog = true;
                     break;
                  case BuildingManager.REPROMPT_TO_PLACE:
                     dialogWidth = GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM;
                     dialogCloseCallback = this.onClosePlaceABuildingPrompt;
                     dialogButtonText = ZLocUtils.t("Dialogs","GenericPlaceButton");
                     if(this.m_itemRepromptData.addNameToGiftbox)
                     {
                        Global.player.addGift(this.m_itemRepromptData.addNameToGiftbox);
                     }
                     showDialog = true;
                     break;
                  case BuildingManager.REPROMPT_TO_EXPAND_BUILDING:
                     dialogWidth = GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM;
                     dialogCloseCallback = this.onCloseExpandABuildingPrompt;
                     dialogButtonText = ZLocUtils.t("Dialogs","GenericShareButton");
                     showDialog = true;
                     break;
                  case BuildingManager.REPROMPT_TO_BARNRAISE_BUILDING:
                     dialogWidth = GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM;
                     dialogCloseCallback = this.onCloseBarnraisingPrompt;
                     dialogButtonText = ZLocUtils.t("Dialogs","GenericShareButton");
                     showDialog = true;
               }
            }
            if(showDialog)
            {
               FarmStatsManager.count("building_reprompt",this.m_itemRepromptData.repromptUserTo,"impressions",this.m_itemRepromptedFor.name);
               this.showRepromptDialog(dialogWidth,dialogTitle,dialogText,dialogCloseCallback,dialogIconURL,dialogIconWidth,dialogIconHeight,dialogButtonText);
            }
         }
      }
      
      private function showRepromptDialog(dialogWidth:int, dialogTitle:String, dialogText:String, dialogCloseCallback:Function, iconURL:String, iconWidth:Number, iconHeight:Number, buttonText:String) : void
      {
         var dialog:GenericDynamicPopup = new GenericDynamicPopup("BuildingReprompt",[dialogWidth,dialogTitle,iconURL,iconWidth,iconHeight,dialogText,buttonText],dialogCloseCallback);
         UI.displayPopup(dialog,false);
      }
      
      protected function onCloseFinishABuildingPrompt(event:GenericPopupEvent) : void
      {
         if(GenericPopup.ACCEPT == event.button)
         {
            FarmStatsManager.count("building_reprompt",this.m_itemRepromptData.repromptUserTo,"click_share",this.m_itemRepromptedFor.name);
            this.publishFeedStory();
         }
      }
      
      protected function onClosePlaceABuildingPrompt(event:GenericPopupEvent) : void
      {
         if(GenericPopup.ACCEPT == event.button)
         {
            FarmStatsManager.count("building_reprompt",this.m_itemRepromptData.repromptUserTo,"click_place",this.m_itemRepromptedFor.name);
            Global.world.addGameMode(new GMBuild(this.m_itemRepromptedFor.name,true,0));
         }
      }
      
      protected function onCloseExpandABuildingPrompt(event:GenericPopupEvent) : void
      {
         if(GenericPopup.ACCEPT == event.button)
         {
            FarmStatsManager.count("building_reprompt",this.m_itemRepromptData.repromptUserTo,"click_share",this.m_itemRepromptedFor.name);
            this.publishFeedStory();
         }
      }
      
      protected function onCloseBarnraisingPrompt(event:GenericPopupEvent) : void
      {
         var storage:StorageBuilding = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            FarmStatsManager.count("building_reprompt",this.m_itemRepromptData.repromptUserTo,"click_share",this.m_itemRepromptedFor.name);
            storage = Global.world.getObjectById(this.m_itemRepromptData.buildingID) as StorageBuilding;
            TransactionManager.addTransaction(new TUpgradeStorage(storage,null,"upgrade",this.publishBarnraisingFeedStory),true);
         }
      }
      
      private function publishBarnraisingFeedStory() : void
      {
         InventoryWithdrawal.sendPostUpgradeFeed();
      }
      
      private function publishFeedStory() : void
      {
         if(Boolean(this.m_itemRepromptData) && Boolean(this.m_itemRepromptData.publishFeedAction) && Boolean(this.m_itemRepromptData.publishFeedHRef) && Boolean(this.m_itemRepromptData.publishFeedIconURL))
         {
            this.m_bundleData = {
               "reward_link":this.m_itemRepromptData.publishFeedHRef,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_itemRepromptData.publishFeedHRef,
                  "src":this.m_itemRepromptData.publishFeedIconURL
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory(this.m_itemRepromptData.publishFeedAction,this.m_bundleData,[],false);
         }
      }
      
      protected function onConfirmShareFeed(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            GlobalEngine.socialNetwork.publishFeedStory(this.m_itemRepromptData.publishFeedAction,this.m_bundleData,[],false);
         }
      }
   }
}

