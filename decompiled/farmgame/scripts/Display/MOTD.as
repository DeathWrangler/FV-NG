package Display
{
   import Classes.ChickenCoopBuilding;
   import Classes.Constants.CrossPromoConstants;
   import Classes.DairyFarmBuilding;
   import Classes.DealOfDayHelper;
   import Classes.MOTD.MOTDHandler;
   import Classes.MOTD.RepeatableMOTDHandler;
   import Classes.NurseryBuilding;
   import Classes.NurseryConstructionBuilding;
   import Classes.RewardCreditsBuilding;
   import Classes.RewardCreditsBuildingWithPresents;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Init.PostInitActionHandlers.PostInitPopup;
   import Managers.ChatManager;
   import Managers.Clubs.FarmClubUtility;
   import Managers.FaceOffManager;
   import Managers.FarmStatsManager;
   import Managers.HolidayCountdownManager;
   import Managers.LeaderboardManager;
   import Managers.LotteryManager;
   import Transactions.TSawMOTD;
   import Transactions.TSawSpecificMOTD;
   import Widgets.Windows.FCSlotMachineWindow;
   import Widgets.Windows.MOTD.SubscriptionsMOTDWindow;
   import Widgets.Windows.Mastery.MasteryWindow;
   import Widgets.Windows.ScratchCardWindow;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   
   public class MOTD extends DataDrivenOkayPopup
   {
      
      public static const SEEN_MOTD_SESSION_FLAG:String = "sawMotd";
      
      private static const MOTD_DIALOG_NAME_NORMAL:String = "MotdNormal";
      
      private static const MOTD_SOFT_XPROMO_CITYVILLE:String = "Cityville_forced_xpromo_softgate";
      
      private static const MOTD_SOFT_XPROMO_ADVWORLD:String = "Adventure_forced_xpromo_softgate";
      
      private static const MOTD_SOFT_XPROMO_CITYVILLE_PAYER:String = "Cityville_forced_xpromo_softgate_payer";
      
      private static const MOTD_SOFT_XPROMO_ADVWORLD_PAYER:String = "Adventure_forced_xpromo_softgate_payer";
      
      private static const MOTD_FRITO_LAY_WALMART_PROMO_INFO_URL:String = "http://company.zynga.com/crunch/?game=farmville&channel=MOTD&campaign=q1fritolay2012";
      
      private static var m_freeGiftUIOpenedFromMOTDAcceptance:Boolean = false;
      
      private static var m_cancelButtonPressed:Boolean = false;
      
      private var m_popGiftDialog:Boolean = false;
      
      private var m_currentMOTD:Object = {};
      
      private var m_sawMOTDTransactionSent:Boolean = false;
      
      public function MOTD(currentMOTD:Object)
      {
         this.m_currentMOTD = currentMOTD;
         FarmStatsManager.count("MOTD","impressions",this.m_currentMOTD.motdSeenFlag);
         Global.player.setSeenSessionFlag(SEEN_MOTD_SESSION_FLAG);
         var dialogName:String = MOTD_DIALOG_NAME_NORMAL;
         if(this.m_currentMOTD["dialog"].toString() != "")
         {
            dialogName = this.m_currentMOTD["dialog"].toString();
         }
         var params:Array = [this.m_currentMOTD["icon"].toString(),ZLocUtils.t_pk(this.m_currentMOTD["text"])];
         if(this.m_currentMOTD.hasOwnProperty("title"))
         {
            if(ZLocUtils.isObject(this.m_currentMOTD["title"]))
            {
               params.push(ZLocUtils.tk_pk_asTitle(this.m_currentMOTD["title"]));
            }
            else
            {
               params.push(ZLocUtils.t_pk(this.m_currentMOTD["title"]));
            }
         }
         if(this.m_currentMOTD.hasOwnProperty("buttonText"))
         {
            params.push(ZLocUtils.t_pk(this.m_currentMOTD["buttonText"]));
         }
         if(this.m_currentMOTD.hasOwnProperty("cancelButtonText"))
         {
            params.push(ZLocUtils.t_pk(this.m_currentMOTD["cancelButtonText"]));
         }
         if(this.m_currentMOTD.hasOwnProperty("infoButtonText"))
         {
            params.push(ZLocUtils.t_pk(this.m_currentMOTD["infoButtonText"]));
         }
         this.setTransactionForSoftXPromo(this.m_currentMOTD);
         super(dialogName,params);
      }
      
      public static function get freeGiftUIOpenedFromMOTDAcceptance() : Boolean
      {
         return m_freeGiftUIOpenedFromMOTDAcceptance;
      }
      
      public static function set freeGiftUIOpenedFromMOTDAcceptance(freeGiftUIOpenedFromMOTDAcceptance:Boolean) : void
      {
         m_freeGiftUIOpenedFromMOTDAcceptance = freeGiftUIOpenedFromMOTDAcceptance;
      }
      
      public static function get cancelButtonPressed() : Boolean
      {
         return m_cancelButtonPressed;
      }
      
      public static function set cancelButtonPressed(cancelButtonPressed:Boolean) : void
      {
         m_cancelButtonPressed = cancelButtonPressed;
      }
      
      public static function displayMOTD(currentMOTD:Object, postInitAction:Boolean = true, motdCloseCallback:Function = null, motdAcceptCallback:Function = null, addToQueue:Boolean = true) : Boolean
      {
         var motdClassName:String = null;
         var motdHandler:Class = null;
         var postMotdInst:MOTDHandler = null;
         var motdInst:RepeatableMOTDHandler = null;
         var newMOTDObj:MOTD = null;
         var result:Boolean = false;
         if(currentMOTD.action == "customHandler")
         {
            try
            {
               motdClassName = "Classes.MOTD." + String(currentMOTD.handlerType);
               motdHandler = getDefinitionByName(motdClassName) as Class;
               if(postInitAction)
               {
                  postMotdInst = new motdHandler(currentMOTD);
                  if(motdCloseCallback != null)
                  {
                     postMotdInst.addEventListener(Event.CANCEL,motdCloseCallback);
                  }
                  if(motdAcceptCallback != null)
                  {
                     postMotdInst.addEventListener(Event.COMPLETE,motdAcceptCallback);
                  }
                  Global.postInitActionsManager.addInitAction(postMotdInst);
               }
               else
               {
                  motdInst = new motdHandler(currentMOTD);
                  if(motdCloseCallback != null)
                  {
                     motdInst.addEventListener(Event.CANCEL,motdCloseCallback);
                  }
                  if(motdAcceptCallback != null)
                  {
                     motdInst.addEventListener(Event.COMPLETE,motdAcceptCallback);
                  }
                  motdInst.addToQueue = addToQueue;
                  motdInst.execute();
               }
               result = true;
            }
            catch(e:Error)
            {
               ErrorManager.addError("Error displaying MOTD: " + e,ErrorManager.ERROR_UNKNOWN,currentMOTD);
            }
         }
         else
         {
            newMOTDObj = new MOTD(currentMOTD);
            if(postInitAction)
            {
               Global.postInitActionsManager.addInitAction(new PostInitPopup(newMOTDObj,motdCloseCallback));
            }
            else
            {
               UI.displayPopup(newMOTDObj);
            }
            result = true;
         }
         return result;
      }
      
      private function setTransactionForSoftXPromo(currentMOTD:Object) : void
      {
         var motdSeenFlag:String = currentMOTD.motdSeenFlag;
         switch(motdSeenFlag)
         {
            case MOTD_SOFT_XPROMO_ADVWORLD:
            case MOTD_SOFT_XPROMO_CITYVILLE:
            case MOTD_SOFT_XPROMO_CITYVILLE_PAYER:
            case MOTD_SOFT_XPROMO_ADVWORLD_PAYER:
               this.sendTSawMOTDTransaction();
         }
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         StatsManager.milestone("decoration_md");
      }
      
      override protected function onMoreInfo(event:Event) : void
      {
         super.onMoreInfo(event);
         FarmStatsManager.count("MOTD","INFO",this.m_currentMOTD.motdSeenFlag);
         var moreInfoAction:String = this.m_currentMOTD.hasOwnProperty("moreInfoAction") ? this.m_currentMOTD["moreInfoAction"] : "";
         switch(moreInfoAction)
         {
            case "FritoLayWalmartPromo":
               GlobalEngine.socialNetwork.redirect(MOTD_FRITO_LAY_WALMART_PROMO_INFO_URL,null,"_blank",false);
         }
         this.onCloseHelper(event);
      }
      
      override protected function onAccept(event:Event) : void
      {
         var location:String;
         var actionParams:Object;
         var category:String;
         var forcedMOTD:Boolean;
         var itemList:Array = null;
         var coops:Array = null;
         var dairyfarms:Array = null;
         var storageBuildings:Array = null;
         var subCategory:String = null;
         var nurserybarns:Array = null;
         var buildingName:String = null;
         var buildings:Array = null;
         var rcbBuildingName:String = null;
         var rcbBuildings:Array = null;
         var storageBuildingName:String = null;
         var storageBuildingObjects:Array = null;
         var farmItem:FarmItem = null;
         var itemName:String = null;
         var invWith:InventoryWithdrawal = null;
         var launchMOTDUpgrade:Function = null;
         var building:RewardCreditsBuildingWithPresents = null;
         var rcBuilding:RewardCreditsBuilding = null;
         var storageBuilding:StorageBuilding = null;
         super.onAccept(event);
         location = this.m_currentMOTD["action"];
         actionParams = this.m_currentMOTD["actionParams"];
         FarmStatsManager.count("MOTD","OK",this.m_currentMOTD.motdSeenFlag);
         category = "";
         forcedMOTD = false;
         switch(location)
         {
            case "miniMarket":
               itemList = [];
               if(this.m_currentMOTD["itemList"].item is String)
               {
                  itemList.push(this.m_currentMOTD["itemList"].item);
               }
               else
               {
                  for each(itemName in this.m_currentMOTD["itemList"].item)
                  {
                     itemList.push(itemName);
                  }
               }
               category = this.m_currentMOTD["marketCategory"];
               UI.displayMiniMarketDialog(itemList,"motd",category);
               break;
            case "garage":
               UI.displayMiniMarketDialog(["garage"],"equipment","building",null);
               break;
            case "giftbox":
               this.m_popGiftDialog = true;
               break;
            case "placementModeForFreeGift":
               if(Boolean(this.m_currentMOTD.freeGift) && Boolean(this.m_currentMOTD.freeGiftClassName))
               {
                  m_freeGiftUIOpenedFromMOTDAcceptance = true;
               }
               break;
            case "placementModeForFreeGiftFromSeenMOTD":
               forcedMOTD = true;
               break;
            case "coop":
               coops = Global.world.getObjectsByClass(ChickenCoopBuilding);
               if(coops[0])
               {
                  launchMOTDUpgrade = function():void
                  {
                     invWith.launchUpgradeFeed(coops[0].getId());
                  };
                  UI.displayStorageDialog(invWith = new InventoryWithdrawal(null,"upgrade",true,launchMOTDUpgrade));
               }
               else
               {
                  UI.displayMarketDialog("motd","building",null,"animal_pens");
               }
               break;
            case "dairyfarm":
               dairyfarms = Global.world.getObjectsByClass(DairyFarmBuilding);
               if(dairyfarms[0])
               {
                  UI.displayStorageDialog(new InventoryWithdrawal(null,"upgrade",false));
               }
               else
               {
                  UI.displayMarketDialog("motd","building",null,"animal_pens");
               }
               break;
            case "storage":
               storageBuildings = Global.world.getObjectsByClass(StorageBuilding);
               if(storageBuildings[0])
               {
                  UI.displayStorageDialog(new InventoryWithdrawal(null,"upgrade",false));
               }
               else
               {
                  UI.displayMarketDialog("motd","building",null,"storage");
               }
               break;
            case "wishlist":
               FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r1FlowCalled","wishlist");
               GlobalEngine.socialNetwork.redirect("gifts.php?template=wishlist&ref=motd");
               break;
            case "market":
               category = this.m_currentMOTD["marketCategory"];
               subCategory = "all";
               if(this.m_currentMOTD["marketSubcategory"])
               {
                  subCategory = this.m_currentMOTD["marketSubcategory"];
               }
               UI.displayMarketDialog("motd",category,null,subCategory);
               break;
            case "cityvilleXPromo100M":
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.CITY_100M_XPROMO_URL,null,"_blank",false);
               break;
            case "cityvilleXPromo":
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.CITY_XPROMO_URL,null,"_blank",false);
               FarmStatsManager.count("MOTD","clicks",this.m_currentMOTD.motdSeenFlag);
               break;
            case "advWorldXPromo":
               GlobalEngine.socialNetwork.redirect(CrossPromoConstants.ADV_WORLD_XPROMO_URL,null,"_blank",false);
               FarmStatsManager.count("MOTD","clicks",this.m_currentMOTD.motdSeenFlag);
               break;
            case "lotteryWindow":
               LotteryManager.instance.queueMainUI();
               FarmStatsManager.count("MOTD","clicks",this.m_currentMOTD.motdSeenFlag);
               break;
            case "nurserybarn":
               nurserybarns = Global.world.getObjectsByClass(NurseryBuilding);
               if(nurserybarns[0])
               {
                  UI.displayStorageDialog(new NurseryWithdrawal(nurserybarns[0]));
               }
               else
               {
                  nurserybarns = Global.world.getObjectsByClass(NurseryConstructionBuilding);
                  if(nurserybarns[0])
                  {
                     UI.displayStorageDialog(new NurseryConstructionWithdrawal(nurserybarns[0]));
                  }
               }
               break;
            case "placeConstructOrExpand":
               this.executeActionPlaceConstructOrExpand();
               break;
            case "RewardCreditsWindow_presents":
               buildingName = this.m_currentMOTD["freeGift"];
               buildings = Global.world.getObjectsByName(buildingName);
               if(buildings[0])
               {
                  building = buildings[0];
                  building.showStoragePresentsTabOnLoad = true;
                  building.displayStorageDialog();
               }
               break;
            case "RewardCreditsWindow":
               rcbBuildingName = this.m_currentMOTD["freeGift"];
               rcbBuildings = Global.world.getObjectsByName(rcbBuildingName);
               if(rcbBuildings[0])
               {
                  rcBuilding = rcbBuildings[0];
                  rcBuilding.displayStorageDialog();
               }
               break;
            case "displayStorageDialog":
               storageBuildingName = this.m_currentMOTD["storageBuildingName"];
               storageBuildingObjects = Global.world.getObjectsByName(storageBuildingName);
               if(storageBuildingObjects[0])
               {
                  storageBuilding = storageBuildingObjects[0];
                  storageBuilding.displayStorageDialog();
               }
               break;
            case "holidayCountdown":
               HolidayCountdownManager.displayDialog();
               break;
            case "farmClubSurface":
               FarmClubUtility.showDialog();
               break;
            case "faceOff":
               FaceOffManager.getInstance().displayDialog();
               break;
            case "animalMasteryWindow":
               UI.displayPopup(new MasteryWindow(MasteryWindow.TYPE_ANIMAL));
               break;
            case "requestExtendedSNPerms":
               StatsManager.count("open_graph_permissions","dialog_confirm_click");
               Global.player.extendedPermissionState.requestExtendedPermissions();
               break;
            case "requestExtendedSNPermsWithGift":
               StatsManager.count("open_graph_permissions_2","dialog_confirm_click");
               Global.player.extendedPermissionState.requestExtendedPermissionsWithGift();
               break;
            case "showSuggestionHubOverlay":
               FarmStatsManager.sample(100,"fv_fbml_depr_inspect","showSuggestionHubOverlay","called");
               ExternalUtil.instance.call("theFarmOverlay.showSuggestionHubOverlay");
               break;
            case "scratchCard":
               UI.displayPopup(new ScratchCardWindow(ScratchCardWindow.SCRATCH_CARD_ENTRY_DESCRIPTOR_MOTD),true,ScratchCardWindow.POPUP_NAME,true);
               break;
            case "slotMachine":
               FarmStatsManager.count("slots","motd_clicked");
               UI.displayPopup(new FCSlotMachineWindow(FCSlotMachineWindow.ENTRY_POINT_MOTD),true,FCSlotMachineWindow.WINDOW_NAME,true);
               break;
            case "redirectToURL":
               FarmStatsManager.count("MOTD","clicks",this.m_currentMOTD.motdSeenFlag);
               Global.farmSocialNetwork.redirectTop(actionParams["redirectURL"]);
               break;
            case "farmTalkSurface":
               ChatManager.farmTalkSurface();
               break;
            case "leaderboard":
               LeaderboardManager.displayLeaderboardWindow();
               FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","MOTD");
               break;
            case "subscriptionsTrial":
               UI.displayPopup(new SubscriptionsMOTDWindow());
               FarmStatsManager.count("subscriptions","clicks","MOTD");
               break;
            case "miniMarketWithDealOfDay":
               farmItem = DealOfDayHelper.getDealOfDayItem();
               if(farmItem)
               {
                  category = this.m_currentMOTD["marketCategory"];
                  UI.displayMiniMarketDialog([farmItem.name],"MOTD",category);
               }
         }
         this.onCloseHelper(event,forcedMOTD);
      }
      
      private function getBuildingsFromClassName(className:String) : Array
      {
         var objectClass:Class = null;
         var buildings:Array = null;
         className = className;
         if(className != null && className != "")
         {
            objectClass = getDefinitionByName(className) as Class;
            if(objectClass != null)
            {
               buildings = Global.world.getObjectsByClass(objectClass);
            }
         }
         return buildings;
      }
      
      private function executeActionPlaceConstructOrExpand() : void
      {
         var constructionBuildings:Array = Global.world.getObjectsByName(this.m_currentMOTD.action.@itemConstruct);
         var finishedBuildings:Array = Global.world.getObjectsByName(this.m_currentMOTD.action.@itemExpand);
         if(finishedBuildings != null && Boolean(finishedBuildings[0]))
         {
            if("displayExpandDialog" in finishedBuildings[0])
            {
               finishedBuildings[0].displayExpandDialog();
            }
         }
         else if(constructionBuildings != null && Boolean(constructionBuildings[0]))
         {
            constructionBuildings[0].displayStorageDialog();
         }
         else
         {
            this.m_currentMOTD["action"] = "placementModeForFreeGift";
         }
      }
      
      protected function sendTSawMOTDTransaction() : void
      {
         if(!this.m_sawMOTDTransactionSent)
         {
            TransactionManager.addTransaction(new TSawMOTD(this.m_currentMOTD),true);
            this.m_sawMOTDTransactionSent = true;
         }
      }
      
      protected function sendTSawSpecificMOTDTransaction() : void
      {
         TransactionManager.addTransaction(new TSawSpecificMOTD(this.m_currentMOTD,true),true);
      }
      
      protected function onCloseHelper(event:Event, forcedMOTD:Boolean = false) : void
      {
         if(forcedMOTD)
         {
            this.sendTSawSpecificMOTDTransaction();
         }
         else
         {
            this.sendTSawMOTDTransaction();
         }
         if(this.m_popGiftDialog)
         {
            UI.displayGiftBoxWindow();
         }
         event.stopPropagation();
         StatsManager.milestone("invite_complete");
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         FarmStatsManager.count("MOTD","cancel",this.m_currentMOTD.motdSeenFlag);
         m_cancelButtonPressed = true;
         var cancelAction:String = this.m_currentMOTD["cancelAction"];
         switch(cancelAction)
         {
            case "placeFreeGiftInGiftBox":
         }
         this.onCloseHelper(event);
      }
      
      override public function get shouldFreeze() : Boolean
      {
         return false;
      }
   }
}

