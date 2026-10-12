package GameMode
{
   import AvatarMode.AMSuperAvatarAction;
   import AvatarMode.AMSuperAvatarPlow;
   import Classes.Avatar.FarmAvatar;
   import Classes.EmbeddedArt;
   import Engine.Helpers.IntVector2;
   import flash.geom.Point;
   
   public class GMSuperAvatarPlow extends GMMultiPlotPlow
   {
      
      public function GMSuperAvatarPlow()
      {
         super();
         m_actionSize = new IntVector2(AMSuperAvatarAction.SUPER_AVATAR_ACTION_SIZE_X,AMSuperAvatarAction.SUPER_AVATAR_ACTION_SIZE_Y);
         m_cursorImage = EmbeddedArt.cursor_super_avatar_plow;
      }
      
      override protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
         avatar.getStateMachine().addState(new AMSuperAvatarPlow(avatar,plots,centerPos),true);
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         Global.selectedAvatar.centerOn();
         Global.selectedAvatar.startSuperOverlay();
      }
      
      override public function disableMode() : void
      {
         Global.selectedAvatar.stopOverlay();
         super.disableMode();
      }
   }
}

