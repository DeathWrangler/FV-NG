package Widgets.Windows.Expansion
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class MeadowsFTUIWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_meadowsPopup.swf";
      
      public function MeadowsFTUIWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","xmw_ftui_dialog_text")));
         addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("FarmGame","Okay"),this.onOkayClick));
      }
      
      private function onOkayClick(event:MouseEvent) : void
      {
         close();
      }
   }
}

