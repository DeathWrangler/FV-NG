package Widgets.Windows.FleaMarket
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.AutoCloseToasterWindow;
   import flash.events.Event;
   
   public class FleaMarketToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_toaster_FleaMarket.swf";
      
      public function FleaMarketToasterWindow()
      {
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         FarmStatsManager.count("trading","toaster_sell","view");
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","fleaMarketToasterTitle")));
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","fleaMarketToasterText")));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Okay"),this.openFleaMarketWindow));
      }
      
      private function openFleaMarketWindow(event:Event) : void
      {
         var dialog:FleaMarketWindow = null;
         FarmStatsManager.count("trading","toaster_sell","click");
         if(!Global.worldManager.isVisiting())
         {
            dialog = new FleaMarketWindow();
            UI.displayPopup(dialog,false,"FleaMarketWindow",true);
         }
      }
   }
}

