package Classes
{
   import AvatarMode.AMHarvest;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.Experiments;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import GameMode.GMBuildingPart;
   import GameMode.GameMode;
   import Managers.AvatarRetentionExperimentUtil;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.RetentionMasterManager;
   import Managers.ToasterManager;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.IconToasterWindow;
   import flash.utils.Dictionary;
   
   public class HarvestableStorageBuilding extends StorageBuilding
   {
      
      public static const ANTI_STUFFING_PERCENTAGE:Number = 0.04;
      
      protected var m_harvestYieldsGroup:HarvestYieldsGroup;
      
      public function HarvestableStorageBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      public static function getItemCodeForMasteryOverrideExportName(itemCode:String) : String
      {
         var convertToItemObject:FarmItem = null;
         var code:String = itemCode;
         var itemObject:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
         if(Boolean(itemObject) && Boolean(itemObject.overrideExportName) && itemObject.overrideExportName != "ugc_fish")
         {
            convertToItemObject = Global.farmGameSettingsManager.getFarmItemByName(itemObject.overrideExportName);
            if(Boolean(convertToItemObject) && Boolean(convertToItemObject.code))
            {
               code = convertToItemObject.code;
            }
         }
         return code;
      }
      
      public function get harvestYieldsGroup() : HarvestYieldsGroup
      {
         return this.m_harvestYieldsGroup;
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var success:Boolean = false;
         this.updatePlantTimeOnStore(m_count,resource);
         return Boolean(super.addItem(resource,fromStorage,isGift,sendStoreItem,force));
      }
      
      protected function updatePlantTimeOnStore(itemCount:int, resource:MapResource) : void
      {
         var stuffingPrevention:Boolean = false;
         var itemXml:XML = null;
         var stuffingPreventionPrereq:String = null;
         var hasStuffingPreventionPrereqProp:Boolean = false;
         var growTime:int = 0;
         var daysToMilliseconds:Number = NaN;
         var totalGrowTime:Number = NaN;
         var timeDelay:Number = NaN;
         var newPlantTime:Number = NaN;
         var toaster:IconToasterWindow = null;
         var item:FarmItem = getItem();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(item.hasPropertyInDataSource("stuffingPrevention"))
            {
               stuffingPrevention = item.getBoolFromDataSource("stuffingPrevention");
            }
            hasStuffingPreventionPrereqProp = item.hasPropertyInDataSource("stuffingPreventionPrereq");
            if(hasStuffingPreventionPrereqProp)
            {
               stuffingPreventionPrereq = item.getStringFromDataSource("stuffingPreventionPrereq");
            }
            if(item.hasPropertyInDataSource("growTime"))
            {
               growTime = item.getIntFromDataSource("growTime");
            }
         }
         else
         {
            itemXml = getItem().xml;
            if(itemXml.hasOwnProperty("stuffingPrevention"))
            {
               stuffingPrevention = itemXml.stuffingPrevention.toString() == "true";
            }
            hasStuffingPreventionPrereqProp = itemXml.hasOwnProperty("stuffingPreventionPrereq");
            if(hasStuffingPreventionPrereqProp)
            {
               stuffingPreventionPrereq = itemXml["stuffingPreventionPrereq"].toString();
            }
            if(itemXml.hasOwnProperty("growTime"))
            {
               growTime = int(itemXml.growTime);
            }
         }
         if(itemCount == 0)
         {
            plantTime = Global.worldTime;
            setState(STATE_BARE);
         }
         else if(itemCount > 0 && resource is HarvestableResource && stuffingPrevention)
         {
            if(!hasStuffingPreventionPrereqProp || PrerequisiteUtility.checkPrereqByName(stuffingPreventionPrereq))
            {
               daysToMilliseconds = Global.farmGameSettingsManager.inGameDaySeconds * FarmGameUtil.NUM_MSECS_IN_SECOND;
               totalGrowTime = growTime * daysToMilliseconds * Global.farmGameSettingsManager.growMultiplier;
               timeDelay = Math.round(getGrowTime() * ANTI_STUFFING_PERCENTAGE);
               newPlantTime = 0;
               if(getGrowPercentage() >= 100)
               {
                  newPlantTime = Math.min(Global.worldTime,Global.worldTime - totalGrowTime + timeDelay);
               }
               else
               {
                  newPlantTime = Math.min(Global.worldTime,m_plantTime + timeDelay);
               }
               plantTime = newPlantTime;
               updateGrowPercentage();
               if(!Global.player.getSeenFlag("FeatureBuildingStuffingPreventionToaster"))
               {
                  toaster = new IconToasterWindow(this.getItem().icon,ZLocUtils.t("Dialogs","FeatureBuildingAntiStuddingReadyDrop",{
                     "item":getItem().friendlyTitle,
                     "addedItem":resource.getItem().friendlyTitle
                  }));
                  ToasterManager.getInstance().add(toaster);
                  Global.player.setSeenFlag("FeatureBuildingStuffingPreventionToaster");
               }
            }
         }
      }
      
      override protected function buildTooltipText() : String
      {
         var toolTip:String = null;
         if(isHighlighted())
         {
            if(Global.worldManager.isVisiting())
            {
               toolTip = m_item.friendlyTitle;
            }
            else
            {
               toolTip = this.getHarvestTooltip();
            }
         }
         return toolTip;
      }
      
      public function getToolTipCapacityText() : String
      {
         return ZLocUtils.t("Items",m_item.name + "_capacity",{
            "quantity":m_count,
            "maximum":capacity
         });
      }
      
      protected function getHarvestTooltip() : String
      {
         var capacityText:String = null;
         var harvestTimeVariant:int = 0;
         var growPercentage:int = 0;
         var toolTip:String = null;
         var mode:GameMode = Global.world.getTopGameMode();
         if(mode is GMBuildingPart)
         {
            capacityText = getBuildingPartCapacityToolTipText((mode as GMBuildingPart).buildingPart.itemName);
         }
         else
         {
            capacityText = this.getToolTipCapacityText();
            if(!isFullyBuilt())
            {
               capacityText = ZLocUtils.t("Items",m_item.name + "_mats",{
                  "quantity":m_count,
                  "maximum":capacity
               });
            }
         }
         switch(state)
         {
            case STATE_RIPE:
               toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_ready",{
                  "item":ZLocUtils.tk_pk(m_item.friendlyName),
                  "capacityStr":capacityText
               });
               break;
            case STATE_BARE:
               harvestTimeVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HARVEST_TIME_2);
               if(RetentionMasterManager.inMasterExperiment() && (harvestTimeVariant == 2 || harvestTimeVariant == 4))
               {
                  toolTip = getHarvestTimeText("AnimalBuilding_toolTip_time") + "\n" + capacityText;
               }
               else
               {
                  growPercentage = getGrowPercentage();
                  toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_toolTip",{
                     "item":ZLocUtils.tk_pk(m_item.friendlyName),
                     "quantity":growPercentage,
                     "capacityStr":capacityText
                  });
               }
               break;
            case STATE_CONSTRUCTION:
            case STATE_BUILT:
               toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                  "item":ZLocUtils.tk_pk(m_item.friendlyName),
                  "capacityStr":capacityText
               });
               break;
            default:
               toolTip = m_item.friendlyTitle;
         }
         return toolTip;
      }
      
      override public function removeContents(itemCode:String, itemCount:int = 1, itemParts:int = 0) : void
      {
         super.removeContents(itemCode,itemCount,itemParts);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(item)
         {
            FarmStatsManager.featureSample("farm_world_action","remove_item_from_storage",m_item.name,item.name);
         }
         if(m_count == 0)
         {
            setState(STATE_BUILT);
         }
      }
      
      override public function isBuilt() : Boolean
      {
         return state == STATE_BUILT || state == STATE_CONSTRUCTION || state == STATE_RIPE || state == STATE_BARE;
      }
      
      override public function showMenu() : void
      {
         var actionText:String = null;
         if(!inQueue())
         {
            if(state == STATE_RIPE)
            {
               actionText = this.m_item.actionText;
               m_menuItems.push({
                  "label":ZLocUtils.t("Items",actionText + "_friendlyName"),
                  "action":HARVEST_OBJECT
               });
            }
            super.showMenu();
         }
         else
         {
            displayStatus(ZLocUtils.t("FarmGame","Harvesting"));
         }
      }
      
      override public function onClick() : void
      {
         var bldgstate:AMHarvest = null;
         onMouseOut();
         if(!hasValidId())
         {
            showObjectBusy();
         }
         else if(state == STATE_RIPE && Global.selectedAvatar != null && !Global.worldManager.isVisiting())
         {
            bldgstate = Global.selectedAvatar.getStateMachine().getState() as AMHarvest;
            if(bldgstate != null && bldgstate.getResource() != this || bldgstate == null)
            {
               Global.selectedAvatar.getStateMachine().addState(new AMHarvest(Global.selectedAvatar,this),true);
               m_isInHarvestQueue = true;
            }
         }
         else
         {
            super.onClick();
         }
      }
      
      public function getHarvestAmount() : int
      {
         var coinYield:int = 0;
         var isInDataSourceExperiment:Boolean = false;
         var curItem:FarmItem = null;
         var key:String = null;
         var total:int = 0;
         var contents:Dictionary = m_contents;
         if(contents)
         {
            isInDataSourceExperiment = FarmGameSettingsManager.isInDataSourceExperiment();
            for(key in contents)
            {
               if(contents[key] > 0)
               {
                  curItem = Global.farmGameSettingsManager.getFarmItemByCode(key);
                  if(isInDataSourceExperiment)
                  {
                     coinYield = curItem.getIntFromDataSource("coinYield");
                  }
                  else
                  {
                     coinYield = int(curItem.xml.coinYield);
                  }
                  total += contents[key] * coinYield;
               }
            }
         }
         return total;
      }
      
      protected function applyHarvestYields() : void
      {
         var key:String = null;
         var itemObject:FarmItem = null;
         var count:int = 0;
         var multiplier:Number = NaN;
         for(key in m_contents)
         {
            if(m_contents[key] > 0)
            {
               itemObject = Global.farmGameSettingsManager.getFarmItemByCode(key);
               if(itemObject is HarvestableItem)
               {
                  count = int(m_contents[key]);
                  multiplier = 1;
                  if(Boolean(m_bonusMultipliers) && Boolean(m_bonusMultipliers.harvestYield))
                  {
                     multiplier = Number(m_bonusMultipliers.harvestYield);
                  }
                  this.m_harvestYieldsGroup.applyHarvestYieldsForItem(itemObject as HarvestableItem,count,multiplier);
               }
            }
         }
      }
      
      public function getMasteryYield() : int
      {
         var key:String = null;
         var selfMastery:Mastery = null;
         var selfMasteryYield:int = 0;
         var item:FarmItem = null;
         var itemMastery:Mastery = null;
         var maxMastery:int = 0;
         var masteryYield:int = 0;
         var contents:Dictionary = m_contents;
         for(key in contents)
         {
            if(contents[key] > 0)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(key);
               itemMastery = Mastery.createMasteryForItem(item);
               maxMastery = int(contents[key]);
               if(itemMastery.lastMasteryLevel())
               {
                  maxMastery = Math.min(itemMastery.remainingCropsToNextLevel,contents[key]);
                  if(masteryYield < 0)
                  {
                     masteryYield = 0;
                  }
               }
               masteryYield += Mastery.createMasteryForItem(item).calculateMasteryYield() * maxMastery;
               masteryYield += masteryBonusCumulative * maxMastery;
            }
         }
         selfMastery = Mastery.createMasteryForItem(m_item);
         selfMasteryYield = selfMastery.calculateMasteryYield();
         return int(masteryYield + selfMasteryYield);
      }
      
      override public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         var key:String = null;
         var statusString:String = null;
         var result:Object = new Object();
         var contentCount:Number = 0;
         this.m_harvestYieldsGroup = new HarvestYieldsGroup();
         for(key in m_contents)
         {
            if(m_contents[key] > 0)
            {
               contentCount += m_contents[key];
            }
         }
         if(contentCount > 0 || this.getHarvestAmount() > 0)
         {
            result.coinYield = Math.round(this.getHarvestAmount() * coinBonusMultiplier);
            result.masteryYield = Math.round(this.getMasteryYield() * masteryBonusMultiplier);
            result.worldCurrency = getHarvestCurrency();
            Global.player.updateWorldCurrency(result.worldCurrency,int(result.coinYield),true);
            result.coinYield *= Global.player.getWorldCurrencyMultiplier(result.worldCurrency);
            this.applyHarvestYields();
            if(showStatus)
            {
               statusString = this.m_harvestYieldsGroup.getDooberStatus();
               if(result.masteryYield > 0)
               {
                  statusString += ZLocUtils.t("FarmGame","Status_HarvestPlotMastery",{
                     "coinNum":result.coinYield,
                     "masteryNum":result.masteryYield
                  });
               }
               else if(result.coinYield > 0)
               {
                  switch(result.worldCurrency)
                  {
                     case Currency.JADE:
                        statusString += ZLocUtils.t("FarmGame","Status_HarvestPlotJade",{"coinNum":result.coinYield});
                        break;
                     case Currency.COINS:
                     default:
                        statusString += ZLocUtils.t("FarmGame","Status_HarvestPlot",{"coinNum":result.coinYield});
                  }
               }
               if(AvatarRetentionExperimentUtil.inNoWaitExperiment())
               {
                  this.displayStatus(statusString);
               }
               else
               {
                  avatar.displayStatus(statusString);
               }
            }
         }
         super.doHarvestDropOff(avatar);
         m_isInHarvestQueue = false;
         return result;
      }
      
      override public function isHarvestable() : Boolean
      {
         return (getGrowPercentage() == 100 || state == STATE_RIPE) && this.isHarvestEnabled();
      }
      
      public function isHarvestEnabled() : Boolean
      {
         return true;
      }
      
      override protected function addDefaultItems(defaultItem:FarmItem, amount:int) : void
      {
         super.addDefaultItems(defaultItem,amount);
         setState(STATE_BARE);
      }
      
      override public function getActionText() : String
      {
         return ZLocUtils.t("FarmGame","Harvesting");
      }
      
      override public function setFullGrown() : void
      {
         super.setFullGrown();
         if((!this.needItemsForHarvest || this.count > 0) && m_isFullyBuilt)
         {
            setState(STATE_RIPE);
         }
         else
         {
            setState(STATE_BARE);
            plantTime = 0;
         }
      }
      
      protected function get needItemsForHarvest() : Boolean
      {
         return true;
      }
      
      override public function getHarvestYieldTypes() : Array
      {
         var key:String = null;
         var item:HarvestableItem = null;
         var harvestYields:Vector.<HarvestYield> = null;
         var harvestYield:HarvestYield = null;
         var result:Array = new Array();
         for(key in m_contents)
         {
            if(m_contents[key] > 0)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(key) as HarvestableItem;
               if(item)
               {
                  harvestYields = item.harvestYields;
                  for each(harvestYield in harvestYields)
                  {
                     if(result.indexOf(harvestYield.type) < 0)
                     {
                        result.push(harvestYield.type);
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getBounsMultiplier() : Object
      {
         return m_bonusMultipliers;
      }
   }
}

