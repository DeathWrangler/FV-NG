package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.util.ZLocUtils;
   import GameMode.GMMultiPlow;
   import flash.geom.Point;
   
   public class AMSuperAvatarPlow extends AMSuperAvatarAction
   {
      
      public function AMSuperAvatarPlow(avatar:FarmAvatar, plots:Array, centerPos:Point)
      {
         var totalActionTime:Number = Global.farmGameSettingsManager.getNumber("plowTime");
         super(avatar,plots,centerPos,HarvestableResource.RESOURCE_ACTION_CLEAR,totalActionTime);
      }
      
      override protected function doAction() : int
      {
         return multiPlow(HarvestableResource.ENERGY_SOURCE_SUPER_AVATAR,m_plots,m_avatar,AMMultiPlotAction.STATUS_ENERGY_SOURCE_SUPERAVATAR);
      }
      
      override protected function updateActionProgress(progress:Number) : void
      {
         m_avatar.setActionProgress(ZLocUtils.t("FarmGame","Plowing"),progress);
      }
      
      override protected function onRunOutOfActions() : void
      {
         Global.world.addGameMode(new GMMultiPlow(),true);
      }
   }
}

