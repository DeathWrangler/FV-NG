package Display
{
   public class SuperAvatarActionIcon extends SuperAvatarIcon
   {
      
      private const ASSET_URL:String = "assets/hud/Action_Menu/FV_Main_SuperAv_Icon.swf";
      
      public function SuperAvatarActionIcon(resourceAction:int)
      {
         super(this.ASSET_URL);
         showIcon(resourceAction);
      }
   }
}

