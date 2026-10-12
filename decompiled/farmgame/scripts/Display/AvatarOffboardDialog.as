package Display
{
   import Classes.util.ZLocUtils;
   import flash.events.Event;
   
   public class AvatarOffboardDialog extends DataDrivenOkayPopup
   {
      
      private var m_closeCallback:Function;
      
      public function AvatarOffboardDialog(closeCallback:Function = null)
      {
         this.m_closeCallback = closeCallback;
         var params:Array = ["assets/dialogs/FV_Avatar_Elements/Avatar_Offboarding.png",ZLocUtils.t("Dialogs","AvatarOffboard_Body")];
         super("ClothesOffboard",params);
      }
      
      override protected function onAccept(event:Event) : void
      {
         super.onAccept(event);
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
   }
}

