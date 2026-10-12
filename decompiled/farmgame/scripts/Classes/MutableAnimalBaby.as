package Classes
{
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.UGC.UGCFeedImage;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Managers.UserContentManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TMove;
   import Transactions.TTransformBuilding;
   import Widgets.Windows.Breeding.BreedingRenameWindow;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   
   public class MutableAnimalBaby extends ConstructionBuilding
   {
      
      protected static const OVERLAY_URL:String = "assets/overlays/effect_sapling_sparkling.swf";
      
      private static const OVERLAY_OFFSET:Vector2 = new Vector2(0,-90);
      
      protected static const MINI_MARKET_ITEMS:Array = new Array("bottle");
      
      public static var CLASSNAME_STRING:String = "MutableAnimalBaby";
      
      protected const ASK_FOR_BOTTLES:String = "askForBottles";
      
      protected const FEED_BOTTLES:String = "feedBottles";
      
      protected const COMPLETE_NOW:String = "completeNow";
      
      protected var m_mutableAnimalState:MutableAnimalState = null;
      
      protected var m_colorHSV:Array;
      
      protected var DEFAULT_HSV_VALUE:Array = [0,0,1];
      
      protected var MIN_SATURATION_VALUE:Number = 1;
      
      protected var MIN_INTENSITY_VALUE:Number = 3;
      
      public function MutableAnimalBaby(buildingType:String = null, metadata:String = null, metadataIndex:Number = -1)
      {
         super(buildingType);
         if(metadata)
         {
            this.setMutableAnimalStateFromMetaData(metadata);
         }
         else
         {
            this.m_colorHSV = this.DEFAULT_HSV_VALUE;
         }
         m_direction = Constants.DIRECTION_SE;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(metadataIndex < 0)
         {
            this.m_giftMetadataIndex = Global.player.getLastGiftMetadataIndex(farmItem.code);
         }
         else
         {
            this.m_giftMetadataIndex = metadataIndex;
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.hasOwnProperty("mutableAnimalState") && data.mutableAnimalState != null && data.mutableAnimalState.dna != null)
         {
            this.m_mutableAnimalState = new MutableAnimalState("",data.mutableAnimalState.dna,"");
         }
         if(this.m_mutableAnimalState)
         {
            this.setAnimalState();
         }
         else
         {
            this.m_colorHSV = this.DEFAULT_HSV_VALUE;
         }
         m_direction = data.direction;
      }
      
      override protected function updateToolTipText() : void
      {
         var capacityText:String = null;
         var sheepName:String = null;
         var toolTip:String = null;
         if(isHighlighted())
         {
            if(Global.worldManager.isVisiting() == false)
            {
               capacityText = ZLocUtils.t("Items",m_item.name + "_capacity",{
                  "quantity":m_count,
                  "maximum":capacity
               });
               if(!isFullyBuilt())
               {
                  capacityText = ZLocUtils.t("Items",m_item.name + "_mats",{
                     "quantity":m_count,
                     "maximum":capacity
                  });
               }
               switch(state)
               {
                  case STATE_CONSTRUCTION:
                     toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                        "item":ZLocUtils.tk_pk(m_item.friendlyName),
                        "capacityStr":capacityText
                     });
                     break;
                  default:
                     toolTip = m_item.friendlyTitle;
               }
            }
            else if(Global.worldManager.isVisiting() == true)
            {
               toolTip = m_item.friendlyTitle;
            }
            if(state == STATE_BUILT)
            {
               toolTip = ZLocUtils.tk_pk_asTitle(getBuiltToolTipText());
            }
         }
         if(this.m_mutableAnimalState != null)
         {
            sheepName = this.m_mutableAnimalState.dna[MutableAnimalState.NAME_DATA_KEY];
            toolTip = sheepName + "\n" + toolTip;
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      public function setMutableAnimalStateFromMetaData(metadata:String) : void
      {
         this.m_mutableAnimalState = MutableAnimalState.createFromPhpString("",metadata);
         this.setAnimalState();
      }
      
      public function setMutableAnimalState(mutableAnimalState:MutableAnimalState) : void
      {
         this.m_mutableAnimalState = mutableAnimalState;
         this.setAnimalState();
      }
      
      protected function setAnimalState() : void
      {
         var saturation:Number = NaN;
         var intensity:Number = NaN;
         var configData:Object = null;
         var desaturateFactor:Number = NaN;
         if(this.m_mutableAnimalState != null)
         {
            saturation = this.m_mutableAnimalState.saturation();
            intensity = this.m_mutableAnimalState.intensity();
            if(saturation <= 0)
            {
               saturation = this.MIN_SATURATION_VALUE;
            }
            if(intensity <= 0)
            {
               intensity = this.MIN_INTENSITY_VALUE;
            }
            configData = Global.animalBreedingSettings.getColoringByItemName(this.getItem().name);
            desaturateFactor = 1;
            if(configData != null)
            {
               desaturateFactor = Number(configData.desaturateFactor);
            }
            this.m_colorHSV = [this.m_mutableAnimalState.hue() / 40,saturation * desaturateFactor / 15,intensity / 15];
            this.updateColorMatrix();
         }
      }
      
      override protected function initializeFilters() : void
      {
         this.updateColorMatrix();
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         var ugcImage:UGCFeedImage;
         var statsKingdom:String = null;
         var rewardLink:String = null;
         var patternTrait:String = null;
         setState(STATE_CONSTRUCTION);
         statsKingdom = this.getItem().name + "_" + StatsTrackingConstants.DIALOG_STATE_PLACE_KINGDOM;
         rewardLink = result.rewardLink;
         ugcImage = this.getFeedImage();
         UserContentManager.getInstance().createFeedImage(ugcImage,function(result:Object):void
         {
            if(result.hasOwnProperty("imagePath"))
            {
               createRewardFeed(m_buildingName + "BeginBuilding",statsKingdom,rewardLink,result.imagePath,displayStorageDialog);
            }
         });
         if(this.m_mutableAnimalState != null)
         {
            patternTrait = Global.animalBreedingSettings.getPatternTrait(Global.animalBreedingSettings.getFeatureNameByItem(getItem().name),this.m_mutableAnimalState.pattern);
            if(this.m_mutableAnimalState.fromFriend)
            {
               FarmStatsManager.count(getItem().statsCounter,"maturation","placed","friend",this.m_mutableAnimalState.statsHSV + ":T:" + patternTrait);
            }
            else
            {
               FarmStatsManager.count(getItem().statsCounter,"maturation","placed","self",this.m_mutableAnimalState.statsHSV + ":T:" + patternTrait);
            }
         }
      }
      
      override protected function onHalfWayFinished(result:Object) : void
      {
         var statsKingdom:String = null;
         var rewardLink:String = null;
         statsKingdom = this.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_HALFWAY_COMPLETE_KINGDOM;
         rewardLink = result.rewardLink;
         var ugcImage:UGCFeedImage = this.getFeedImage();
         UserContentManager.getInstance().createFeedImage(ugcImage,function(result:Object):void
         {
            if(result.hasOwnProperty("imagePath"))
            {
               createRewardFeed(m_buildingName + "HalfBuilt",statsKingdom,rewardLink,result.imagePath,statCountConstructableHalfway);
            }
         });
         FarmStatsManager.count(getItem().statsCounter,"maturation","halfway_finished");
      }
      
      private function getFeedImage() : UGCFeedImage
      {
         var ugcImage:UGCFeedImage = new UGCFeedImage(this,UserContentManager.FEATURE_ANIMAL_BREEDING);
         ugcImage.applyConfigTransforms(this.getItem().ugcTransforms);
         return ugcImage;
      }
      
      override public function getOverlayUrl() : String
      {
         return OVERLAY_URL;
      }
      
      override protected function getOverlayOffset() : Vector2
      {
         return OVERLAY_OFFSET;
      }
      
      public function atGrowthMilestone() : Boolean
      {
         var result:Boolean = false;
         if(m_count == int(getMaterialsNeeded() / 2) || this.state == STATE_BUILT)
         {
            result = true;
         }
         return result;
      }
      
      override public function showMenu() : void
      {
         if(!m_isFullyBuilt)
         {
            if(Global.animalBreedingSettings.canRenameBaby(m_itemName))
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("Items",getItem().statsCounter + "_changeName"),
                  "action":CHANGE_NAME
               });
            }
            m_menuItems.push({
               "label":ZLocUtils.t("Dialogs","CompleteNowCamel"),
               "action":this.COMPLETE_NOW
            });
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","FeedBottles"),
               "action":this.FEED_BOTTLES
            });
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","AskForBottles"),
               "action":this.ASK_FOR_BOTTLES
            });
            super.showMenu();
         }
      }
      
      override public function canRotate() : Boolean
      {
         return true;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.ASK_FOR_BOTTLES:
                  this.onAskForBottle();
                  break;
               case this.FEED_BOTTLES:
                  this.onApplyMaxPossibleBuildingParts("bottle",MINI_MARKET_ITEMS);
                  break;
               case this.COMPLETE_NOW:
                  this.onCompleteNow();
                  break;
               case ROTATE_OBJECT:
                  ++m_direction;
                  if(m_direction >= Constants.ROTATION_MAX)
                  {
                     m_direction = 0;
                  }
                  reloadImage();
                  this.syncChanges();
                  break;
               case CHANGE_NAME:
                  if(this.m_mutableAnimalState != null)
                  {
                     UI.displayPopup(new BreedingRenameWindow(this,this.m_mutableAnimalState,true));
                  }
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function updatePersonalName(value:String) : void
      {
         if(this.m_mutableAnimalState != null)
         {
            this.m_mutableAnimalState.name = value;
         }
      }
      
      override protected function getDisplayHorizontalOffset() : Number
      {
         var xOffset:Number = 0;
         if(m_direction == Constants.DIRECTION_NE || m_direction == Constants.DIRECTION_SW)
         {
            if(m_displayObject != null && m_itemImage != null && Boolean(m_itemImage.boxWidth))
            {
               m_displayObject.scaleX = -m_displayObject.scaleX;
               xOffset = m_itemImage.boxWidth * getImageScaleFactor();
            }
         }
         return xOffset;
      }
      
      private function syncChanges() : void
      {
         var params:Object = new Object();
         params.x = Math.round(getPosition().x);
         params.y = Math.round(getPosition().y);
         params.direction = m_direction;
         params.canWander = false;
         params.state = getState();
         TransactionManager.addTransaction(new TMove(this,params));
      }
      
      public function updateColorMatrix() : void
      {
         if(this.m_colorHSV.length < 3)
         {
            this.m_colorHSV = this.DEFAULT_HSV_VALUE;
         }
         var colorRGB:Array = FarmGameUtil.hsvToRgb(this.m_colorHSV[0],this.m_colorHSV[1],this.m_colorHSV[2]);
         var configData:Object = Global.animalBreedingSettings.getColoringByItemName(this.getItem().name);
         var cData:Object = {};
         if(configData != null)
         {
            cData = configData.colorMatrix;
         }
         var colorMatrix:Array = [colorRGB[0],cData["r"][0],cData["r"][1],cData["r"][2],cData["r"][3],colorRGB[1],cData["g"][0],cData["g"][1],cData["g"][2],cData["g"][3],colorRGB[2],cData["b"][0],cData["b"][1],cData["b"][2],cData["b"][3],0,cData["a"][0],cData["a"][1],cData["a"][2],cData["a"][3]];
         m_colorMatrixFilter = new ColorMatrixFilter(colorMatrix);
         if(m_content != null)
         {
            m_content.filters = [m_colorMatrixFilter];
         }
      }
      
      override public function onApplyMaxPossibleBuildingParts(buildingPartName:String, miniMarketItems:Array, combineTransaction:Boolean = true) : Object
      {
         var result:Object = super.onApplyMaxPossibleBuildingParts(buildingPartName,miniMarketItems);
         if(result.success == false)
         {
            FarmStatsManager.count(getItem().statsCounter,"maturation","open_buy_bottle_market");
         }
         else
         {
            FarmStatsManager.count(getItem().statsCounter,"maturation","feed_bottle",String(result.numAdded));
         }
         return result;
      }
      
      private function onAskForBottle() : void
      {
         MFSRequestManager.getInstance().makeAskMatsRequest(this.getItem().name,"bottle","bottle","",MFSConstants.SOURCE_DIALOG_CLICKED,getItem().statsCounter,"maturation","ask_for_bottle");
      }
      
      override public function onCompleteNow() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs",m_buildingName + "CompleteNow",{"quantity":this.calculateCashNeeded()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCompleteNowPopup);
      }
      
      protected function calculateCashNeeded(partCost:int = 1) : int
      {
         return int(partCost * (getMaterialsNeeded() - m_count));
      }
      
      protected function onAcceptCompleteNowPopup(event:GenericPopupEvent) : void
      {
         var buyResult:Boolean = false;
         if(event.button == GenericPopup.YES)
         {
            if(Global.player.canBuyCash(getMaterialsNeeded()))
            {
               buyResult = Global.player.tryBuy(this,false,this.getItem(),this.count);
               this.dispOverlay(this.getOverlayUrl());
               if(buyResult)
               {
                  m_isFullyBuilt = true;
                  state = STATE_BUILT;
                  TransactionManager.addTransaction(new TTransformBuilding(this,true));
               }
            }
            FarmStatsManager.count(getItem().statsCounter,"maturation","complete_now","accept");
         }
         else
         {
            FarmStatsManager.count(getItem().statsCounter,"maturation","complete_now","cancel");
         }
      }
      
      override protected function showStorageContextMenu() : Boolean
      {
         return false;
      }
      
      override public function getFinishedItem() : FarmItem
      {
         var muteState:MutableAnimalState = null;
         var farmItem:FarmItem = null;
         var featureName:String = null;
         var parentName:String = null;
         var result:FarmItem = null;
         if(this.m_mutableAnimalState != null)
         {
            muteState = this.m_mutableAnimalState;
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getItem().name);
            featureName = Global.animalBreedingSettings.getFeatureNameByItem(farmItem.name);
            parentName = Global.animalBreedingSettings.getItemNameFromGender(featureName,muteState.dna[MutableAnimalState.GENDER_DATA_KEY]);
            result = Global.farmGameSettingsManager.getFarmItemByName(parentName);
         }
         return result;
      }
      
      override protected function createRewardFeed(feedActionName:String, statsKingdom:String, rewardLink:String, iconURL:String, postFeedCallback:Function = null, dialogIconURL:String = null, postFeedCallbackAccept:Function = null, friendlyItemName:String = null, locParams:Object = null, statsClass:String = "", dialogName:String = null, finishedRewardItemName:String = "", fallbackFeedKey:String = "", fallbackStats:Object = null, canSuppressPopup:Boolean = false, checkbox:Boolean = false, checkboxText:String = "") : void
      {
         var bundleData:Object = null;
         var localizedText:String = null;
         var hasLocalization:Boolean = ZLocUtils.hasString("Dialogs",feedActionName);
         var lambName:String = "";
         if(this.m_mutableAnimalState != null)
         {
            lambName = this.m_mutableAnimalState.name;
         }
         if(Boolean(rewardLink) && hasLocalization)
         {
            bundleData = {
               "reward_link":rewardLink,
               "animalName":lambName,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":iconURL
               }]
            };
            if(friendlyItemName != null)
            {
               bundleData["item"] = friendlyItemName;
            }
            if(!dialogIconURL)
            {
               dialogIconURL = iconURL;
            }
            if(locParams)
            {
               localizedText = ZLocUtils.t("Dialogs",feedActionName,locParams);
            }
            else
            {
               localizedText = ZLocUtils.t("Dialogs",feedActionName);
            }
            UI.displayPopup(new GenericIconPopup(localizedText,GenericPopup.TYPE_SHARECANCEL,this.generateOnConfirmShareFeed(feedActionName,bundleData,statsKingdom,statsClass,getItem().name,postFeedCallback,postFeedCallbackAccept),dialogIconURL,false,true,"",false,GenericIconPopup.GENERIC_CALLOUT_ASSET,[m_colorMatrixFilter]));
         }
      }
      
      override public function onFullyFinished(result:Object, transformedObj:MapResource = null) : void
      {
         var item:FarmItem = null;
         var patternTrait:String = null;
         var callback:Function = null;
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("bottle");
         item = this.getItem();
         if(this.m_mutableAnimalState != null)
         {
            if(transformedObj != null)
            {
               callback = function(rawData:Object):void
               {
                  var imagePath:String = rawData.imagePath;
                  var statsKingdom:String = item.name + "_" + StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM;
                  createRewardFeed(m_buildingName + "FullyBuilt",statsKingdom,result.rewardLink,imagePath,null,imagePath,statCountConstructableComplete,m_mutableAnimalState.name,{"item":m_mutableAnimalState.name});
               };
               (transformedObj as MutableAnimal).setImageLoadedCallback(function():void
               {
                  var ugcImage:UGCFeedImage = new UGCFeedImage(transformedObj,UserContentManager.FEATURE_ANIMAL_BREEDING);
                  ugcImage.applyConfigTransforms(transformedObj.getItem().ugcTransforms);
                  UserContentManager.getInstance().createFeedImage(ugcImage,callback);
               });
            }
            patternTrait = Global.animalBreedingSettings.getPatternTrait(Global.animalBreedingSettings.getFeatureNameByItem(getItem().name),this.m_mutableAnimalState.pattern);
            FarmStatsManager.count(getItem().statsCounter,"maturation","grown_up",this.m_mutableAnimalState.statsHSV + ":T:" + patternTrait);
         }
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         var featureName:String = null;
         var featureObjects:Array = null;
         var farmItem:FarmItem = getItem();
         if(farmItem != null)
         {
            featureName = Global.animalBreedingSettings.getFeatureNameByItem(getItem().name);
            featureObjects = Global.world.getObjectsByName(featureName);
            if(featureObjects != null && featureObjects.length > 0)
            {
               if(featureObjects[0] is FeatureBuilding)
               {
                  (featureObjects[0] as FeatureBuilding).displayStorageDialog();
               }
            }
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = "";
         if(m_item != null)
         {
            if(m_direction == Constants.DIRECTION_SE || m_direction == Constants.DIRECTION_SW)
            {
               imageName = "frt_idle";
            }
            else
            {
               imageName = "bk_idle";
            }
         }
         return imageName;
      }
      
      override protected function generateOnConfirmShareFeed(feedAction:String, bundleData:Object, statsKingdon:String, statsClass:String, itemName:String, callbackFunction:Function = null, callbackFunctionOnAccept:Function = null) : Function
      {
         return function(event:GenericPopupEvent):void
         {
            if(event.button == GenericPopup.ACCEPT)
            {
               GlobalEngine.socialNetwork.publishFeedStory(feedAction,bundleData,[],false);
               if(callbackFunctionOnAccept != null)
               {
                  callbackFunctionOnAccept();
               }
            }
            else
            {
               TransactionManager.addTransaction(new TCancelFriendReward([bundleData["reward_link"]]));
            }
         };
      }
      
      public function getPackedMutableState() : String
      {
         var result:String = null;
         if(this.m_mutableAnimalState != null)
         {
            result = this.m_mutableAnimalState.getPackedMutableState();
         }
         return result;
      }
      
      override public function getMetadata() : Object
      {
         return this.getPackedMutableState();
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         m_displayStorageDialog = false;
         return super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
      }
      
      public function getMutableAnimalState() : MutableAnimalState
      {
         return this.m_mutableAnimalState;
      }
   }
}

