package Display
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class HangingGardensFTUECompletionDialog extends FarmWindow
   {
      
      private static const WINDOW_ASSET:String = "assets/dialogs/xhg/FV_xhg_FTUEComplete.swf";
      
      private static const DIALOG_KEY:String = "HangingGardensPostFTUE";
      
      public function HangingGardensFTUECompletionDialog()
      {
         super(WINDOW_ASSET);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_window)
         {
            if(m_window.hasOwnProperty("copy_0_tf"))
            {
               addWidget(new ZwTextField(m_window.copy_0_tf,ZLocUtils.t_pk("Dialogs",DIALOG_KEY)));
            }
            if(m_window.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedButton(m_window.accept_bt,this.onAccept));
            }
         }
      }
      
      private function onAccept(event:Event) : void
      {
         super.close();
      }
   }
}

