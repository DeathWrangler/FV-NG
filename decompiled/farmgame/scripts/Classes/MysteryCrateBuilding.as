package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.MFSRequestManager;
   import Managers.ToasterManager;
   import Transactions.TGenericWorldObjectTransaction;
   import Transactions.TMysteryCrateAskForMore;
   import Widgets.Windows.IconToasterWindow;
   import Widgets.Windows.MysteryCrateHoverOverWindow;
   import Widgets.Windows.MysteryCrateRewardWindow;
   import flash.events.MouseEvent;
   
   public class MysteryCrateBuilding extends ConstructionBuilding
   {
      
      public static const ASK_PARTS_FEED:String = "feed";
      
      public static const ASK_PARTS_R4R:String = "r4r";
      
      public static const PART_TYPE_SCISSORS:String = "Scissors";
      
      public static const PART_TYPE_SNIPS:String = "Snips";
      
      public static const SCISSORS_PART_NAME:String = "part_scissors";
      
      public static const SNIPS_PART_NAME:String = "part_snips";
      
      public static const FEED_STATUS_READY:String = "ready";
      
      public static const FEED_STATUS_POSTED:String = "posted";
      
      public static const MYSTERY_CRATE:String = "mystery_crate";
      
      public static const START_STAT:String = "start";
      
      public static const CLICKED_STAT:String = "clicked";
      
      public static const BUY_STAT:String = "fv_cash_buy";
      
      public static const COMPLETED_CONTEXT_MENU_STAT:String = "context_menu_complete";
      
      public static const AFTER_EXPIRED_STAT:String = "after_expired";
      
      public static const FEED_STAT:String = "feed";
      
      public static const REQUEST_STAT:String = "request";
      
      public static const REQUEST_MORE_STAT:String = "request_more";
      
      public static const REQUEST_TYPE_STAT:String = "MFS_3x1x";
      
      public static const COMPLETED_STAT:String = "completed";
      
      public static const CLICKED_CONTEXT_MENU_STAT:String = "context_menu_clicked";
      
      public static const WHAT_IS_THIS_STAT:String = "whatIsThis";
      
      public static const COMPLETE_NOW_STAT:String = "completeNow";
      
      public static const ASK_PARTS_STAT:String = "askParts";
      
      private static const ZERO_PRICE_STAT:String = "zeroPrice";
      
      private static const NULL_PART_STAT:String = "nullPart";
      
      public static const VIRAL_POST_FREQUENCY_FLAG:String = "mysteryCrateFeedPost";
      
      public static const ACTION_REMOVE:String = "RemoveMysteryCrate";
      
      public static const ACTION_REMOVE_BUILDING:String = "RemoveMysteryCrateBuilding";
      
      public static const ACTION_COMPLETE_NOW:String = "CompleteNow";
      
      public static const ACTION_MYSTERY_CRATE_COMPLETE_NOW:String = "MysteryCrateCompleteNow";
      
      public static const ACTION_REQUEST_PART:String = "RequestExpansionPart";
      
      public static const ACTION_UPDATE_VIRAL_TIME:String = "UpdateViralTime";
      
      public static const MYSTERY_CRATE_FEED_POST_COOLDOWN_DEFAULT:int = 2;
      
      public static const MYSTERY_CRATE_ENGAGEMENT_HOURS:int = 2;
      
      public static const DEFAULT_EXPIRY_HOURS:int = 24;
      
      private var m_hoverWindow:MysteryCrateHoverOverWindow;
      
      private var m_rewardWindow:MysteryCrateRewardWindow;
      
      private var m_hoverCallbackObject:Object = null;
      
      private var m_part:PartItem;
      
      private var m_partName:String;
      
      private var m_hoursUntilExpiry:int = 0;
      
      private var m_requestTypeToUse:String = null;
      
      private var m_remove:Boolean = true;
      
      private var m_feedPostingState:String = "ready";
      
      private var m_applyLoadCheck:Boolean = false;
      
      public function MysteryCrateBuilding(buildingType:String = null)
      {
         super(buildingType);
         if(!Global.worldManager.isVisiting())
         {
            this.m_hoverCallbackObject = {
               "howItWorksCallback":this.onHowItWorksClick,
               "completeNowCallback":this.completeNow,
               "getCashNeededCallback":this.getCashNeeded,
               "getTotalPartsCallback":this.getTotalNumPartsNeeded,
               "getCurrentPartsCallback":this.getCountInBuilding,
               "getExpiryTimeCallback":this.getExpiryTimeText,
               "askForHelpCallback":this.onAskForHelp,
               "getCurrentGiftPartsCallback":this.getGiftboxPartCount,
               "usePartsCallBack":this.useParts
            };
            if(!Global.player.postInitFinished)
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.displayEngagementToaster,false,0,true);
            }
            this.m_applyLoadCheck = GlobalEngine.getFlashVar("FEATURE_FLASHPARAM_MYSTERY_CRATE_APPLY_LOAD_CHECK");
         }
      }
      
      override public function onMouseOut() : void
      {
         if(!Global.worldManager.isVisiting())
         {
            if(this.m_hoverWindow != null)
            {
               this.m_hoverWindow.beginCloseTimer();
            }
         }
         super.onMouseOut();
      }
      
      private function setViralChannel() : void
      {
         switch(Global.flashHotParams["MYSTERY_CRATE_VIRAL_CHANNEL"])
         {
            case ASK_PARTS_R4R:
               this.m_requestTypeToUse = ASK_PARTS_R4R;
               break;
            case ASK_PARTS_FEED:
            default:
               this.m_requestTypeToUse = ASK_PARTS_FEED;
         }
      }
      
      override public function onFullyFinished(result:Object, transformedObj:MapResource = null) : void
      {
      }
      
      override protected function onMaterialComplete(result:Object) : void
      {
      }
      
      override protected function onIncrementFinished(result:Object) : void
      {
      }
      
      override protected function onHalfWayFinished(result:Object) : void
      {
      }
      
      public function setPartType() : void
      {
         var partItem:FarmItem = null;
         switch(Global.flashHotParams["MYSTERY_CRATE_PART_TYPE"])
         {
            case SNIPS_PART_NAME:
               this.m_partName = PART_TYPE_SNIPS;
               partItem = Global.farmGameSettingsManager.getFarmItemByName(SNIPS_PART_NAME);
               break;
            case SCISSORS_PART_NAME:
            default:
               this.m_partName = PART_TYPE_SCISSORS;
               partItem = Global.farmGameSettingsManager.getFarmItemByName(SCISSORS_PART_NAME);
         }
         if(Boolean(partItem) || !this.m_applyLoadCheck)
         {
            this.m_part = new PartItem(partItem,this.getTotalNumPartsNeeded());
         }
         if(this.m_part != null && partItem == null)
         {
            FarmStatsManager.count(MYSTERY_CRATE,MYSTERY_CRATE,NULL_PART_STAT);
         }
      }
      
      private function setHoursUntilExpiry() : void
      {
         var timePlaced:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.MYSTERY_CRATE,FeatureOptionsManager.MYSTERY_CRATE_PLACED_TIME,timePlaced);
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.MYSTERY_CRATE,FeatureOptionsManager.MYSTERY_CRATE_LEVEL,1);
         timePlaced /= FarmGameUtil.NUM_SECS_IN_HOUR;
         var expiryHours:int = int(Global.flashHotParams["MYSTERY_CRATE_EXPIRY_HOURS"]);
         if(expiryHours <= 0)
         {
            expiryHours = DEFAULT_EXPIRY_HOURS;
         }
         this.m_hoursUntilExpiry = timePlaced + expiryHours;
      }
      
      private function getHoursPlaced() : int
      {
         var timePlaced:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_HOUR;
         var value:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.MYSTERY_CRATE,FeatureOptionsManager.MYSTERY_CRATE_PLACED_TIME);
         if(value != null || value is Number)
         {
            timePlaced = (value as int) / FarmGameUtil.NUM_SECS_IN_HOUR;
         }
         return timePlaced;
      }
      
      private function getHoursUntilExpiry() : void
      {
         var timePlaced:int = this.getHoursPlaced();
         var expiryHours:int = int(Global.flashHotParams["MYSTERY_CRATE_EXPIRY_HOURS"]);
         if(expiryHours <= 0)
         {
            expiryHours = DEFAULT_EXPIRY_HOURS;
         }
         this.m_hoursUntilExpiry = timePlaced + expiryHours;
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         var currentTime:int = 0;
         if(this.m_applyLoadCheck)
         {
            super.onMouseOver(event);
         }
         if(!Global.worldManager.isVisiting())
         {
            this.setPartType();
            if(this.hasValidPart())
            {
               this.setViralChannel();
               this.getHoursUntilExpiry();
               currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_HOUR;
               this.setFeedPostingState();
               if(currentTime < this.m_hoursUntilExpiry)
               {
                  this.showHoverMenu(getPosition(),getItem(),this.m_part);
               }
               else
               {
                  this.removeMysteryCrateBuilding();
                  TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this,ACTION_REMOVE_BUILDING));
               }
            }
         }
         if(!this.m_applyLoadCheck)
         {
            super.onMouseOver(event);
         }
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
      }
      
      override protected function showStorageContextMenu() : Boolean
      {
         return false;
      }
      
      override public function getTunedPartRequirement(partXML:*, level:int, partDataSource:BaseDataSource = null) : int
      {
         var result:int = 0;
         if(this.getTotalNumPartsNeeded() > 0)
         {
            result = this.getTotalNumPartsNeeded();
         }
         else
         {
            result = super.getTunedPartRequirement(partXML,level,partDataSource);
         }
         return result;
      }
      
      private function canGrantReward() : Boolean
      {
         var level:int = 0;
         var value:int = 0;
         var result:Boolean = false;
         if(Boolean(this.getCountInBuilding(this.m_part.item)) && this.getCountInBuilding(this.m_part.item) % int(this.getTotalNumPartsNeeded() / 3) == 0)
         {
            level = this.getCountInBuilding(this.m_part.item) / int(this.getTotalNumPartsNeeded() / 3);
            value = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.MYSTERY_CRATE,FeatureOptionsManager.MYSTERY_CRATE_LEVEL) as int;
            if(value == level)
            {
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.MYSTERY_CRATE,FeatureOptionsManager.MYSTERY_CRATE_LEVEL,level + 1);
               result = true;
            }
         }
         return result;
      }
      
      override public function onObjectDrop() : void
      {
         super.onObjectDrop();
         this.setHoursUntilExpiry();
         FarmStatsManager.count(MYSTERY_CRATE,MYSTERY_CRATE,START_STAT);
      }
      
      override protected function updateToolTipText() : void
      {
         setToolTip("");
         updateToolTipPosition();
      }
      
      private function showHoverMenu(position:Vector3, item:FarmItem, part:PartItem) : void
      {
         FarmStatsManager.count(MYSTERY_CRATE,MYSTERY_CRATE,CLICKED_STAT);
         this.m_hoverWindow = new MysteryCrateHoverOverWindow(position,item,part,this.m_feedPostingState,this.m_hoverCallbackObject);
         UI.addHoverWindow(this.m_hoverWindow);
         TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this,"Check"));
      }
      
      protected function onHowItWorksClick() : void
      {
         this.setPartType();
         var coolDownHours:int = Global.flashHotParams["MYSTERY_CRATE_COOL_DOWN_HOURS"] != null ? int(Global.flashHotParams["MYSTERY_CRATE_COOL_DOWN_HOURS"]) : MYSTERY_CRATE_FEED_POST_COOLDOWN_DEFAULT;
         var dialogText:String = ZLocUtils.t("Dialogs","mysterycrate_How_it_works_text",{
            "part":this.m_partName,
            "numParts":this.getTotalNumPartsNeeded() / 3,
            "hours":coolDownHours
         });
         var dialogTitle:String = ZLocUtils.t("Dialogs","mysterycrate_How_it_works_title");
         UI.showMessage(dialogText,1,dialogTitle);
      }
      
      private function completeNow() : void
      {
         if(Global.player.canBuyCash(this.getCashNeeded(),true))
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","mysterycrate_complete_text",{"cashQuantity":this.getCashNeeded().toString()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompletePopupClose,"",true);
         }
      }
      
      private function onConfirmCompletePopupClose(event:GenericPopupEvent) : void
      {
         if(this.hasValidPart())
         {
            if(event.button == GenericPopup.YES)
            {
               FarmStatsManager.count(BUY_STAT,MYSTERY_CRATE,this.m_part.item.name,this.getCashNeeded().toString(),COMPLETED_CONTEXT_MENU_STAT);
               this.frictionlessCompleteNow();
            }
         }
      }
      
      private function showBuyDialog() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","mysterycrate_buy_text",{
            "part":this.m_partName,
            "cost":this.getCashNeeded().toString()
         }),GenericPopup.TYPE_YESNO,this.onConfirmBuyDialogPopupClose,"",true);
      }
      
      private function onConfirmBuyDialogPopupClose(event:GenericPopupEvent) : void
      {
         if(this.hasValidPart())
         {
            if(event.button == GenericPopup.YES)
            {
               if(Global.player.canBuyCash(this.getCashNeeded(),true))
               {
                  FarmStatsManager.count(BUY_STAT,MYSTERY_CRATE,this.m_part.item.name,this.getCashNeeded().toString(),AFTER_EXPIRED_STAT);
                  this.frictionlessCompleteNow();
               }
            }
            if(this.m_remove)
            {
               this.removeMysteryCrateBuilding();
               TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this,ACTION_REMOVE_BUILDING));
            }
         }
      }
      
      private function displaySuccessToaster(rewardName:String) : void
      {
         var toasterMessage:String = ZLocUtils.t("Dialogs","mysterycrate_success_toaster_text",{"prize":ZLocUtils.tk_pk(rewardName)});
         var icon:String = m_item.iconUrl;
         ToasterManager.getInstance().togglePause(false);
         ToasterManager.getInstance().add(new IconToasterWindow(icon,toasterMessage));
      }
      
      private function displayEngagementToaster(event:FarmGameWorldEvent) : void
      {
         var toasterMessage:String = null;
         var icon:String = null;
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.displayEngagementToaster);
         this.setPartType();
         var lastViralTaskTime:int = Global.player.getFeatureLastShown(VIRAL_POST_FREQUENCY_FLAG) / FarmGameUtil.NUM_SECS_IN_HOUR;
         var timePlaced:int = this.getHoursPlaced();
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_HOUR;
         var engagementHours:Number = Global.flashHotParams["MYSTERY_CRATE_ENGAGMENT_HOURS"] != null ? Number(Global.flashHotParams["MYSTERY_CRATE_ENGAGMENT_HOURS"]) : MYSTERY_CRATE_ENGAGEMENT_HOURS;
         if(lastViralTaskTime != 0 && currentTime - lastViralTaskTime >= engagementHours || lastViralTaskTime == 0 && currentTime - timePlaced >= engagementHours)
         {
            toasterMessage = ZLocUtils.t("Dialogs","mysterycrate_engagement_toaster_text",{
               "partNeeded":this.getNumPartsNeeded(),
               "part":this.m_partName
            });
            icon = m_item.iconUrl;
            ToasterManager.getInstance().togglePause(false);
            ToasterManager.getInstance().add(new IconToasterWindow(icon,toasterMessage));
         }
      }
      
      override public function frictionlessCompleteNow(transformBuildingOnComplete:Boolean = false, callback:Function = null) : void
      {
         var currentItemName:String = null;
         var cashNeeded:int = this.getCashNeeded();
         var purchaseStatName:String = "Other";
         if(Global.player.canBuyCash(cashNeeded,true,purchaseStatName))
         {
            currentItemName = getItem().name;
            if(this.canRemove())
            {
               Global.player.removeLimitedItem(currentItemName);
            }
            this.m_remove = false;
            Global.player.cash -= cashNeeded;
            TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this,ACTION_MYSTERY_CRATE_COMPLETE_NOW),true);
            BuildingItemUseMediator.getInstance().mediate(this.m_part.item.name,false,this,true,false,this.getNumPartsNeeded());
            if(this.canGrantReward() || isFullyBuilt())
            {
               this.removeMysteryCrate();
               TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this,ACTION_COMPLETE_NOW,this.onCompleteMysteryCrate),true);
            }
         }
      }
      
      override protected function getMaterialsNeeded() : int
      {
         var result:int = 0;
         if(this.getTotalNumPartsNeeded() > 0)
         {
            result = this.getTotalNumPartsNeeded();
         }
         return result;
      }
      
      override public function getCurrentSuffix() : int
      {
         var initialExpansionLevel:int = 0;
         var intervalBreak:Number = NaN;
         var result:int = 0;
         var numImageStates:int = m_numImageStates;
         var capacity:int = m_capacity;
         if(!m_isFullyBuilt)
         {
            numImageStates = m_numConstructImageStates;
            capacity = this.getMaterialsNeeded();
            if(m_count < capacity)
            {
               numImageStates++;
            }
         }
         if(numImageStates > 1)
         {
            intervalBreak = capacity / (numImageStates - 1);
            result = int(Math.floor(m_count / intervalBreak));
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_item.hasPropertyInDataSource("initialExpansionLevel"))
            {
               initialExpansionLevel = m_item.getIntFromDataSource("initialExpansionLevel");
               result = Math.max(result,initialExpansionLevel);
            }
         }
         else if(m_item.xml.hasOwnProperty("initialExpansionLevel"))
         {
            initialExpansionLevel = int(m_item.xml.initialExpansionLevel);
            result = Math.max(result,initialExpansionLevel);
         }
         return result;
      }
      
      override public function getTotalPartsNeededForItem(itemCode:String) : int
      {
         var result:int = 0;
         if(this.getTotalNumPartsNeeded() <= 0)
         {
            result = super.getTotalPartsNeededForItem(itemCode);
         }
         else
         {
            result = this.getTotalNumPartsNeeded();
         }
         return result;
      }
      
      private function getCountInBuilding(item:FarmItem) : int
      {
         return getCurrentLevelConstructionItemCount(item.code);
      }
      
      private function useParts(item:FarmItem) : void
      {
         var giftBoxPartCount:int = this.getGiftboxPartCount(item);
         if(giftBoxPartCount > 0)
         {
            BuildingItemUseMediator.getInstance().mediate(item.name,true,this,true,false,1,false);
            if(this.canGrantReward() || isFullyBuilt())
            {
               TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this,ACTION_COMPLETE_NOW,this.onCompleteMysteryCrate));
               this.removeMysteryCrate();
            }
         }
      }
      
      private function getGiftboxPartCount(item:FarmItem) : int
      {
         return Global.player.getGiftCountForItem(item.name);
      }
      
      private function getTotalNumPartsNeeded() : Number
      {
         return Global.flashHotParams["MYSTERY_CRATE_NUMBER_OF_PARTS_NEEDED"];
      }
      
      override public function getCashNeeded(partcost:int = 1) : Number
      {
         var result:int = 0;
         if(this.hasValidPart())
         {
            partcost = this.m_part.item.cash;
            result = partcost * this.getNumPartsNeeded();
         }
         if(result == 0)
         {
            FarmStatsManager.count(MYSTERY_CRATE,MYSTERY_CRATE,ZERO_PRICE_STAT);
         }
         return result as Number;
      }
      
      private function getNumPartsNeeded() : int
      {
         var currentParts:int = 0;
         var totalParts:int = 0;
         var result:int = 0;
         if(this.hasValidPart())
         {
            currentParts = getCurrentLevelConstructionItemCount(this.m_part.item.code);
            totalParts = this.getTotalNumPartsNeeded();
            result = totalParts / 3 - currentParts % (totalParts / 3);
         }
         return result < 0 ? 0 : result;
      }
      
      private function getExpiryTimeText() : String
      {
         var result:String = "";
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_HOUR;
         var hoursLeft:int = this.m_hoursUntilExpiry - currentTime;
         var days:int = 0;
         if(hoursLeft >= FarmGameUtil.NUM_HOURS_IN_DAY)
         {
            days = Math.floor(hoursLeft / FarmGameUtil.NUM_HOURS_IN_DAY);
            hoursLeft -= days * FarmGameUtil.NUM_HOURS_IN_DAY;
         }
         if((days > 1 || days == 0) && (hoursLeft > 1 || hoursLeft == 0))
         {
            result = ZLocUtils.t("Dialogs","mysterycrate_days_hours",{
               "days":days.toString(),
               "hours":hoursLeft.toString()
            });
         }
         else if((days > 1 || days == 0) && hoursLeft == 1)
         {
            result = ZLocUtils.t("Dialogs","mysterycrate_days_hour",{"days":days.toString()});
         }
         else if(days == 1 && (hoursLeft > 1 || hoursLeft == 0))
         {
            result = ZLocUtils.t("Dialogs","mysterycrate_day_hours",{"hours":hoursLeft.toString()});
         }
         else
         {
            result = ZLocUtils.t("Dialogs","mysterycrate_day_hour");
         }
         return result;
      }
      
      private function onAskForHelp() : void
      {
         var currentTime:int = 0;
         if(this.hasValidPart())
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            Global.player.setFeatureLastShown(MysteryCrateBuilding.VIRAL_POST_FREQUENCY_FLAG,currentTime,true);
            switch(this.m_requestTypeToUse)
            {
               case ASK_PARTS_FEED:
                  this.m_feedPostingState = MysteryCrateBuilding.FEED_STATUS_POSTED;
                  FarmStatsManager.count(FEED_STAT,FEED_STAT,MYSTERY_CRATE,this.m_part.item.name);
                  TransactionManager.addTransaction(new TMysteryCrateAskForMore(this,this.m_part.item.name,true,null),true);
                  break;
               case ASK_PARTS_R4R:
                  FarmStatsManager.count(REQUEST_STAT,REQUEST_MORE_STAT,MYSTERY_CRATE,this.m_part.item.name,REQUEST_TYPE_STAT);
                  TransactionManager.addTransaction(new TMysteryCrateAskForMore(this,this.m_part.item.name,false,null),true);
                  MFSRequestManager.getInstance().makeAskItemsRequest(this.getItemName(),this.m_part.item.name);
            }
         }
      }
      
      public function onCompleteMysteryCrate(result:Object) : void
      {
         var reward:FarmItem = null;
         var friendlyName:String = null;
         if(Boolean(result) && Boolean(result.rewardName) && result.rewardName != "")
         {
            reward = Global.farmGameSettingsManager.getFarmItemByName(result.rewardName);
            friendlyName = reward.friendlyName;
            FarmStatsManager.count(MYSTERY_CRATE,MYSTERY_CRATE,COMPLETED_STAT);
            this.rewardWindow(reward,result);
            this.displaySuccessToaster(friendlyName);
         }
      }
      
      private function rewardWindow(reward:FarmItem, transactionResult:Object) : void
      {
         if(this.hasValidPart())
         {
            Global.player.addGift(reward.name);
            this.m_rewardWindow = new MysteryCrateRewardWindow(reward,this.m_part.item,this.m_partName,transactionResult);
            UI.displayPopup(this.m_rewardWindow,false,"mysterycrate_reward");
         }
      }
      
      private function removeMysteryCrate() : void
      {
         if(this.hasValidPart() && this.canRemove())
         {
            Global.player.removeGiftWithKey(this.m_part.item.code,this.getGiftboxPartCount(this.m_part.item));
            Global.player.removeLimitedItem(getItem().name);
            detach();
         }
      }
      
      private function removeMysteryCrateBuilding() : void
      {
         if(this.hasValidPart() && this.canRemove())
         {
            Global.player.removeLimitedItem(getItem().name);
            detach();
         }
      }
      
      private function canRemove() : Boolean
      {
         var result:Boolean = false;
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_HOUR;
         this.getHoursUntilExpiry();
         if(isFullyBuilt() || currentTime > this.m_hoursUntilExpiry)
         {
            result = true;
         }
         return result;
      }
      
      public function setFeedPostingState() : void
      {
         var coolDownHours:int = Global.flashHotParams["MYSTERY_CRATE_COOL_DOWN_HOURS"] != null ? int(Global.flashHotParams["MYSTERY_CRATE_COOL_DOWN_HOURS"]) : MYSTERY_CRATE_FEED_POST_COOLDOWN_DEFAULT;
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_HOUR;
         var lastViralSent:int = Global.player.getFeatureLastShown(MysteryCrateBuilding.VIRAL_POST_FREQUENCY_FLAG) / FarmGameUtil.NUM_SECS_IN_HOUR;
         var timeSinceLastPosted:int = currentTime - lastViralSent;
         if(lastViralSent != 0)
         {
            if(timeSinceLastPosted >= coolDownHours && timeSinceLastPosted > 0)
            {
               this.m_feedPostingState = FEED_STATUS_READY;
            }
            else
            {
               this.m_feedPostingState = FEED_STATUS_POSTED;
            }
         }
         else
         {
            this.m_feedPostingState = FEED_STATUS_READY;
         }
      }
      
      private function hasValidPart() : Boolean
      {
         return Boolean(this.m_part) || !this.m_applyLoadCheck;
      }
   }
}

