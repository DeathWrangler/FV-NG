package Managers
{
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.AreasOfEffect.AOEConfig;
   import Classes.AreasOfEffect.AOEIntersection;
   import Classes.Constants.WorldsConstants;
   import Classes.HarvestableResource;
   import Classes.MapResource;
   import Classes.TimedActions.AOEStateChangeTimedAction;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Classes.AOEWorldObject;
   import Engine.Classes.SavedObject;
   import Engine.Classes.WorldObject;
   import Engine.Managers.ErrorManager;
   import com.infomatiq.jsi.RectangleUtil;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class AOEManager
   {
      
      private static var m_aoeObjectsCache:Dictionary;
      
      private static var m_instance:AOEManager = null;
      
      private static var m_initialized:Boolean = false;
      
      private static const AOE_ID_STARTING_VALUE:int = 65000;
      
      private static var m_aoeId:int = AOE_ID_STARTING_VALUE;
      
      public static const HARVEST_YIELD_BONUS_KEY:String = "harvestYield";
      
      public static const MASTERY_BONUS_KEY:String = "mastery";
      
      public static const BONUS_TYPE_MULT:String = "mult";
      
      public static const BONUS_TYPE_ADD:String = "add";
      
      public static const STATS_COUNTER_NAME:String = "aoe";
      
      private static const FEATURE_NAME_AOE_LICENSE:String = "aoeLicense";
      
      private var m_targetToSourceMapping:Dictionary;
      
      private var m_allConfigs:Array;
      
      private var m_aoeStateChangeSources:Object = new Object();
      
      public function AOEManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            m_aoeObjectsCache = new Dictionary();
            return;
         }
         throw new Error("Error: Instantiation failed: Use AreasOfEffectManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : AOEManager
      {
         if(m_instance == null)
         {
            m_instance = new AOEManager();
         }
         return m_instance;
      }
      
      public function getNewId() : int
      {
         return m_aoeId++;
      }
      
      public function addConfig(aoeConfig:AOEConfig) : void
      {
         if(!this.m_allConfigs)
         {
            this.m_allConfigs = new Array();
         }
         this.m_allConfigs.push(aoeConfig);
      }
      
      public function addAOEStateChangeSource(aoeSource:MapResource) : void
      {
         if(!this.m_aoeStateChangeSources)
         {
            this.m_aoeStateChangeSources = new Object();
         }
         if(!this.m_aoeStateChangeSources.hasOwnProperty(Global.worldManager.currentWorldType))
         {
            this.m_aoeStateChangeSources[Global.worldManager.currentWorldType] = new Array();
         }
         if((this.m_aoeStateChangeSources[Global.worldManager.currentWorldType] as Array).lastIndexOf(aoeSource) == -1)
         {
            this.m_aoeStateChangeSources[Global.worldManager.currentWorldType].push(aoeSource);
            Global.player.setSeenSessionFlag(Global.worldManager.currentWorldType + "AOESTATECHANGE_ADDEDTOQUEUE",false);
         }
      }
      
      public function resetAOEStateChangeSources() : void
      {
         this.m_aoeStateChangeSources = new Object();
      }
      
      public function getAOEStateChangeSources() : Array
      {
         var result:Array = null;
         if(this.m_aoeStateChangeSources.hasOwnProperty(Global.worldManager.currentWorldType))
         {
            result = this.m_aoeStateChangeSources[Global.worldManager.currentWorldType];
         }
         return result;
      }
      
      public function addAreaObject(aoeWorldObject:AOEWorldObject) : void
      {
         if(m_aoeObjectsCache[aoeWorldObject.getId()] == null)
         {
            m_aoeObjectsCache[aoeWorldObject.getId()] = aoeWorldObject;
         }
         else
         {
            ErrorManager.addError("AOEManager - adding aeoWorldObject with duplicate id");
         }
      }
      
      public function removeAreaObject(aoeWorldObject:AOEWorldObject) : void
      {
         if(m_aoeObjectsCache[aoeWorldObject.getId()])
         {
            delete m_aoeObjectsCache[aoeWorldObject.getId()];
         }
      }
      
      public function getAreaObjectSource(aoeWorldObj:AOEWorldObject) : WorldObject
      {
         var result:WorldObject = null;
         if(aoeWorldObj != null)
         {
            result = Global.world.getObjectById(aoeWorldObj.getParentId());
         }
         return result;
      }
      
      public function getAOEWorldObjectById(id:int) : AOEWorldObject
      {
         var result:AOEWorldObject = null;
         if(m_aoeObjectsCache[id])
         {
            result = m_aoeObjectsCache[id];
         }
         return result;
      }
      
      public function getAoeResourceIdsAffecting(targetResource:MapResource) : Array
      {
         var aoeResourceIds:Vector.<int> = null;
         var aoeResource:MapResource = null;
         var aoeConfig:AOEConfig = null;
         var i:int = 0;
         var id:int = 0;
         var result:Array = new Array();
         if(targetResource.isAoeTarget())
         {
            aoeResourceIds = Global.world.getContainingObjectIds(targetResource as WorldObject);
            for(i = 0; i < aoeResourceIds.length; i++)
            {
               id = aoeResourceIds[i];
               if(m_aoeObjectsCache[id])
               {
                  aoeResource = this.getAreaObjectSource(m_aoeObjectsCache[id] as AOEWorldObject) as MapResource;
                  if(aoeResource != null && Boolean(aoeResource.getItem()))
                  {
                     aoeConfig = aoeResource.getItem().aoeConfig;
                     if(aoeConfig != null)
                     {
                        if(aoeConfig.targets(targetResource) || aoeResource.equals(targetResource) && aoeConfig.targetsSelf)
                        {
                           result.push(aoeResource.getId());
                        }
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getResourcesAffectedBy(aoeResource:MapResource) : Array
      {
         var aoeWorldObjects:Vector.<AOEWorldObject> = null;
         var aoeConfig:AOEConfig = null;
         var i:int = 0;
         var resources:Vector.<WorldObject> = null;
         var j:int = 0;
         var result:Array = new Array();
         if(aoeResource.hasAreasOfEffect())
         {
            aoeWorldObjects = aoeResource.getAOEWorldObjects();
            aoeConfig = aoeResource.getItem().aoeConfig;
            for(i = 0; i < aoeWorldObjects.length; i++)
            {
               resources = Global.world.getContainedObjects(aoeWorldObjects[i]);
               for(j = 0; j < resources.length; j++)
               {
                  if(resources[j] != null && resources[j] is MapResource && aoeConfig.targets(resources[j] as MapResource))
                  {
                     result.push(resources[j]);
                  }
               }
            }
         }
         return result;
      }
      
      public function getResourceIdsAffectedBy(aoeResource:MapResource) : Array
      {
         var result:Array = new Array();
         var resources:Array = this.getResourcesAffectedBy(aoeResource);
         for(var j:int = 0; j < resources.length; j++)
         {
            result.push(resources[j].getId());
         }
         return result;
      }
      
      public function doesAoeResourceAffect(aoeResource:MapResource, targetResource:MapResource) : Boolean
      {
         var result:Boolean = false;
         var aoeResourceIds:Array = this.getAoeResourceIdsAffecting(targetResource);
         for(var i:int = 0; i < aoeResourceIds.length; i++)
         {
            if(aoeResource.equals(aoeResourceIds[i] as SavedObject))
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function getPotentialAoeResources(target:MapResource) : Array
      {
         var sourceItemCode:String = null;
         if(!this.m_targetToSourceMapping)
         {
            this.buildTargetToSourceMapping();
         }
         var targetItemCode:String = target.getItem().code;
         var sourceItemCodes:Array = this.m_targetToSourceMapping[targetItemCode] ? this.m_targetToSourceMapping[targetItemCode] : [];
         var result:Array = new Array();
         for each(sourceItemCode in sourceItemCodes)
         {
            result = result.concat(Global.world.getObjectsByCode(sourceItemCode));
         }
         return result;
      }
      
      public function getPotentialTargets(aoeResource:MapResource) : Array
      {
         var targetItemCodes:Array = null;
         var targetItemCode:String = null;
         if(Boolean(aoeResource) && Boolean(aoeResource.isAoeSource()) && Boolean(aoeResource.getItem()))
         {
            targetItemCodes = aoeResource.getItem().aoeConfig.getTargetItemCodes();
         }
         var result:Array = new Array();
         for each(targetItemCode in targetItemCodes)
         {
            result = result.concat(Global.world.getObjectsByCode(targetItemCode));
         }
         return result;
      }
      
      public function isAOETarget(mapResource:MapResource) : Boolean
      {
         if(!this.m_targetToSourceMapping)
         {
            this.buildTargetToSourceMapping();
         }
         var result:Boolean = false;
         if(Boolean(mapResource.getItem()) && Boolean(this.m_targetToSourceMapping[mapResource.getItem().code]))
         {
            result = true;
         }
         else if(Boolean(mapResource.getItem()) && (mapResource.getItem().type == "seed" || mapResource.getItem().type == "plot"))
         {
            result = true;
         }
         return result;
      }
      
      public function getCommonAOETargets(aoeResource1:MapResource, aoeResource2:MapResource) : Array
      {
         var aoeTargets1:Array = null;
         var aoeTargets2:Array = null;
         var itemCode:String = null;
         var result:Array = new Array();
         if(aoeResource1.hasAreasOfEffect() && aoeResource2.hasAreasOfEffect())
         {
            aoeTargets1 = aoeResource1.getItem().aoeConfig.getTargetItemCodes();
            aoeTargets2 = aoeResource2.getItem().aoeConfig.getTargetItemCodes();
            for each(itemCode in aoeTargets1)
            {
               if(aoeTargets2.indexOf(itemCode) >= 0)
               {
                  result.push(itemCode);
               }
            }
         }
         return result;
      }
      
      public function computeBonusesForResource(resource:MapResource, checkAllowBonus:Boolean = true) : AOEBonusData
      {
         var result:AOEBonusData = null;
         var aoeResourceIds:Array = this.getAoeResourceIdsAffecting(resource);
         return this.computeBonusesForAoeResourceIds(aoeResourceIds,resource,checkAllowBonus);
      }
      
      public function hasAOELicense(target:MapResource) : Boolean
      {
         var result:Boolean = true;
         var item:FarmItem = target.getItem();
         if(Boolean(item) && Boolean(item.aoeLicenseKey) && item.aoeLicenseKey != "")
         {
            result = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME_AOE_LICENSE,item.aoeLicenseKey) as Boolean;
         }
         return result;
      }
      
      public function setAOELicense(target:MapResource) : void
      {
         var item:FarmItem = target.getItem();
         if(Boolean(item) && Boolean(item.aoeLicenseKey) && item.aoeLicenseKey != "")
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME_AOE_LICENSE,item.aoeLicenseKey,true);
         }
      }
      
      public function computeBonusesForAoeResourceIds(aoeResourceIds:Array, target:MapResource, performAntiStuffingCheck:Boolean = true) : AOEBonusData
      {
         var bonusMultipliers:Array = null;
         var bonusCumulative:Array = null;
         var bonusValue:Number = NaN;
         var worldObj:MapResource = null;
         var bonusType:String = null;
         var locKey:String = null;
         var i:int = 0;
         var extraIncrement:int = 0;
         var worldType:String = null;
         var buffBonuses:Dictionary = null;
         var aoeBuffsManager:AOEBuffsManager = null;
         var activeBuffCode:String = null;
         var item:FarmItem = null;
         var type:String = null;
         var harvestYieldType:String = null;
         var harvestYieldTypes:Array = null;
         var multiplierResults:Object = this.getDefaultBonusMultiplierObject();
         var cumulativeResults:Object = this.getDefaultBonusCumulativeObject();
         var numSources:int = 0;
         var possibleStates:Array = [];
         if(this.hasAOELicense(target))
         {
            if(aoeResourceIds != null)
            {
               for(i = 0; i < aoeResourceIds.length; i++)
               {
                  extraIncrement = 0;
                  worldObj = Global.world.getObjectById(aoeResourceIds[i]) as MapResource;
                  if(Boolean(worldObj) && Boolean(this.hasAOELicense(worldObj)) && (!performAntiStuffingCheck || this.isBonusAllowed(target,worldObj) || this.isAOETile(target)))
                  {
                     if(!bonusType)
                     {
                        bonusType = this.getBonusToolTipType(worldObj);
                     }
                     worldType = Global.worldManager.currentWorldType;
                     if(worldType == WorldsConstants.WORLD_ID_JAPAN)
                     {
                        if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isChampionFromFO())
                        {
                           extraIncrement = 1;
                        }
                     }
                     aoeBuffsManager = AOEBuffsManager.getInstance();
                     activeBuffCode = aoeBuffsManager.getActiveBuffForSourceID(worldObj.getResourceItemCode());
                     if(activeBuffCode)
                     {
                        buffBonuses = aoeBuffsManager.getBonusesForBuff(activeBuffCode);
                     }
                     else
                     {
                        buffBonuses = null;
                     }
                     item = worldObj.getItem();
                     if(item != null)
                     {
                        numSources++;
                        bonusMultipliers = item.aoeConfig.bonusMultipliers;
                        bonusCumulative = item.aoeConfig.bonusCumulative;
                        if(item.aoeConfig.stateChange)
                        {
                           possibleStates.push(item.aoeConfig.stateChange);
                        }
                        locKey = item.aoeConfig.locKey;
                        if(bonusMultipliers != null)
                        {
                           for(type in bonusMultipliers)
                           {
                              bonusValue = Number(bonusMultipliers[type]);
                              bonusValue += extraIncrement;
                              if(type == HARVEST_YIELD_BONUS_KEY && target is HarvestableResource)
                              {
                                 harvestYieldTypes = (target as HarvestableResource).getHarvestYieldTypes();
                                 for each(harvestYieldType in harvestYieldTypes)
                                 {
                                    if(!multiplierResults[harvestYieldType])
                                    {
                                       multiplierResults[harvestYieldType] = 1;
                                    }
                                    multiplierResults[harvestYieldType] += bonusValue;
                                 }
                              }
                              if(multiplierResults[type])
                              {
                                 multiplierResults[type] += bonusValue;
                              }
                              else
                              {
                                 multiplierResults[type] = bonusValue;
                              }
                              if(Boolean(buffBonuses) && Boolean(buffBonuses[AOEManager.BONUS_TYPE_MULT]) && Boolean(buffBonuses[AOEManager.BONUS_TYPE_MULT][type]))
                              {
                                 if(multiplierResults[type])
                                 {
                                    multiplierResults[type] *= buffBonuses[AOEManager.BONUS_TYPE_MULT][type];
                                 }
                                 else
                                 {
                                    multiplierResults[type] = buffBonuses[AOEManager.BONUS_TYPE_MULT][type];
                                 }
                              }
                           }
                        }
                        if(bonusCumulative != null)
                        {
                           for(type in bonusCumulative)
                           {
                              bonusValue = Number(bonusCumulative[type]);
                              bonusValue += extraIncrement;
                              if(type == HARVEST_YIELD_BONUS_KEY && target is HarvestableResource)
                              {
                                 harvestYieldTypes = (target as HarvestableResource).getHarvestYieldTypes();
                                 for each(harvestYieldType in harvestYieldTypes)
                                 {
                                    if(!cumulativeResults[harvestYieldType])
                                    {
                                       cumulativeResults[harvestYieldType] = 1;
                                    }
                                    cumulativeResults[harvestYieldType] += bonusValue;
                                 }
                              }
                              if(cumulativeResults[type])
                              {
                                 cumulativeResults[type] += bonusValue;
                              }
                              else
                              {
                                 cumulativeResults[type] = bonusValue;
                              }
                              if(Boolean(buffBonuses) && Boolean(buffBonuses[AOEManager.BONUS_TYPE_ADD]) && Boolean(buffBonuses[AOEManager.BONUS_TYPE_ADD][type]))
                              {
                                 if(cumulativeResults[type])
                                 {
                                    cumulativeResults[type] *= buffBonuses[AOEManager.BONUS_TYPE_ADD][type];
                                 }
                                 else
                                 {
                                    cumulativeResults[type] = buffBonuses[AOEManager.BONUS_TYPE_ADD][type];
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         var returnValue:AOEBonusData = new AOEBonusData(multiplierResults,cumulativeResults,numSources,bonusType,locKey);
         returnValue.possibleStates = possibleStates;
         return returnValue;
      }
      
      public function getFreeAreaIdsForAOEResourceClass(className:String) : Array
      {
         var len:int = 0;
         var aoeWorldObject:AOEWorldObject = null;
         var aoeResource:MapResource = null;
         var containedResource:Vector.<WorldObject> = null;
         var isEmpty:Boolean = false;
         var j:int = 0;
         var result:Array = new Array();
         if(className != null && className != "")
         {
            len = int(m_aoeObjectsCache.length);
            for each(aoeWorldObject in m_aoeObjectsCache)
            {
               if(aoeWorldObject != null)
               {
                  aoeResource = this.getAreaObjectSource(aoeWorldObject) as MapResource;
                  if(Boolean(aoeResource != null) && Boolean(aoeResource.getItem()) && aoeResource.getItem().className == className)
                  {
                     containedResource = Global.world.getContainedObjects(aoeWorldObject);
                     isEmpty = true;
                     for(j = 0; j < containedResource.length; j++)
                     {
                        if(containedResource[j] is MapResource && aoeResource.getItem().aoeConfig.targets(containedResource[j] as MapResource))
                        {
                           isEmpty = false;
                           break;
                        }
                     }
                     if(isEmpty)
                     {
                        result.push(aoeWorldObject.getId());
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function aoeResourceClassHasFreeAreas(className:String) : Boolean
      {
         var result:Boolean = false;
         var resourceIds:Array = null;
         if(Boolean(className) && className != "")
         {
            resourceIds = this.getFreeAreaIdsForAOEResourceClass(className);
            result = resourceIds.length > 0;
         }
         return result;
      }
      
      public function hasOverlappingAreas(aoeResource:MapResource) : Boolean
      {
         return this.getIntersectingAOESources(aoeResource,1).length > 0;
      }
      
      public function getIntersectingAOESources(aoeResource:MapResource, max:int = 0) : Vector.<AOEIntersection>
      {
         var aoeWorldObjects:Vector.<AOEWorldObject> = null;
         var intersections:Vector.<WorldObject> = null;
         var intersectingAoeWorldObj:AOEWorldObject = null;
         var intersectingResource:MapResource = null;
         var intersectionRect:Rectangle = null;
         var intersectionArea:Number = NaN;
         var commonAoeTargets:Array = null;
         var smallestCommonAoeArea:Number = NaN;
         var aoeTargetItem:FarmItem = null;
         var aoeTargetItemArea:Number = NaN;
         var aoeWorldObj:AOEWorldObject = null;
         var intersectingWorldObj:WorldObject = null;
         var targetItemCode:String = null;
         var result:Vector.<AOEIntersection> = new Vector.<AOEIntersection>();
         if(aoeResource.hasAreasOfEffect())
         {
            aoeWorldObjects = aoeResource.getAOEWorldObjects();
            loop0:
            for each(aoeWorldObj in aoeWorldObjects)
            {
               intersections = Global.world.getIntersectingObjects(aoeWorldObj);
               for each(intersectingWorldObj in intersections)
               {
                  intersectingAoeWorldObj = intersectingWorldObj as AOEWorldObject;
                  if(intersectingAoeWorldObj != null && !aoeWorldObj.equals(intersectingAoeWorldObj))
                  {
                     intersectingResource = this.getAreaObjectSource(intersectingAoeWorldObj) as MapResource;
                     if(intersectingResource != null && !intersectingResource.equals(aoeResource))
                     {
                        commonAoeTargets = this.getCommonAOETargets(aoeResource,intersectingResource);
                        if(commonAoeTargets != null && commonAoeTargets.length > 0)
                        {
                           smallestCommonAoeArea = 0;
                           for each(targetItemCode in commonAoeTargets)
                           {
                              aoeTargetItem = Global.farmGameSettingsManager.getFarmItemByCode(targetItemCode);
                              if(aoeTargetItem != null)
                              {
                                 aoeTargetItemArea = aoeTargetItem.sizeX * aoeTargetItem.sizeY;
                                 if(smallestCommonAoeArea == 0 || aoeTargetItemArea < smallestCommonAoeArea)
                                 {
                                    smallestCommonAoeArea = aoeTargetItemArea;
                                 }
                              }
                           }
                           intersectionRect = RectangleUtil.intersection(aoeWorldObj.getTileRect(),intersectingWorldObj.getTileRect());
                           intersectionArea = RectangleUtil.area(intersectionRect.left,intersectionRect.top,intersectionRect.right,intersectionRect.bottom);
                           if(intersectionArea >= smallestCommonAoeArea)
                           {
                              result.push(new AOEIntersection(aoeResource,intersectingResource,aoeWorldObj,intersectingAoeWorldObj,intersectionRect,commonAoeTargets));
                              if(max > 0 && result.length >= max)
                              {
                                 break loop0;
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         return result;
      }
      
      private function buildTargetToSourceMapping() : void
      {
         var aoeConfig:AOEConfig = null;
         var targetItemCodes:Array = null;
         var itemCode:String = null;
         this.m_targetToSourceMapping = new Dictionary();
         for each(aoeConfig in this.m_allConfigs)
         {
            targetItemCodes = aoeConfig.getTargetItemCodes();
            for each(itemCode in targetItemCodes)
            {
               if(!this.m_targetToSourceMapping[itemCode])
               {
                  this.m_targetToSourceMapping[itemCode] = new Array();
               }
               this.m_targetToSourceMapping[itemCode].push(aoeConfig.itemCode);
            }
         }
      }
      
      public function getDefaultBonusMultiplierObject() : Object
      {
         return {
            "coin":1,
            "xp":1,
            "mastery":1,
            "harvestYield":1
         };
      }
      
      public function getDefaultBonusCumulativeObject() : Object
      {
         return {
            "xp":0,
            "mastery":0,
            "harvestYield":1
         };
      }
      
      private function isBonusAllowed(target:MapResource, source:MapResource) : Boolean
      {
         var targetPlaceTime:Number = NaN;
         var sourcePlaceTime:Number = NaN;
         var plantTime:Number = NaN;
         var growTime:Number = NaN;
         var harvestReadyTime:Number = NaN;
         var result:Boolean = false;
         var harvestableTarget:HarvestableResource = target as HarvestableResource;
         if(harvestableTarget)
         {
            targetPlaceTime = harvestableTarget.aoePlaceTime;
            sourcePlaceTime = source.aoePlaceTime;
            plantTime = Math.floor(harvestableTarget.getAOEPlantTime() / FarmGameUtil.NUM_MSECS_IN_SECOND);
            growTime = harvestableTarget.getGrowTime() / FarmGameUtil.NUM_MSECS_IN_SECOND;
            harvestReadyTime = plantTime + growTime;
            result = targetPlaceTime < harvestReadyTime && sourcePlaceTime < harvestReadyTime;
         }
         return result;
      }
      
      private function isAOETile(target:MapResource) : Boolean
      {
         var result:Boolean = false;
         var targetItemType:String = target.getItem().type;
         if(targetItemType == "seed" || targetItemType == "plot")
         {
            result = true;
         }
         return result;
      }
      
      public function getBonusToolTipType(source:MapResource) : String
      {
         var item:FarmItem = null;
         var buildingName:String = null;
         var xml:XML = null;
         var locKey:String = null;
         var bonusToolTipType:String = "";
         if(source)
         {
            item = source.getItem();
            if(item)
            {
               buildingName = "";
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  buildingName = item.getStringFromDataSource("buildingName");
               }
               else if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  if(item.hasPropertyInDataSource("buildingName"))
                  {
                     buildingName = item.getStringFromDataSource("buildingName");
                  }
               }
               else
               {
                  xml = item.xml;
                  if(Boolean(xml) && xml.hasOwnProperty("@buildingName"))
                  {
                     buildingName = xml.@buildingName;
                  }
               }
               if(buildingName)
               {
                  locKey = "AOEToolTipBonusType_" + buildingName;
                  if(ZLocUtils.hasString("Dialogs",locKey))
                  {
                     bonusToolTipType = ZLocUtils.t("Dialogs",locKey);
                  }
               }
            }
         }
         return bonusToolTipType;
      }
      
      public function getAOEObjectsByClass(className:Class = null) : Array
      {
         var mapResource:MapResource = null;
         var results:Array = new Array();
         var objects:Array = Global.world.getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            mapResource = objects[objIdx] as MapResource;
            if(mapResource != null && (className == null || mapResource is className))
            {
               if(mapResource.isAoeSource())
               {
                  results.push(mapResource);
               }
            }
            objIdx++;
         }
         return results;
      }
      
      public function doesAOESourceGiveStateChange(id:int) : Boolean
      {
         var item:FarmItem = null;
         var result:Boolean = false;
         var worldObj:MapResource = Global.world.getObjectById(id) as MapResource;
         if(worldObj)
         {
            item = worldObj.getItem();
            if(item != null)
            {
               if(Boolean(item.aoeConfig) && Boolean(item.aoeConfig.stateChange))
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function addAOETasksToQueue() : void
      {
         var objectList:Array = null;
         var affectedItem:MapResource = null;
         var affectedItemName:String = null;
         var affectedItemList:Array = null;
         var AOESources:Array = this.getAOEStateChangeSources();
         var AOESourceResource:MapResource = null;
         for each(AOESourceResource in AOESources)
         {
            objectList = AOESourceResource.getCurrentAoeTargets();
            affectedItem = null;
            for each(affectedItem in objectList)
            {
               affectedItemName = affectedItem.getItemName();
               affectedItemList = Global.world.getObjectsByName(affectedItemName);
               if(GlobalEngine.getFlashVar("TIMED_ACTION_MILLISECONDS_OPS") != null)
               {
                  Global.world.addTimedActionToQueue(new AOEStateChangeTimedAction(Number(GlobalEngine.getFlashVar("TIMED_ACTION_MILLISECONDS_OPS")),affectedItemList));
               }
            }
         }
      }
      
      public function setAOELicenseByResourceName(resourceName:String) : void
      {
         if(resourceName != "")
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME_AOE_LICENSE,resourceName,true);
         }
      }
   }
}

