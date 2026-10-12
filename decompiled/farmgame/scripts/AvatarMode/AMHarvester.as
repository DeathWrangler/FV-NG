package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.Harvester;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Managers.AvatarRetentionExperimentUtil;
   import Managers.CrossPromoManager;
   import flash.geom.Point;
   
   public class AMHarvester extends AMEquipment
   {
      
      public function AMHarvester(avatar:FarmAvatar, plots:Array, harvester:Harvester, centerPos:Point)
      {
         super(avatar,plots,harvester,centerPos);
      }
      
      override public function enter() : void
      {
         super.enter();
         if(this.m_actionStarted)
         {
            SoundManager.playSound("tractorPlow");
         }
      }
      
      override public function reenter() : void
      {
         super.reenter();
         if(this.m_actionStarted)
         {
            SoundManager.playSound("tractorPlow");
         }
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         var statusKeySuffix:String = null;
         var numHarvested:int = 0;
         var crossPromoManager:CrossPromoManager = null;
         if(m_equipment != null && m_equipment.isAttached() == true)
         {
            if(m_actionStarted)
            {
               m_actionTime += delta;
               progress = m_actionTime / Global.farmGameSettingsManager.getNumber("harvestTime");
               if(progress > 1 || AvatarRetentionExperimentUtil.inNoWaitExperiment())
               {
                  statusKeySuffix = Global.player.hasNoFuelDayActive() ? AMMultiPlotAction.STATUS_ENERGY_SOURCE_FREE_FUEL : AMMultiPlotAction.STATUS_ENERGY_SOURCE_FUEL;
                  numHarvested = multiHarvest(HarvestableResource.ENERGY_SOURCE_FUEL,m_plots,m_actionEquipment,statusKeySuffix);
                  m_avatar.getStateMachine().removeState(this);
                  if(0 == numHarvested && !Global.player.hasEnergy())
                  {
                     UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_FUEL,"impulseBuyVehicle");
                     m_avatar.getStateMachine().removeMachineStates();
                  }
                  if(!Global.player.hasEnergy())
                  {
                     crossPromoManager = CrossPromoManager.getInstance();
                     crossPromoManager.notifyBeginOutBoundPromo("use_x_fuel");
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
   }
}

