package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.GenericPopup;
   import Display.GenericPopupTitleSimple;
   import Display.GenericXMLDialog;
   import Display.PigpenDialog;
   import Display.PigpenDialogMakeSlop;
   import Display.PigpenDialogTruffleSuccess;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import GameMode.GMAnimalPlace;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TPigHunt;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class PigpenBuilding extends AnimalStorageBuilding
   {
      
      private static const ADDSLOPICON_DURATION:Number = 3;
      
      private static const ADDSLOPICON_OUTLINECOLOR:uint = 16776960;
      
      private static const ADDSLOPICON_OUTLINEALPHA:Number = 1;
      
      private static const ADDSLOPICON_BLUR:Number = 8;
      
      private static const ADDSLOPICON_STRENGTH:Number = 20;
      
      public static const SHARE_DIALOG_ICON_SIZE:Number = 100;
      
      public static const SHARE_DIALOG_SUBTITLE_STYLE:String = ".body";
      
      private static const EXPAND_SEEN_FLAG:String = "ExpandPigpen";
      
      public static const EXPAND_PART_IMAGE_ICON_PREFIX:String = "assets/newsfeed/pigpen_";
      
      private static const DIALOG_INSTANCE_NAME:String = "PigpenMainDialog";
      
      public static const EXPAND_IMAGE_ICON_URL:String = "assets/buildings/building_pigpen_icon.png";
      
      public static const FLAG_HAS_OPENED_WHATISTHIS:String = "pigpenWhatIsThisOpened";
      
      private static const STR_HUNT_ICON:String = "assets/animals/animal_pig_icon.png";
      
      private static const NUM_HUNT_ARROW_INDICATOR_CHECK_INTERVAL_MS:Number = 2000;
      
      private static const NUM_HUNT_ARROW_SCALE:Number = 0.25;
      
      private static const PT_HUNT_ARROW_OFFSET:Point = new Point(-25,-50);
      
      protected var m_bundleData:Object = null;
      
      protected var m_feedAction:String = "";
      
      private var m_harvestResult:Object = null;
      
      private var m_makeSlopDialog:PigpenDialogMakeSlop = null;
      
      private var m_slopCount:int;
      
      private var m_cooldownTimestamp:int;
      
      private var m_readyToHuntPigs:Object = {};
      
      private var m_pigpenDialog:PigpenDialog;
      
      private var m_lastTruffleResult:Object;
      
      private var m_restingPigs:Object = {};
      
      private var m_nextHuntArrowIndicatorCheckTimeMs:Number = 0;
      
      private var m_huntArrowCurrentlyHidden:Boolean = true;
      
      protected var m_huntArrowDisplayObj:DisplayObject;
      
      public function PigpenBuilding(buildingType:String = null)
      {
         super(buildingType);
         this.checkArrowIndicator();
      }
      
      public static function hasUserSeenWhatIsThisDialog() : Boolean
      {
         return Global.player.getSeenFlag(FLAG_HAS_OPENED_WHATISTHIS);
      }
      
      public static function setUserSeenWhatIsThisDialog() : void
      {
         Global.player.setSeenFlag(FLAG_HAS_OPENED_WHATISTHIS);
      }
      
      override public function loadObject(data:Object) : void
      {
         var contents:Array = null;
         var pig:Object = null;
         var have:int = 0;
         var resting:int = 0;
         super.loadObject(data);
         if(data.hasOwnProperty("slopCount"))
         {
            this.m_slopCount = data["slopCount"];
         }
         if(data.hasOwnProperty("cooldownTimestamp"))
         {
            this.m_cooldownTimestamp = data["cooldownTimestamp"];
         }
         if(data.hasOwnProperty("restingPigs") && Boolean(data.restingPigs))
         {
            this.m_restingPigs = data["restingPigs"];
         }
         if(data.hasOwnProperty("contents"))
         {
            contents = data.contents as Array;
            for each(pig in contents)
            {
               if(Boolean(pig.itemCode) && pig.numItem > 0)
               {
                  have = int(pig.numItem);
                  resting = pig.hasOwnProperty("numItemInCooldown") ? int(pig.numItemInCooldown) : 0;
                  if(have - resting > 0)
                  {
                     this.m_readyToHuntPigs[pig.itemCode] = have - resting;
                  }
               }
            }
         }
      }
      
      public function getCoolDownTimeLeft() : String
      {
         var timeAmounts:Array = null;
         var nHours:Number = NaN;
         var nMinutes:Number = NaN;
         var nSeconds:Number = NaN;
         var restingPeriod:Number = Global.farmGameSettingsManager.getInt("pigpenRestingPeriod",172800);
         var worldTime:Number = Global.worldTime / 1000;
         var timeDiffInTotalSec:Number = this.m_cooldownTimestamp + restingPeriod - worldTime;
         var result:String = "";
         if(timeDiffInTotalSec < 0)
         {
            if(this.m_cooldownTimestamp != 0)
            {
               this.m_cooldownTimestamp = 0;
            }
            result = "00:00:00";
         }
         else
         {
            timeAmounts = FarmGameUtil.parseTimeLeft(timeDiffInTotalSec);
            nHours = timeAmounts[0] * FarmGameUtil.NUM_HOURS_IN_DAY + timeAmounts[1];
            nMinutes = Number(timeAmounts[2]);
            nSeconds = Number(timeAmounts[3]);
            result = FarmGameUtil.numberToStringPadZeros(nHours) + ":" + FarmGameUtil.numberToStringPadZeros(nMinutes) + ":" + FarmGameUtil.numberToStringPadZeros(nSeconds);
         }
         return result;
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         this.m_harvestResult = result;
         if(this.m_harvestResult.hasOwnProperty("rewardUrl") && this.m_harvestResult.rewardUrl != "")
         {
            this.openDialogSlopFoundExtra();
         }
         else
         {
            this.displayStorageDialog();
         }
         FarmStatsManager.count("pigpen","harvest");
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var code:String = null;
         var numPigs:int = 0;
         var cap:int = 0;
         var msg:String = null;
         var dialog:GenericXMLDialog = null;
         var isValidExpansionPart:Boolean = isValidExpansionPart(resource);
         var success:Boolean = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         if(success && !isValidExpansionPart)
         {
            code = resource.getItem().code;
            if(!this.m_restingPigs.hasOwnProperty(code) || this.getAmount(code) > this.m_restingPigs[code])
            {
               if(!this.m_readyToHuntPigs.hasOwnProperty(code))
               {
                  this.m_readyToHuntPigs[code] = 0;
               }
               ++this.m_readyToHuntPigs[code];
            }
            numPigs = this.count;
            cap = this.capacity;
            if(hasNextExpansion() && numPigs == cap && Global.player.getSeenFlag(EXPAND_SEEN_FLAG + cap) == false)
            {
               Global.player.setSeenFlag(EXPAND_SEEN_FLAG + cap);
               msg = ZLocUtils.t("Dialogs",m_item.className + "ExpandNow");
               dialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,true,ZLocUtils.t("Dialogs","Okay"),this.onExpandNowAccept);
               UI.displayPopup(dialog,false);
            }
            FarmStatsManager.count("Market","actionMenu","Store_pig");
         }
         FarmStatsManager.featureSample("farm_world_action","add_item_to_storage",m_item.name,resource.getItem().name);
         this.checkArrowIndicator(true);
         return success;
      }
      
      override protected function onCompleteExpansion(rewardLink:String, itemName:String) : void
      {
         this.reloadImage();
         var iconUrl:String = EXPAND_IMAGE_ICON_URL;
         this.m_feedAction = m_item.className + "ExpandComplete";
         var feedImage:String = Global.getAssetURL(iconUrl);
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var title:String = ZLocUtils.t("Dialogs",m_item.className + "ExpandCompleteTitle");
         var subtitle:String = ZLocUtils.t("Dialogs",m_item.className + "ExpandCompleteSubTitle");
         var message:String = ZLocUtils.t("Dialogs",m_item.className + "ExpandCompleteMessage");
         var dialog:GenericXMLDialog = new GenericXMLDialog(title,subtitle,SHARE_DIALOG_SUBTITLE_STYLE,iconUrl,SHARE_DIALOG_ICON_SIZE,SHARE_DIALOG_ICON_SIZE,message,this.onShareExpansionReward,true,ZLocUtils.t("Dialogs","ShareButton"));
         dialog.setTrackerKey("expand_pigpen-expansion_complete");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteHalfExpansion(rewardLink:String) : void
      {
         var iconUrl:String = EXPAND_IMAGE_ICON_URL;
         this.m_feedAction = m_item.className + "ExpandHalfComplete";
         var feedImage:String = Global.getAssetURL(iconUrl);
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var title:String = ZLocUtils.t("Dialogs",m_item.className + "ExpandHalfCompleteTitle");
         var subtitle:String = ZLocUtils.t("Dialogs",m_item.className + "ExpandHalfCompleteSubTitle");
         var message:String = ZLocUtils.t("Dialogs",m_item.className + "ExpandHalfCompleteMessage");
         var dialog:GenericXMLDialog = new GenericXMLDialog(title,subtitle,SHARE_DIALOG_SUBTITLE_STYLE,iconUrl,SHARE_DIALOG_ICON_SIZE,SHARE_DIALOG_ICON_SIZE,message,this.onShareExpansionReward,true,ZLocUtils.t("Dialogs","ShareButton"));
         dialog.setTrackerKey("expand_pigpen-expansion_halfway");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteExpansionPart(rewardLink:String, itemName:String) : void
      {
         this.m_feedAction = m_item.className + "ExpandCompletePart";
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
         var title:String = ZLocUtils.t("Dialogs",m_item.className + "ExpandPartCompleteTitle");
         var subtitle:String = ZLocUtils.t("Dialogs",m_item.className + "ExpandPartCompleteSubTitle",{"items":ZLocUtils.tk_pk(itemFriendlyName)});
         var message:String = ZLocUtils.t("Dialogs",m_item.className + "ExpandPartCompleteMessage");
         var dialog:GenericXMLDialog = new GenericXMLDialog(title,subtitle,SHARE_DIALOG_SUBTITLE_STYLE,Global.reverseAssetURL(partImage,2),SHARE_DIALOG_ICON_SIZE,SHARE_DIALOG_ICON_SIZE,message,this.onShareExpansionReward,true,ZLocUtils.t("Dialogs","ShareButton"));
         dialog.setTrackerKey("expand_pigpen-expand_materialcomplete");
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
      
      override public function removeContents(itemCode:String, itemCount:int = 1, itemParts:int = 0) : void
      {
         super.removeContents(itemCode,itemCount,itemParts);
         if(this.m_readyToHuntPigs[itemCode])
         {
            --this.m_readyToHuntPigs[itemCode];
            if(this.m_readyToHuntPigs[itemCode] <= 0)
            {
               delete this.m_readyToHuntPigs[itemCode];
            }
            FarmStatsManager.count("pigpen","mainDialog","removeActive");
         }
         else
         {
            FarmStatsManager.count("pigpen","mainDialog","removeInactive");
         }
         this.checkArrowIndicator(true);
      }
      
      public function attemptPigPlacementForPigRemoval(itemCode:String) : void
      {
         var type:String = Global.farmGameSettingsManager.getFarmItemByCode(itemCode).name;
         Global.world.addGameMode(new GMAnimalPlace(type,false,this.getId()));
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         var showWhatIsThisDialog:Boolean = false;
         if(!hasUserSeenWhatIsThisDialog())
         {
            setUserSeenWhatIsThisDialog();
            showWhatIsThisDialog = true;
         }
         this.removeHuntArrowIndicator();
         this.m_pigpenDialog = new PigpenDialog(this,PigpenDialog.DEFAULT_ENTRY,showWhatIsThisDialog);
         UI.displayPopup(this.m_pigpenDialog,true,DIALOG_INSTANCE_NAME,true);
      }
      
      public function displayExpandDialog() : void
      {
         this.m_pigpenDialog = new PigpenDialog(this,PigpenDialog.EXPAND_ENTRY);
         UI.displayPopup(this.m_pigpenDialog,true,DIALOG_INSTANCE_NAME,true);
      }
      
      public function onExpandNowAccept(evt:Event = null) : void
      {
         this.displayExpandDialog();
      }
      
      public function openDialogSlopMakeSlop() : void
      {
         this.m_makeSlopDialog = new PigpenDialogMakeSlop(this);
         this.m_makeSlopDialog.addEventListener(CloseEvent.CLOSE,function(e:Event):void
         {
            m_makeSlopDialog = null;
         });
         UI.displayPopup(this.m_makeSlopDialog,false);
      }
      
      public function openDialogSlopMaxSlop() : void
      {
         var sMsg:String = ZLocUtils.t("Dialogs",m_item.className + "_Slop_MaxSlop" + "_Body");
         var tmpPopup:GenericPopup = new GenericPopup(sMsg,GenericPopup.TYPE_OK,null,GenericPopup.GENERIC_ASSET,"",false,true);
         tmpPopup.setAcceptTextName("Okay");
         UI.displayPopup(tmpPopup,false,"Slop_MaxSlop",true);
         FarmStatsManager.count("pigpen","makeSlop","maximumSlopReached");
      }
      
      public function openDialogSlopOutOfSlop() : void
      {
         var sMsg:String = ZLocUtils.t("Dialogs",m_item.className + "_Slop_OutOfSlop" + "_Body");
         var sTitleToken:String = m_item.className + "_Slop_OutOfSlop" + "_Title";
         var tmpPopup:GenericPopup = new GenericPopupTitleSimple(sMsg,sTitleToken);
         UI.displayPopup(tmpPopup,false,"Slop_OutOfSlop",true);
         FarmStatsManager.count("pigpen","huntActive","outofslop");
      }
      
      private function openDialogSlopFoundExtra() : void
      {
         var sMsg:String = ZLocUtils.t("Dialogs",m_item.className + "_Slop_FoundExtra" + "_Body");
         var sTitleToken:String = m_item.className + "_Slop_FoundExtra" + "_Title";
         var tmpPopup:GenericPopup = new GenericPopupTitleSimple(sMsg,sTitleToken,GenericPopup.TYPE_SHARECANCEL,this.onCloseFoundSlop);
         tmpPopup.setTrackerKey("pigpen_share_slop");
         UI.displayPopup(tmpPopup,false,"Slop_FoundExtra",true);
      }
      
      private function onCloseFoundSlop(event:GenericPopupEvent) : void
      {
         var slopCode:String = null;
         var slop:FarmItem = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("pigpen","harvest","getSlop","clickShare");
            slopCode = Global.farmGameSettingsManager.getString("pigpenHarvestSlopDropItemCode");
            if(Boolean(slopCode) && slopCode != "")
            {
               slop = Global.farmGameSettingsManager.getFarmItemByCode(slopCode);
               bundleData = {
                  "reward_link":this.m_harvestResult.rewardUrl,
                  "images":[{
                     "href":"{SN_APP_URL}" + this.m_harvestResult.rewardUrl,
                     "src":slop.getImageByName("icon")
                  }]
               };
               Global.farmSocialNetwork.publishFeedStory("PigpenShareSlop",bundleData,null,false);
            }
         }
         else
         {
            FarmStatsManager.count("pigpen","harvest","getSlop","clickCancel");
         }
         this.displayStorageDialog();
      }
      
      public function onButtonClickMakeSlopIsOutOfBushels() : void
      {
         if(this.m_pigpenDialog != null)
         {
            this.m_pigpenDialog.close();
            this.m_pigpenDialog = null;
         }
         var pCraftMan:CraftingManager = CraftingManager.getInstance();
         if(pCraftMan.getPlacedMarketStalls() > 0)
         {
            CraftingUI.displayMarketStallWindow(null);
            FarmStatsManager.count("pigpen","makeSlop","gotoFarmersMarket");
         }
         else if(pCraftMan.getMarketStallsInGiftBox() > 0)
         {
            UI.displayGiftBoxWindow();
         }
         else
         {
            UI.displayMarketDialog("pigpen","building",null,"crafting");
         }
      }
      
      private function openDialogHuntSuccessFoundTruffle(sUserImageUrl:String, sFriendName:String, sPigType:String, sTruffleType:String, sTruffleImageRelUrl:String) : void
      {
         var sFriendGender:String = ZLocUtils.FEM;
         var sMsg:String = ZLocUtils.t("Dialogs",m_item.className + "_Hunt_SuccessFoundTruffle_Body",{
            "itemA":ZLocUtils.tk_pk(sPigType),
            "user":ZLocUtils.tn(sFriendName,sFriendGender),
            "itemB":ZLocUtils.tk_pk(sTruffleType),
            "user_same":sFriendName
         });
         var sTitleToken:String = m_item.className + "_Hunt_SuccessFoundTruffle_Title";
         var tmpPopup:GenericPopup = new PigpenDialogTruffleSuccess(sMsg,sTitleToken,sUserImageUrl,sTruffleImageRelUrl,GenericPopup.TYPE_SHARECANCEL,this.onHuntFoundTruffleClose);
         tmpPopup.setTrackerKey("pigpen_found_truffle");
         UI.displayPopup(tmpPopup,false,"Hunt_SuccessFoundTruffle",true);
      }
      
      private function onHuntFoundTruffleClose(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("pigpen","huntActive","getTruffle","clickShare");
            bundleData = {
               "reward_link":this.m_lastTruffleResult.rewardUrl,
               "friendName":this.m_lastTruffleResult.friendName,
               "truffleType":this.m_lastTruffleResult.truffleName,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_lastTruffleResult.rewardUrl,
                  "src":this.m_lastTruffleResult.imageUrl
               }]
            };
            Global.farmSocialNetwork.publishFeedStory("PigpenFoundTruffle",bundleData,[this.m_lastTruffleResult.friendUid],false);
         }
         else
         {
            FarmStatsManager.count("pigpen","huntActive","getTruffle","clickCancel");
         }
         this.m_lastTruffleResult = null;
         this.updateAllTiredMessage();
      }
      
      private function openDialogHuntFoundNothing() : void
      {
         var sMsg:String = m_item.className + "_Hunt_FoundNothing" + "_Body";
         var sTitleToken:String = m_item.className + "_Hunt_FoundNothing" + "_Title";
         this.m_pigpenDialog.showFailedHuntDialog(sMsg,sTitleToken);
         FarmStatsManager.count("pigpen","huntActive","getNothing");
      }
      
      private function updateAllTiredMessage(event:GenericPopupEvent = null) : void
      {
         this.m_pigpenDialog.updateAllTiredMessage();
      }
      
      public function openDialogHuntMaxHuntsReached(nMaxHuntsPerDay:Number = 123) : void
      {
         var sMsg:String = ZLocUtils.t("Dialogs",m_item.className + "_Hunt_MaxHuntsReached" + "_Body",{"quantity":nMaxHuntsPerDay});
         var sTitleToken:String = m_item.className + "_Hunt_MaxHuntsReached" + "_Title";
         var tmpPopup:GenericPopup = new GenericPopupTitleSimple(sMsg,sTitleToken);
         UI.displayPopup(tmpPopup,false,"Hunt_MaxHuntsReached",true);
         FarmStatsManager.count("pigpen","huntActive","maxHuntsReached");
      }
      
      public function addSlop(bShowRisingIconFX:Boolean = false, sItemWithIcon:String = "pkg_slop") : void
      {
         var iconFilter:Array = null;
         var iconUrl:String = null;
         var duration:Number = NaN;
         var message:String = null;
         ++this.m_slopCount;
         if(this.m_pigpenDialog != null)
         {
            this.m_pigpenDialog.updateFeedCounter();
            this.m_pigpenDialog.updateSlopBar();
         }
         if(bShowRisingIconFX)
         {
            iconFilter = [new GlowFilter(ADDSLOPICON_OUTLINECOLOR,ADDSLOPICON_OUTLINEALPHA,ADDSLOPICON_BLUR,ADDSLOPICON_BLUR,ADDSLOPICON_STRENGTH)];
            iconUrl = Global.farmGameSettingsManager.getFarmItemByName(sItemWithIcon).iconUrl;
            duration = ADDSLOPICON_DURATION;
            message = ZLocUtils.t("Dialogs","PigpenAcceptSlopGift",{"item":ZLocUtils.tk("Items",sItemWithIcon + "_friendlyName")});
            this.displayStatus(message,iconUrl,iconFilter,duration);
         }
      }
      
      private function useSlop() : void
      {
         --this.m_slopCount;
         if(this.m_pigpenDialog != null)
         {
            this.m_pigpenDialog.updateFeedCounter();
            this.m_pigpenDialog.updateSlopBar();
         }
      }
      
      public function canAddSlop() : Boolean
      {
         var result:Boolean = false;
         if(this.m_slopCount < this.getMaxSlop())
         {
            result = true;
         }
         return result;
      }
      
      public function getSlopCount() : int
      {
         return this.m_slopCount;
      }
      
      public function getMaxSlop() : int
      {
         return int(capacity * Global.farmGameSettingsManager.getNumber("pigpenSlopToPigCapacityRatio",0.5));
      }
      
      public function getContentDictionary() : Dictionary
      {
         return m_contents;
      }
      
      public function getReadyPigs() : Object
      {
         return this.m_readyToHuntPigs;
      }
      
      public function setReadyPigs(obj:Object) : void
      {
         this.m_readyToHuntPigs = new Object();
         this.m_readyToHuntPigs = obj;
      }
      
      public function getRestingPigs() : Dictionary
      {
         var key:String = null;
         var readyPigs:Object = null;
         var code:String = null;
         var restingPigs:Dictionary = new Dictionary();
         for(key in this.m_contents)
         {
            restingPigs[key] = this.m_contents[key];
         }
         readyPigs = this.getReadyPigs();
         for(code in readyPigs)
         {
            restingPigs[code] -= readyPigs[code];
         }
         return restingPigs;
      }
      
      public function clearRestingPigsCache() : void
      {
         this.m_restingPigs = new Object();
      }
      
      private function getHuntCount() : int
      {
         var pigCode:String = null;
         var count:int = 0;
         for(pigCode in this.m_restingPigs)
         {
            if(this.m_restingPigs[pigCode] > 0)
            {
               count += this.m_restingPigs[pigCode];
            }
         }
         return count;
      }
      
      private function getReadyToHuntCount() : int
      {
         var pigCode:String = null;
         var count:int = 0;
         for(pigCode in this.m_readyToHuntPigs)
         {
            if(this.m_readyToHuntPigs[pigCode] > 0)
            {
               count += this.m_readyToHuntPigs[pigCode];
            }
         }
         return count;
      }
      
      public function hasHuntedToCapacity() : Boolean
      {
         return this.getHuntCount() >= this.maxNumHuntsPerDay();
      }
      
      public function maxNumHuntsPerDay() : Number
      {
         return capacity;
      }
      
      public function hunt(pigCode:String) : void
      {
         FarmStatsManager.count("pigpen","myPigs","huntActive");
         TransactionManager.addTransaction(new TPigHunt(this,pigCode),true);
         this.useSlop();
         if(!this.m_restingPigs.hasOwnProperty(pigCode))
         {
            this.m_restingPigs[pigCode] = 0;
         }
         ++this.m_restingPigs[pigCode];
         --this.m_readyToHuntPigs[pigCode];
         if(this.m_readyToHuntPigs[pigCode] <= 0)
         {
            delete this.m_readyToHuntPigs[pigCode];
         }
      }
      
      public function onHuntComplete(result:Object) : void
      {
         if(this.m_cooldownTimestamp == 0)
         {
            this.m_cooldownTimestamp = Global.worldTime / 1000;
         }
         var pigData:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(result.pigCode);
         var prizeData:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(result.truffleFound);
         if(Boolean(result) && Boolean(result.hasOwnProperty("truffleFound")) && result.truffleFound != "")
         {
            if(prizeData)
            {
               this.m_lastTruffleResult = result;
               this.m_lastTruffleResult["imageUrl"] = prizeData.getImageByName("feedIcon");
               this.m_lastTruffleResult["truffleName"] = prizeData.friendlyName;
               this.openDialogHuntSuccessFoundTruffle(result.friendPic,result.friendName,pigData.friendlyName,prizeData.friendlyName,prizeData.getImageByName("icon"));
            }
         }
         else
         {
            this.openDialogHuntFoundNothing();
         }
         this.m_pigpenDialog.onTransactionComplete();
      }
      
      override protected function updateToolTipText() : void
      {
         this.checkArrowIndicator();
         if(isHighlighted() && Global.worldManager.isVisiting())
         {
            setToolTip(ZLocUtils.t("Dialogs","PigpenTitle"));
         }
         else
         {
            super.updateToolTipText();
         }
      }
      
      override public function getToolTipCapacityText() : String
      {
         return ZLocUtils.t("Items",m_item.name + "_capacity",{
            "quantityA":m_count,
            "maximum":capacity,
            "quantityB":this.getReadyToHuntCount()
         });
      }
      
      private function checkArrowIndicator(forceRefresh:Boolean = false) : void
      {
         var spr:Sprite = null;
         if(!m_usingLoadingGraphic && !UI.isShowingPopup())
         {
            if(Boolean(m_arrow || this.getReadyToHuntCount() <= 0) || Boolean((m_count - this.getReadyToHuntCount() || this.m_pigpenDialog) > 0) || Global.worldManager.isVisiting())
            {
               m_hideArrow = true;
            }
            else
            {
               m_hideArrow = false;
            }
            if(this.m_huntArrowCurrentlyHidden != m_hideArrow || forceRefresh)
            {
               if(m_hideArrow)
               {
                  this.removeHuntArrowIndicator();
               }
               else
               {
                  if(Boolean(this.m_huntArrowDisplayObj) && forceRefresh)
                  {
                     this.removeHuntArrowIndicator();
                  }
                  spr = m_displayObject as Sprite;
                  if(this.m_huntArrowDisplayObj == null && spr != null && spr.numChildren > 0)
                  {
                     this.m_huntArrowDisplayObj = this.createHuntArrowIndicator();
                     if(this.m_huntArrowDisplayObj)
                     {
                        this.m_huntArrowDisplayObj.visible = true;
                        GlobalEngine.viewport.objectBase.addChild(this.m_huntArrowDisplayObj);
                        this.setArrowPosition();
                     }
                     this.m_huntArrowCurrentlyHidden = false;
                  }
               }
            }
         }
      }
      
      override protected function setArrowPosition() : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         if(Boolean(this.m_huntArrowDisplayObj) && Boolean(m_displayObject))
         {
            point = new Point();
            spr = m_displayObject as Sprite;
            this.m_huntArrowDisplayObj.scaleX = NUM_HUNT_ARROW_SCALE / m_displayObject.scaleX;
            this.m_huntArrowDisplayObj.scaleY = NUM_HUNT_ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point.y = m_displayObject.y + PT_HUNT_ARROW_OFFSET.y;
               point.x = spr.getChildAt(0).width / 2 * m_displayObject.scaleX + m_displayObject.x + PT_HUNT_ARROW_OFFSET.x;
               if(point.x != this.m_huntArrowDisplayObj.x || point.y != this.m_huntArrowDisplayObj.y)
               {
                  this.m_huntArrowDisplayObj.y = point.y;
                  this.m_huntArrowDisplayObj.x = point.x;
               }
            }
         }
         super.setArrowPosition();
      }
      
      public function removeHuntArrowIndicator() : void
      {
         if(Boolean(this.m_huntArrowDisplayObj) && Boolean(this.m_huntArrowDisplayObj.visible) && this.m_huntArrowDisplayObj.parent != null)
         {
            this.m_huntArrowDisplayObj.visible = false;
            this.m_huntArrowDisplayObj.parent.removeChild(this.m_huntArrowDisplayObj);
            this.m_huntArrowDisplayObj = null;
            conditionallyRedraw(true);
            this.m_huntArrowCurrentlyHidden = true;
            m_hideArrow = true;
         }
      }
      
      private function createHuntArrowIndicator() : DisplayObject
      {
         var arrowIndicator:DisplayObject = null;
         var iconUrl:String = "";
         var pigsReadyToHunt:int = this.getReadyToHuntCount();
         var titleLocalizeKey:String = "pigpen_finished_huntArrow_title";
         var title:String = ZLocUtils.t("Items",titleLocalizeKey,{"quantity":pigsReadyToHunt});
         var text:String = ZLocUtils.t("Items","pigpen_finished_huntArrow_text");
         var counterText:String = pigsReadyToHunt > 0 ? pigsReadyToHunt.toString() : null;
         arrowIndicator = new ArrowIndicatorWindow(STR_HUNT_ICON,title,text,counterText);
         FarmStatsManager.count("pigpen","see_hunt_arrow");
         return arrowIndicator;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(GlobalEngine.currentTime > this.m_nextHuntArrowIndicatorCheckTimeMs)
         {
            this.checkArrowIndicator();
            this.m_nextHuntArrowIndicatorCheckTimeMs = GlobalEngine.currentTime + NUM_HUNT_ARROW_INDICATOR_CHECK_INTERVAL_MS;
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.updateArrowIndicator();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.updateArrowIndicator();
      }
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
         {
            arrowIndicatorWindow = this.m_huntArrowDisplayObj as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      override public function setPosition(newX:Number, newY:Number, newZ:Number = 0) : void
      {
         super.setPosition(newX,newY,newZ);
         this.setArrowPosition();
      }
   }
}

