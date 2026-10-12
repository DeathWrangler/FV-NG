package Classes
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.Terrain.TerrainUtil;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.StatsDropDown;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import Events.TileUnlockEvent;
   import GameMode.GMBuildingPart;
   import Managers.AOEManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.ItemFinderManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TTransformTreasure;
   import Widgets.Windows.MultiTreasureHoverOverWindow;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Managers.QuestManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class MultiRewardTreasureConstructionBuilding extends FeatureBuilding
   {
      
      public static const NON_PAYER_TILE:String = "MultiRewardTreasureConstructionBuilding";
      
      public static const PAYER_TILE:String = "MultiRewardTreasurePayerConstructionBuilding";
      
      public static const PAYER_BUNDLE_TILE:String = "MultiRewardTreasurePayerBundleConstructionBuilding";
      
      public static const PAYER_LAND_BUNDLE:String = "MultiRewardTreasurePayerLandBundleConstructionBuilding";
      
      public static const NEW_LAND_BUNDLE:String = "LandBundleUnlockFeatureTreasureConstructionBuilding";
      
      public static const START_TIME:String = "startTime";
      
      public static const SHOULD_SHOW_ADJACENT_TEXT:String = "shouldShowAdjacentText";
      
      public static const REWARDS:String = "rewards";
      
      public static const REWARDS_FENCE:String = "rewardsFence";
      
      public static const FENCE_COUNT:String = "fenceCount";
      
      public static const SLOT_ITEMS:String = "slotItems";
      
      public static const SHOULD_SHOW_JMINNOVATION_GA:String = "shouldShowJMIGAReward";
      
      protected static const LOCKED_STATE:String = "built_0";
      
      public static const TREASURE_UNLOCK_ANIM_ASSET_PATH:String = "assets/effects/fireworks.swf";
      
      protected static const HOVER_MENU_TIME_MS:int = 800;
      
      protected static const TRANSFORM_COMPLETE:String = "transformComplete";
      
      protected static var m_transformStarted:Boolean = false;
      
      protected static var m_hoverWindows:Object = new Object();
      
      protected var m_payerTile:Boolean;
      
      protected var m_hoverOverWindowAssetLocked:String = "assets/dialogs/Avalon1/FV_xma_landUnlockLocked.swf";
      
      protected var m_hoverOverWindowAssetReady:String = "assets/dialogs/Avalon1/FV_xma_landUnlockReady.swf";
      
      protected var m_hoveringContextMenuState:String;
      
      protected var m_frictionlessBuyActive:Boolean = false;
      
      protected var m_hoverCallbackObject:Object = null;
      
      protected var m_cashBuyKingdom:String = "";
      
      protected var m_prereqName:String = "";
      
      protected var m_allPrereqDetails:Object;
      
      protected var isDatePreqMet:Boolean = false;
      
      protected var m_currentWindowAsset:String;
      
      private var m_questName:String;
      
      protected var m_prereqObject:Object;
      
      protected var m_eventName:String;
      
      public function MultiRewardTreasureConstructionBuilding(itemName:String = null)
      {
         var lockedHoverWindowAsset:String = null;
         var readyHoverWindowAsset:String = null;
         this.m_allPrereqDetails = {};
         if(itemName == "xwi_rubbletreasure_christmas")
         {
            Global.world.addEventListener(FarmGameWorldEvent.UNLOCK_TILE,this.unlockNow);
         }
         super(itemName);
         if(!Global.worldManager.isVisiting())
         {
            lockedHoverWindowAsset = Global.farmGameSettingsManager.getImageByName(itemName,"lock",false);
            readyHoverWindowAsset = Global.farmGameSettingsManager.getImageByName(itemName,"ready",false);
            if(lockedHoverWindowAsset)
            {
               this.m_hoverOverWindowAssetLocked = lockedHoverWindowAsset;
            }
            if(readyHoverWindowAsset)
            {
               this.m_hoverOverWindowAssetReady = readyHoverWindowAsset;
            }
            GlobalEventManager.getInstance().addEventListener(MultiRewardTreasureConstructionBuilding.TRANSFORM_COMPLETE,this.onTransformComplete);
            QuestManager.getInstance().addEventListener(QuestEvent.COMPLETED,this.onQuestComplete);
            this.m_prereqName = getMultiTreasurePrereqName();
            this.m_hoveringContextMenuState = getHoveringContextMenuState();
            this.m_frictionlessBuyActive = useFrictionlessBuy();
            this.m_hoverCallbackObject = {
               "completeNowCallback":this.completeNow,
               "unlockNowCallback":this.unlockNow,
               "getCashNeededCallback":this.getTreasureCost
            };
            this.m_prereqObject = Global.farmGameSettingsManager.getPrereqByName(this.m_prereqName);
            this.updateDataFromPrereq(this.m_prereqObject);
         }
      }
      
      protected static function showHoverMenu(treasure:MultiRewardTreasureConstructionBuilding, treasureQuestDetails:Object, hoverCallbackObject:Object, hoverOverWindowAsset:String, timerTime:int = -1, payerTile:Boolean = false) : void
      {
         if(m_hoverWindows[hoverOverWindowAsset] != null && Boolean(m_hoverWindows[hoverOverWindowAsset].isLoaded()))
         {
            m_hoverWindows[hoverOverWindowAsset].updateAndShow(treasure,treasureQuestDetails,hoverCallbackObject,timerTime,payerTile);
         }
         else if(m_hoverWindows[hoverOverWindowAsset] == null)
         {
            m_hoverWindows[hoverOverWindowAsset] = new MultiTreasureHoverOverWindow(treasure,treasureQuestDetails,hoverCallbackObject,timerTime,hoverOverWindowAsset,payerTile);
            UI.addHoverWindow(m_hoverWindows[hoverOverWindowAsset]);
         }
      }
      
      private function onQuestComplete(event:QuestEvent) : void
      {
         if(Boolean(event) && Boolean(event.quest) && Boolean(event.quest.name))
         {
            if(event.quest.name == this.m_questName)
            {
               if(PrerequisiteUtility.isPrerequisiteMet(this.m_prereqObject))
               {
                  setState(LOCKED_STATE);
               }
            }
         }
      }
      
      private function onTransformComplete(event:Event) : void
      {
         var prereqName:String = getMultiTreasurePrereqName();
         var prereqObject:Object = Global.farmGameSettingsManager.getPrereqByName(prereqName);
         if(Boolean(this.m_prereqObject) && Boolean(prereqObject) && PrerequisiteUtility.isPrerequisiteMet(prereqObject))
         {
            setState(LOCKED_STATE);
         }
      }
      
      protected function getTreasureCost() : int
      {
         var result:int = 0;
         if(getItem().realCashCost > 0)
         {
            result = getItem().realCashCost;
         }
         return result;
      }
      
      protected function updateDataFromPrereq(prereq:Object) : void
      {
         var childPrereq:Object = null;
         if(Boolean(prereq) && Boolean(prereq[FarmGameSettingsManager.XML_CHILDREN_FIELD]))
         {
            for each(childPrereq in prereq[FarmGameSettingsManager.XML_CHILDREN_FIELD])
            {
               this.updateDataFromSinglePrereq(childPrereq);
            }
         }
      }
      
      protected function updateDataFromSinglePrereq(prereq:Object) : void
      {
         var quest:FarmQuest = null;
         var isQuestComplete:Boolean = false;
         var isPrereqMet:Boolean = false;
         var farmTasks:Vector.<FarmTask> = null;
         var i:int = 0;
         var slotItems:Array = new Array();
         switch(prereq.type)
         {
            case PrerequisiteConstants.PREREQUISITE_START_TIME:
               if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
               {
                  this.m_allPrereqDetails[START_TIME] = prereq.value;
               }
               else
               {
                  this.isDatePreqMet = true;
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_QUEST_COMPLETE:
               quest = FarmQuestSettingsInit.getInstance().getItemByName(prereq.value) as FarmQuest;
               isQuestComplete = PrerequisiteUtility.isPrerequisiteMet(prereq);
               if(quest)
               {
                  farmTasks = quest.farmTasks;
                  this.m_questName = quest.name;
                  for(i = 0; i < farmTasks.length; i++)
                  {
                     slotItems.push({
                        "task":farmTasks[i],
                        "progress":(isQuestComplete ? 1 : farmTasks[i].progress)
                     });
                  }
                  this.m_allPrereqDetails[SLOT_ITEMS] = slotItems;
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_PREREQ_REFERENCE:
               isPrereqMet = PrerequisiteUtility.isPrerequisiteMet(prereq);
               this.m_allPrereqDetails[SHOULD_SHOW_ADJACENT_TEXT] = !isPrereqMet;
         }
      }
      
      protected function completeNow() : void
      {
         var treasurecost:int = 0;
         var reward:int = FeatureOptionsManager.getInstance().getFeatureOption("DreamWorldInnovation","k11") as int;
         var treasureName:String = this.bldgName;
         if(!m_transformStarted && Global.player.canBuyCash(getCashNeeded(),true,"expand_treasure_farm"))
         {
            if(treasureName == "xdw_tile_special" && reward > 0)
            {
               treasurecost = this.getTreasureCost();
               if(reward == 1)
               {
                  treasurecost = 0;
               }
               if(reward == 2)
               {
                  treasurecost *= 0.4;
               }
               if(reward == 3)
               {
                  treasurecost *= 0.6;
               }
               if(reward == 4)
               {
                  treasurecost *= 0.8;
               }
               UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
                  "cashQuantity":treasurecost.toString(),
                  "item":ZLocUtils.tk_pk(getItemFriendlyName())
               }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompletePopupClose,"",true);
            }
            else if(this.m_frictionlessBuyActive)
            {
               this.frictionlessCompleteNow(true);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
                  "cashQuantity":this.getTreasureCost().toString(),
                  "item":ZLocUtils.tk_pk(getItemFriendlyName())
               }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompletePopupClose,"",true);
            }
         }
         this.m_cashBuyKingdom = "complete_now";
      }
      
      protected function frictionlessCompleteNow(transformBuildingOnComplete:Boolean = false, callback:Function = null) : void
      {
         var cashNeeded:int = 0;
         var reward:int = FeatureOptionsManager.getInstance().getFeatureOption("DreamWorldInnovation","k11") as int;
         var treasureName:String = this.bldgName;
         if(!m_transformStarted)
         {
            cashNeeded = this.getTreasureCost();
            if(Boolean(reward) && treasureName == "xdw_tile_special")
            {
               if(reward == 1)
               {
                  cashNeeded = 0;
               }
               if(reward == 2)
               {
                  cashNeeded *= 0.4;
               }
               if(reward == 3)
               {
                  cashNeeded *= 0.6;
               }
               if(reward == 4)
               {
                  cashNeeded *= 0.8;
               }
            }
            if(Global.player.canBuyCash(cashNeeded,true))
            {
               Global.player.cash -= cashNeeded;
               TransactionManager.addTransaction(new TTransformTreasure(this,transformBuildingOnComplete,callback));
               m_transformStarted = true;
               if(Global.hud)
               {
                  Global.hud.removeHudLandBundle();
               }
            }
         }
      }
      
      public function unlockNow(e:Event = null, callback:Function = null) : void
      {
         if(!m_transformStarted)
         {
            TransactionManager.addTransaction(new TTransformTreasure(this,true,callback,true));
            m_transformStarted = true;
         }
      }
      
      public function onUnlockTileCallback(e:Event) : void
      {
         ItemFinderManager.getInstance().highlightWorldItems("bldg_northpoletoyworks");
      }
      
      protected function onConfirmCompletePopupClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            FarmStatsManager.count("expand_treasure_farm",bldgName,"confirm_dialog","accept");
            this.frictionlessCompleteNow(true);
         }
         else
         {
            FarmStatsManager.count("expand_treasure_farm",bldgName,"confirm_dialog","cancel");
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         if(this.m_hoveringContextMenuState == HOVERING_CONTEXT_OFF)
         {
            this.setHighlighted(false);
         }
      }
      
      override public function onClick() : void
      {
         var itemPackageHash:Object = null;
         var itemPackageFenceHash:Object = null;
         var callbackEvt:String = null;
         var dialogConfig:Object = null;
         var rewards:Array = null;
         var itemName:String = null;
         var isEA:Boolean = false;
         var dialogClassName:String = null;
         var dialogClass:Class = null;
         var dialog:* = undefined;
         if(!Global.worldManager.isVisiting() && !m_transformStarted)
         {
            this.isDatePreqMet = false;
            this.m_allPrereqDetails = {};
            this.m_allPrereqDetails[SHOULD_SHOW_ADJACENT_TEXT] = false;
            this.updateDataFromPrereq(this.m_prereqObject);
            if(this.m_payerTile)
            {
               this.m_currentWindowAsset = this.m_hoverOverWindowAssetLocked;
            }
            else
            {
               this.m_currentWindowAsset = this.m_hoverOverWindowAssetReady;
            }
            itemPackageHash = this.getItem().getItemPackageHash();
            itemPackageFenceHash = this.getItem().getItemPackageFenceHash();
            if(itemPackageHash != null)
            {
               rewards = new Array();
               for(itemName in itemPackageHash)
               {
                  rewards.push(itemName);
               }
               this.m_allPrereqDetails[REWARDS] = rewards;
            }
            if(itemPackageFenceHash != null)
            {
               rewards = new Array();
               for(itemName in itemPackageFenceHash)
               {
                  this.m_allPrereqDetails[FENCE_COUNT] = itemPackageFenceHash[itemName];
                  rewards.push(itemName);
               }
               this.m_allPrereqDetails[REWARDS_FENCE] = rewards;
            }
            callbackEvt = getItem().eventCallbackName;
            if(callbackEvt != "")
            {
               isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_JUNGLE);
               if(!isEA)
               {
                  this.m_allPrereqDetails[SHOULD_SHOW_JMINNOVATION_GA] = true;
               }
            }
            this.m_hoveringContextMenuState = getHoveringContextMenuState();
            dialogConfig = this.getItem().getDialogConfig("storage");
            if(dialogConfig)
            {
               dialogClassName = dialogConfig.className;
               dialogClass = getDefinitionByName(dialogClassName) as Class;
               dialog = new dialogClass(this,true);
               UI.displayPopup(dialog);
            }
            else if(this.m_hoveringContextMenuState == HOVERING_CONTEXT_MOUSE_OVER && !(Global.world.getTopGameMode() is GMBuildingPart))
            {
               showHoverMenu(this,this.m_allPrereqDetails,this.m_hoverCallbackObject,this.m_currentWindowAsset,HOVER_MENU_TIME_MS,this.m_payerTile);
            }
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var prereqMet:Boolean = false;
         var currentImageName:String = "";
         if(this.m_payerTile)
         {
            currentImageName = LOCKED_STATE;
         }
         else if(this.m_prereqObject)
         {
            prereqMet = PrerequisiteUtility.isPrerequisiteMet(this.m_prereqObject);
            currentImageName = LOCKED_STATE;
            if(prereqMet)
            {
               m_arrowArt = GUITAR_PICK;
               if(m_arrow == null)
               {
                  m_arrow = generateHarvestArrow();
                  m_hideArrow = false;
               }
            }
         }
         return currentImageName;
      }
      
      private function grantUserRewards() : void
      {
         var treasureItem:FarmItem = this.getItem();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(Boolean(treasureItem) && Boolean(treasureItem.rewardsData))
            {
               UserRewardUtil.grantUserRewardsFromDataSource(treasureItem.rewardsData);
            }
         }
         else if(Boolean(treasureItem) && Boolean(treasureItem.rewardsXML))
         {
            UserRewardUtil.grantUserRewardsFromXml(treasureItem.rewardsXML);
         }
      }
      
      public function transformBuilding(resultData:Object = null) : Array
      {
         var overlayParams:Object = null;
         var finishedItems:Array = null;
         var currentItemName:String = null;
         var id:Number = NaN;
         var tempClass:Class = null;
         var callbackEvt:String = null;
         var itemObj:Object = null;
         var finishedItem:FarmItem = null;
         var currentPosition:Vector3 = null;
         var transformedObject:MapResource = null;
         var itemPlacable:Boolean = false;
         var typeAsClassName:String = null;
         var overlappingAreas:Boolean = false;
         var phylum:String = null;
         var result:Array = null;
         if(null != resultData)
         {
            m_transformStarted = false;
            overlayParams = new Object();
            finishedItems = this.getFinishedItemsFromResult(resultData);
            currentItemName = getItem().name;
            overlayParams.offsetY = 425;
            overlayParams.offsetX = 910;
            this.dispOverlay(TREASURE_UNLOCK_ANIM_ASSET_PATH,overlayParams);
            Global.player.removeLimitedItem(currentItemName);
            id = this.getId();
            detach();
            if(m_count < capacity)
            {
               Global.player.updatePlayerStat(StatsDropDown.INDEX_BUILDINGS,0);
            }
            if(finishedItems != null)
            {
               result = new Array();
               for each(itemObj in finishedItems)
               {
                  finishedItem = null;
                  if(itemObj != null && itemObj.hasOwnProperty("name"))
                  {
                     finishedItem = Global.farmGameSettingsManager.getFarmItemByName(itemObj["name"]);
                  }
                  if(finishedItem != null)
                  {
                     if(finishedItem.className != "")
                     {
                        tempClass = getDefinitionByName("Classes." + finishedItem.className) as Class;
                     }
                     else if(finishedItem.type)
                     {
                        typeAsClassName = "Classes." + FarmGameUtil.toUpperCaseFirst(finishedItem.type);
                        tempClass = getDefinitionByName(typeAsClassName) as Class;
                        if(!tempClass)
                        {
                           tempClass = getDefinitionByName("Classes.Building") as Class;
                        }
                     }
                     else
                     {
                        tempClass = getDefinitionByName("Classes.Building") as Class;
                     }
                     currentPosition = new Vector3(itemObj["x"],itemObj["y"],itemObj["z"]);
                     transformedObject = null;
                     itemPlacable = TerrainUtil.isAreaAcceptable(finishedItem.getTerrainCodes(),currentPosition.x,currentPosition.y,currentPosition.x + finishedItem.sizeX,currentPosition.y + finishedItem.sizeY) && finishedItem.allMissingRequirements.length == 0;
                     if(itemPlacable && !isStoredFeature)
                     {
                        transformedObject = new tempClass(finishedItem.name);
                        transformedObject.setOuter(Global.world);
                        transformedObject.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
                        transformedObject.conditionallyReattach();
                        transformedObject.setId(itemObj["id"]);
                        if(transformedObject is FixedTreasureConstructionBuilding)
                        {
                           (transformedObject as FixedTreasureConstructionBuilding).setState(STATE_CONSTRUCTION);
                        }
                        else if(transformedObject is Building)
                        {
                           (transformedObject as Building).setState(STATE_BUILT);
                        }
                        else if(transformedObject is SimpleHarvestableResource)
                        {
                           (transformedObject as SimpleHarvestableResource).setFullGrown();
                        }
                        if(transformedObject.isAoeSource())
                        {
                           overlappingAreas = AOEManager.getInstance().hasOverlappingAreas(transformedObject);
                           phylum = overlappingAreas ? "area_overlaps_another" : "area_doesnt_overlap";
                           FarmStatsManager.count(AOEManager.STATS_COUNTER_NAME,bldgName,"placed_and_finished",phylum);
                        }
                     }
                     else
                     {
                        Global.player.addGift(finishedItem.name);
                     }
                     result.push(transformedObject);
                  }
               }
            }
            callbackEvt = getItem().eventCallbackName;
            if(callbackEvt != "")
            {
               GlobalEventManager.getInstance().dispatchEvent(new TileUnlockEvent(callbackEvt,this));
            }
         }
         return result;
      }
      
      public function onFullyFinished(result:Object) : void
      {
         this.grantUserRewards();
         FarmStatsManager.count("expand_treasure_farm",bldgName,"complete");
      }
      
      protected function getFinishedItemsFromResult(resultData:Object) : Array
      {
         var itemObj:Object = null;
         var finishedItems:Array = null;
         if(Boolean(resultData) && resultData.hasOwnProperty("finishedItems"))
         {
            finishedItems = new Array();
            for each(itemObj in resultData["finishedItems"])
            {
               finishedItems.push(itemObj);
            }
         }
         return finishedItems;
      }
   }
}

