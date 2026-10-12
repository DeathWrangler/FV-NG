package Classes
{
   import Classes.FeatureComponents.IHarvestComponent;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   
   public class MoneyTree2017Building extends FeatureBuilding
   {
      
      private var m_finalHarvest:Boolean = false;
      
      private var m_harvesting:Boolean = false;
      
      public function MoneyTree2017Building(itemName:String = null)
      {
         super(itemName);
         if(this.isHarvestable())
         {
            setState(FeatureBuilding.STATE_RIPE);
         }
      }
      
      override protected function determineState(delta:Number) : void
      {
         if(state == FeatureBuilding.STATE_RIPE || state == FeatureBuilding.STATE_BARE)
         {
            if(this.isHarvestable())
            {
               setState(FeatureBuilding.STATE_RIPE);
            }
            else
            {
               setState(FeatureBuilding.STATE_BARE);
            }
         }
         else
         {
            setState(state);
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var tooltip:String = "";
         if(this.m_finalHarvest == false && this.m_harvesting == false)
         {
            if(this.isHarvestable())
            {
               tooltip = ZLocUtils.t("FarmGame","AnimalBuilding_ready",{
                  "item":m_item.friendlyTitle,
                  "capacityStr":""
               });
            }
            else
            {
               tooltip = m_item.friendlyTitle + " ready in " + HUD.getformattedTimeLeft(this.getTimeToHarvest());
            }
            setToolTip(tooltip);
            updateToolTipPosition();
         }
      }
      
      override public function isHarvestable() : Boolean
      {
         var result:Boolean = false;
         var harvesterComponent:IHarvestComponent = harvester;
         var canHarvest:Boolean = harvesterComponent ? harvesterComponent.canHarvest() : false;
         if(this.getTimeToHarvest() <= 0 && canHarvest && this.m_finalHarvest == false && this.m_harvesting == false)
         {
            result = true;
         }
         return result;
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var key:String = null;
         var lastHArvestTime:Number = NaN;
         var postHarvestData:Object = null;
         this.m_harvesting = false;
         if(result.hasOwnProperty("postHarvestData") && Boolean(result["postHarvestData"].hasOwnProperty("harvestedTime")))
         {
            key = Global.worldManager.currentWorldType + "_" + getId() + "_hackPrevention";
            lastHArvestTime = result["postHarvestData"]["harvestedTime"] as Number;
            Global.player.setFeatureLastShown(key,lastHArvestTime,false);
            postHarvestData = result["postHarvestData"];
            if(postHarvestData.hasOwnProperty("expiredTextReplacements"))
            {
               this.m_finalHarvest = true;
            }
            setState(FeatureBuilding.STATE_BARE);
         }
         super.onHarvestComplete(result);
      }
      
      private function getTimeToHarvest() : int
      {
         var key:String = Global.worldManager.currentWorldType + "_" + getId() + "_hackPrevention";
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(86400 - timeSinceLastFeed);
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         var result:Boolean = super.harvest(energySource,energy,showNoEnergyMessage,updateBackend,neighborId);
         this.m_harvesting = true;
         return result;
      }
   }
}

