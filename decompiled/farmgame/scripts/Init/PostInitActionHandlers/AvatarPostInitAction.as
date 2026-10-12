package Init.PostInitActionHandlers
{
   public class AvatarPostInitAction extends AbstractPostInitAction
   {
      
      public function AvatarPostInitAction(callback:Function = null)
      {
         super(callback);
      }
      
      override public function execute() : void
      {
         if(GlobalEngine.getFlashVar("avatarClothes") == "1" && !Global.player.getSeenFlag("reactivation_session"))
         {
            Global.world.displayAvatarCustomizationScreen(false);
            this.addHudIcon();
         }
         m_isFinished = true;
      }
      
      private function addHudIcon() : void
      {
         if(!Global.player.getSeenFlag("clothesHud"))
         {
            Global.hud.iconQueue.addIcon("AvatarClothes");
            Global.player.setSeenFlag("clothesHud");
         }
      }
   }
}

