package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import GameMode.GMMarketPlant;
   import flash.geom.Point;
   
   public class AMSuperAvatarPlant extends AMSuperAvatarAction
   {
      
      protected var m_seed:FarmItem;
      
      public function AMSuperAvatarPlant(avatar:FarmAvatar, plots:Array, centerPos:Point, seed:FarmItem)
      {
         var totalActionTime:Number = Global.farmGameSettingsManager.getNumber("plantTime");
         super(avatar,plots,centerPos,HarvestableResource.RESOURCE_ACTION_PLANT,totalActionTime);
         this.m_seed = seed;
      }
      
      override protected function doAction() : int
      {
         return multiPlant(HarvestableResource.ENERGY_SOURCE_SUPER_AVATAR,this.m_seed,m_plots,m_avatar,AMMultiPlotAction.STATUS_ENERGY_SOURCE_SUPERAVATAR);
      }
      
      override protected function updateActionProgress(progress:Number) : void
      {
         m_avatar.setActionProgress(ZLocUtils.t("FarmGame","Planting"),progress);
      }
      
      override public function added() : void
      {
         super.added();
         Global.hud.updateSeedingQueue(1,this.m_seed.name);
      }
      
      override public function removed() : void
      {
         super.removed();
         Global.hud.updateSeedingQueue(-1,this.m_seed.name);
      }
      
      override protected function onRunOutOfActions() : void
      {
         Global.world.addGameMode(new GMMarketPlant(this.m_seed.name),true);
      }
   }
}

