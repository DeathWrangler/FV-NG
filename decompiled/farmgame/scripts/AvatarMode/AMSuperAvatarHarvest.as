package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.util.ZLocUtils;
   import GameMode.GMDefault;
   import flash.geom.Point;
   
   public class AMSuperAvatarHarvest extends AMSuperAvatarAction
   {
      
      public function AMSuperAvatarHarvest(avatar:FarmAvatar, plots:Array, centerPos:Point)
      {
         var totalActionTime:Number = Global.farmGameSettingsManager.getNumber("harvestTime");
         super(avatar,plots,centerPos,HarvestableResource.RESOURCE_ACTION_HARVEST,totalActionTime);
      }
      
      override protected function doAction() : int
      {
         return multiHarvest(HarvestableResource.ENERGY_SOURCE_SUPER_AVATAR,m_plots,m_avatar,AMMultiPlotAction.STATUS_ENERGY_SOURCE_SUPERAVATAR);
      }
      
      override protected function updateActionProgress(progress:Number) : void
      {
         m_avatar.setActionProgress(ZLocUtils.t("FarmGame","Harvesting"),progress);
      }
      
      override protected function onRunOutOfActions() : void
      {
         Global.world.addGameMode(new GMDefault(),true);
      }
   }
}

