package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FVAnniversaryBirthdayGiftPopup extends FarmWindow
   {
      
      public function FVAnniversaryBirthdayGiftPopup()
      {
         super("assets/dialogs/Farmville10thBirthday/Free_surprise_gift/popup.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         var popupMC:MovieClip = null;
         var acceptBT:FarmAnimatedTextButton = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("popup_mc"))
         {
            popupMC = m_window["popup_mc"] as MovieClip;
            if(popupMC.hasOwnProperty("accept_bt"))
            {
               acceptBT = addWidget(new FarmAnimatedTextButton(popupMC.accept_bt,"Okay",this.onAccept)) as FarmAnimatedTextButton;
               acceptBT.visible = true;
            }
            popupMC.visible = true;
         }
      }
      
      private function onAccept(event:Event) : void
      {
         close();
      }
   }
}

