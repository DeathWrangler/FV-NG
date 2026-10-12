package Display
{
   import Classes.util.ZLocUtils;
   import flash.events.Event;
   
   public class AvatarOnboardDialog extends DataDrivenOkayPopup
   {
      
      public function AvatarOnboardDialog()
      {
         var params:Array = ["assets/dialogs/FV_Avatar_Elements/Avatar_Onboard.png",ZLocUtils.t("Dialogs","AvatarOnboard_Title"),ZLocUtils.t("Dialogs","AvatarOnboard_Body")];
         super("ClothesOnboard",params);
      }
      
      override protected function onAccept(event:Event) : void
      {
         super.onAccept(event);
         Global.world.displayAvatarCustomizationScreen(false);
      }
      
      override public function get shouldFreeze() : Boolean
      {
         return false;
      }
   }
}

