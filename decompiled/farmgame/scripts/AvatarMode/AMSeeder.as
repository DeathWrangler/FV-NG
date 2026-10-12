package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.Seeder;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Managers.AvatarRetentionExperimentUtil;
   import Managers.CrossPromoManager;
   import flash.geom.Point;
   
   public class AMSeeder extends AMEquipment
   {
      
      protected var m_seed:FarmItem;
      
      public function AMSeeder(avatar:FarmAvatar, plots:Array, seeder:Seeder, centerPos:Point, seed:FarmItem)
      {
         super(avatar,plots,seeder,centerPos);
         this.m_seed = seed;
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
         var numSeeded:int = 0;
         var crossPromoManager:CrossPromoManager = null;
         if(m_equipment != null && m_equipment.isAttached() == true)
         {
            if(m_actionStarted)
            {
               m_actionTime += delta;
               progress = m_actionTime / Global.farmGameSettingsManager.getNumber("plantTime");
               if(progress > 1 || AvatarRetentionExperimentUtil.inNoWaitExperiment())
               {
                  statusKeySuffix = Global.player.hasNoFuelDayActive() ? AMMultiPlotAction.STATUS_ENERGY_SOURCE_FREE_FUEL : AMMultiPlotAction.STATUS_ENERGY_SOURCE_FUEL;
                  numSeeded = multiPlant(HarvestableResource.ENERGY_SOURCE_FUEL,this.m_seed,m_plots,m_actionEquipment,statusKeySuffix);
                  if(!Global.player.hasEnergy())
                  {
                     crossPromoManager = CrossPromoManager.getInstance();
                     crossPromoManager.notifyBeginOutBoundPromo("use_x_fuel");
                  }
                  m_avatar.getStateMachine().removeState(this);
                  if(numSeeded == 0 && !Global.player.hasEnergy())
                  {
                     UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_FUEL,"impulseBuyVehicle");
                     m_avatar.getStateMachine().removeMachineStates();
                  }
               }
               else
               {
                  m_actionEquipment.setActionProgress(ZLocUtils.t("FarmGame","Planting"),progress);
               }
            }
         }
         else
         {
            m_avatar.displayStatus(ZLocUtils.t("FarmGame","NeedSeeder"));
            m_avatar.getStateMachine().removeState(this);
         }
      }
      
      override public function added() : void
      {
         super.added();
         Global.hud.updateSeedingQueue(this.getNumActions(),this.m_seed.name);
      }
      
      override public function removed() : void
      {
         super.removed();
         Global.hud.updateSeedingQueue(-1 * this.getNumActions(),this.m_seed.name);
      }
   }
}

