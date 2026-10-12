package GameMode.ModeComponents
{
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.AreasOfEffect.AOEConfig;
   import Classes.AreasOfEffect.AOEIntersection;
   import Classes.FarmGameObject;
   import Classes.HarvestableResource;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import GameMode.GMObjectMove;
   import GameMode.GameMode;
   import Managers.AOEManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.AOETooltip;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class AOESourceMoveComponent implements IGameModeComponent
   {
      
      private var m_mapResource:MapResource;
      
      private var m_newTargets:Array;
      
      private var m_allAoeSources:Array;
      
      private var m_sourceIntersections:Vector.<AOEIntersection>;
      
      private var m_allTargets:Array;
      
      private var m_bAoeSourcesHighlighted:Boolean = false;
      
      private var m_bTargetHighlighted:Boolean = false;
      
      public function AOESourceMoveComponent(selectedObject:MapResource)
      {
         super();
         this.m_mapResource = selectedObject;
      }
      
      public static function canApply(mode:GameMode, selectedObject:FarmGameObject) : Boolean
      {
         var mapResource:MapResource = null;
         var result:Boolean = false;
         if(mode is GMObjectMove && selectedObject != null && selectedObject is MapResource)
         {
            mapResource = selectedObject as MapResource;
            if(mapResource.isAoeSource())
            {
               result = true;
            }
         }
         return result;
      }
      
      public function onMouseMove(event:MouseEvent) : Boolean
      {
         this.m_mapResource.showAreaOfEffect(true);
         this.m_mapResource.hideAoeToolTips();
         var item:FarmItem = this.m_mapResource.getItem();
         var aoeConfig:AOEConfig = null;
         if(item)
         {
            aoeConfig = item.aoeConfig;
         }
         this.m_mapResource.showTargets(false,true,Boolean(aoeConfig) && aoeConfig.stateChange != null,false);
         this.m_newTargets = this.m_mapResource.getCurrentAoeTargets(true);
         var consolidateTargetBonuses:Boolean = Boolean(aoeConfig) && aoeConfig.consolidateBonusOnSourceMove;
         if(consolidateTargetBonuses)
         {
            this.m_mapResource.showAoeBonus(new AOEBonusData(aoeConfig.bonusMultipliers,aoeConfig.bonusCumulative,1,null,aoeConfig.locKey),true);
         }
         else
         {
            this.showOverlapAreaToolTips();
            this.m_mapResource.showTargets(true,false);
         }
         return true;
      }
      
      protected function showOverlapAreaToolTips() : void
      {
         var overlappingArea:AOEIntersection = null;
         var aoeManager:AOEManager = AOEManager.getInstance();
         var overlappingAreas:Vector.<AOEIntersection> = aoeManager.getIntersectingAOESources(this.m_mapResource);
         var bonusType:String = aoeManager.getBonusToolTipType(this.m_mapResource);
         for each(overlappingArea in overlappingAreas)
         {
            this.m_mapResource.showAoeToolTip(AOETooltip.MODE_SHOW_STACKED_BONUS_AVAILABLE,overlappingArea.rect,null,bonusType);
         }
      }
      
      public function enableMode() : void
      {
         if(this.m_mapResource.getId() == 0)
         {
         }
         var classString:String = getQualifiedClassName(this.m_mapResource);
         var aoeClass:Class = getDefinitionByName(classString) as Class;
         this.m_allAoeSources = AOEManager.getInstance().getAOEObjectsByClass(aoeClass);
         this.highlightAOESources(true);
         this.m_allTargets = AOEManager.getInstance().getPotentialTargets(this.m_mapResource);
         this.highlightTargets(true);
      }
      
      public function disableMode() : void
      {
         this.m_mapResource.showAreaOfEffect(false);
         this.m_mapResource.showTargets(false);
         this.m_mapResource.hideAoeToolTips();
         this.highlightAOESources(false);
         this.highlightTargets(false);
      }
      
      public function handleObjectDrop(event:MouseEvent) : void
      {
         var target:MapResource = null;
         var overlappingAreas:Boolean = false;
         var item:FarmItem = null;
         var bonuses:AOEBonusData = null;
         var featureName:String = null;
         var buildingName:String = null;
         var itemXml:XML = null;
         this.m_mapResource.refreshAOEPlaceTime();
         for each(target in this.m_newTargets)
         {
            if(target is HarvestableResource)
            {
               (target as HarvestableResource).conditionallyShowAntiStuffingAoeMessage();
            }
            bonuses = AOEManager.getInstance().computeBonusesForResource(target,false);
            target.applyAoeAffects(bonuses,true);
         }
         overlappingAreas = AOEManager.getInstance().hasOverlappingAreas(this.m_mapResource);
         item = this.m_mapResource.getItem();
         if(item)
         {
            featureName = item.name;
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
               itemXml = item.xml;
               if(Boolean(itemXml) && Boolean(itemXml.hasOwnProperty("@buildingName")) && Boolean(itemXml.@buildingName.length()))
               {
                  buildingName = itemXml.@buildingName;
               }
            }
            if(buildingName)
            {
               featureName = buildingName;
            }
         }
         var phylum:String = overlappingAreas ? "area_overlaps_another" : "area_doesnt_overlap";
         FarmStatsManager.count(AOEManager.STATS_COUNTER_NAME,featureName,"placed_and_finished",phylum);
      }
      
      private function highlightAOESources(highlight:Boolean) : void
      {
         var aoeSource:MapResource = null;
         if(this.m_bAoeSourcesHighlighted != highlight)
         {
            this.m_bAoeSourcesHighlighted = highlight;
            for each(aoeSource in this.m_allAoeSources)
            {
               if(aoeSource != this.m_mapResource)
               {
                  aoeSource.showAreaOfEffect(highlight);
               }
            }
         }
      }
      
      private function highlightTargets(highlight:Boolean) : void
      {
         var targetSource:MapResource = null;
         if(this.m_bTargetHighlighted != highlight)
         {
            this.m_bTargetHighlighted = highlight;
            for each(targetSource in this.m_allTargets)
            {
               targetSource.showHighlight(highlight,MapResource.AOE_HIGHLIGHT_COLOR);
            }
         }
      }
   }
}

