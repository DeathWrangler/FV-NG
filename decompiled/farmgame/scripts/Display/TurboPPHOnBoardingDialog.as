package Display
{
   import Classes.util.ZLocUtils;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class TurboPPHOnBoardingDialog extends FarmDynamicDialog
   {
      
      private static const ACTION_COUNT_NAME:String = "TurboPPHOnBoardingDialogCount";
      
      private static const ACTION_COUNT_THRESHOLD:int = 1;
      
      public function TurboPPHOnBoardingDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      private static function shouldShow() : Boolean
      {
         var result:Boolean = false;
         var count:int = Global.player.getActionCount(ACTION_COUNT_NAME);
         if(count <= ACTION_COUNT_THRESHOLD)
         {
            Global.player.incrementActionCount(ACTION_COUNT_NAME,true);
            count++;
         }
         if(count == ACTION_COUNT_THRESHOLD)
         {
            result = true;
         }
         return result;
      }
      
      public static function conditionalShow() : void
      {
         var turboPPHOnBoardingDialog:TurboPPHOnBoardingDialog = null;
         if(shouldShow())
         {
            turboPPHOnBoardingDialog = FarmDynamicDialog.createDialog("TurboPPHOnBoardingDialog",TurboPPHOnBoardingDialog) as TurboPPHOnBoardingDialog;
            if(turboPPHOnBoardingDialog != null)
            {
               turboPPHOnBoardingDialog.setupDialog();
               turboPPHOnBoardingDialog.show();
            }
         }
      }
      
      private function setupDialog() : void
      {
         var titleText:String = ZLocUtils.t("Dialogs","TurboPPHOnBoardingTitle");
         setShortcutAttribute("titletext",TextFieldView.ATTRIBUTE_TEXT,titleText);
         setShortcutListener("okButton",WidgetControllerEvent.BUTTON_PRESSED,this.onOKPressed);
      }
      
      private function onOKPressed(event:WidgetControllerEvent) : void
      {
         destroy();
      }
   }
}

