package GameMode.ModeComponents
{
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.FarmGameObject;
   import Classes.HarvestableResource;
   import Classes.MapResource;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import GameMode.GMObjectMove;
   import GameMode.GameMode;
   import Managers.AOEManager;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class AOETargetMoveComponent implements IGameModeComponent
   {
      
      private var m_aoeSources:Array;
      
      private var m_mapResource:MapResource;
      
      private var m_hasBonus:Boolean;
      
      public function AOETargetMoveComponent(selectedObject:MapResource)
      {
         super();
         this.m_mapResource = selectedObject;
      }
      
      public static function canApply(mode:GameMode, selectedObject:FarmGameObject) : Boolean
      {
         var mapResource:MapResource = null;
         var result:Boolean = false;
         if(Boolean(mode is GMObjectMove) && Boolean(selectedObject) && selectedObject is MapResource)
         {
            mapResource = selectedObject as MapResource;
            if(mapResource.isAoeTarget())
            {
               result = true;
            }
         }
         return result;
      }
      
      public function onMouseMove(event:MouseEvent) : Boolean
      {
         var bonuses:AOEBonusData = AOEManager.getInstance().computeBonusesForResource(this.m_mapResource,false);
         if(bonuses.numSources > 0)
         {
            this.m_hasBonus = true;
            this.m_mapResource.showAoeBonus(bonuses,true);
            this.m_mapResource.applyAoeAffects(bonuses);
         }
         else
         {
            this.m_hasBonus = false;
            this.m_mapResource.hideAoeBonus();
            this.m_mapResource.unapplyAoeAffects();
         }
         return true;
      }
      
      public function enableMode() : void
      {
         if(this.m_mapResource)
         {
            this.m_aoeSources = AOEManager.getInstance().getPotentialAoeResources(this.m_mapResource);
            this.highlightAOESources(true);
         }
      }
      
      public function disableMode() : void
      {
         this.m_mapResource.hideAoeBonus();
         this.highlightAOESources(false);
      }
      
      public function handleObjectDrop(event:MouseEvent) : void
      {
         var harvestableResource:HarvestableResource = null;
         this.m_mapResource.refreshAOEPlaceTime();
         if(this.m_hasBonus)
         {
            harvestableResource = this.m_mapResource as HarvestableResource;
            if(harvestableResource !== null)
            {
               harvestableResource.conditionallyShowAntiStuffingAoeMessage();
            }
         }
         var aoeResourceIds:Array = AOEManager.getInstance().getAoeResourceIdsAffecting(this.m_mapResource);
         var percentage:Number = 0;
         if(this.m_mapResource is SimpleHarvestableResource)
         {
            percentage = (this.m_mapResource as SimpleHarvestableResource).getGrowPercentage();
         }
         var item:FarmItem = this.m_mapResource.getItem();
         var featureName:String = "";
         if(item)
         {
            featureName = item.name;
         }
         FarmStatsManager.count(AOEManager.STATS_COUNTER_NAME,"moved_into_area_" + featureName,percentage.toString(),aoeResourceIds.length.toString());
      }
      
      private function highlightAOESources(highlight:Boolean) : void
      {
         var aoeSource:MapResource = null;
         if(highlight)
         {
            for each(aoeSource in this.m_aoeSources)
            {
               aoeSource.showHighlight(true);
               aoeSource.showAreaOfEffect(true);
            }
         }
         else
         {
            for each(aoeSource in this.m_aoeSources)
            {
               aoeSource.showHighlight(false);
               aoeSource.showAreaOfEffect(false);
            }
         }
      }
   }
}

