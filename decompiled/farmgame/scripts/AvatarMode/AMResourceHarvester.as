package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.FarmGameObject;
   import Classes.HarvestableResource;
   import Classes.ResourceHarvester;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Managers.AvatarRetentionExperimentUtil;
   import Managers.FarmStatsManager;
   import Transactions.TResourceEquipmentAction;
   import flash.geom.Point;
   
   public class AMResourceHarvester extends AMMultiResourceEquipmentAction
   {
      
      public function AMResourceHarvester(avatar:FarmAvatar, resources:Array, harvester:ResourceHarvester, centerPos:Point)
      {
         super(avatar,resources,harvester,centerPos);
      }
      
      override public function enter() : void
      {
         super.enter();
         if(m_actionStarted)
         {
            SoundManager.playSound("tractorPlow");
         }
      }
      
      override public function reenter() : void
      {
         super.reenter();
         if(m_actionStarted)
         {
            SoundManager.playSound("tractorPlow");
         }
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         var statusKeySuffix:String = null;
         var numHarvested:int = 0;
         if(Boolean(m_equipment) && m_equipment.isAttached())
         {
            if(m_actionStarted)
            {
               m_actionTime += delta;
               progress = m_actionTime / Global.farmGameSettingsManager.getNumber("harvestTime");
               if(progress > 1 || AvatarRetentionExperimentUtil.inNoWaitExperiment())
               {
                  statusKeySuffix = Global.player.hasNoFuelDayActive() ? AMMultiResourceAction.STATUS_ENERGY_SOURCE_FREE_FUEL : AMMultiResourceAction.STATUS_ENERGY_SOURCE_FUEL;
                  numHarvested = this.performAction(HarvestableResource.ENERGY_SOURCE_FUEL,m_resources,m_actionEquipment,statusKeySuffix);
                  m_avatar.getStateMachine().removeState(this);
                  if(!Global.player.hasEnergy(m_actionEquipment.getEnergyCost()))
                  {
                     UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_FUEL,"impulseBuyVehicle");
                     m_avatar.getStateMachine().removeMachineStates();
                     notifyOutOfFuel();
                  }
               }
               else
               {
                  m_actionEquipment.setActionProgress(ZLocUtils.t("FarmGame","Harvesting"),progress);
               }
            }
         }
         else
         {
            m_avatar.displayStatus(ZLocUtils.t("FarmGame","NeedHarvester"));
            m_avatar.getStateMachine().removeState(this);
         }
      }
      
      override protected function performAction(energySource:int, resources:Array, displayStatusTarget:FarmGameObject, statusKeySuffix:String, sendTransaction:Boolean = true) : int
      {
         var resource:HarvestableResource = null;
         var limitGroupNames:String = null;
         var numHarvested:int = 0;
         var energyPerResource:int = m_actionEquipment.getEnergyCost();
         var totalEnergy:int = 0;
         var resourceBundle:Array = [];
         var numResources:int = int(resources.length);
         for(var i:int = 0; i < numResources; i++)
         {
            resource = resources[i] as HarvestableResource;
            if(resource)
            {
               if(Global.player.energy >= energyPerResource && resource.harvest(energySource,energyPerResource,false,false))
               {
                  if(!Global.player.hasUnlimitedFuelOfferActivated())
                  {
                     Global.player.energy -= energyPerResource;
                  }
                  totalEnergy += energyPerResource;
                  resourceBundle.push({
                     "id":resource.getId(),
                     "position":resource.getPosition(),
                     "aoeSources":resource.getAOESourceIds()
                  });
                  resource.doHarvestDropOff(m_avatar,false);
                  numHarvested++;
               }
            }
         }
         if(numHarvested > 0 && sendTransaction)
         {
            limitGroupNames = "";
            if(m_equipment)
            {
               limitGroupNames = m_equipment.getLimitGroupNamesForStatHit();
            }
            FarmStatsManager.count("farm_world_actions","harvest","MapResource","harvest_" + limitGroupNames + "vehicle",numHarvested.toString());
            TransactionManager.addTransaction(new TResourceEquipmentAction(TResourceEquipmentAction.ACTION_HARVEST,m_equipment,resourceBundle));
            m_equipment.onActionTransactionAdded();
            notifyFuelUse(totalEnergy);
         }
         return numHarvested;
      }
   }
}

