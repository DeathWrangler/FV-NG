package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.ItemContestManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.Event;
   
   public class ItemContestMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_Contests2_MOTD.swf";
      
      public function ItemContestMOTDWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Dialogs","PlayNow"),this.onClickAccept));
      }
      
      override public function show() : void
      {
         super.show();
         FarmStatsManager.count("contests","MOTD","view");
      }
      
      private function onClickAccept(event:Event) : void
      {
         super.onClose(event);
         ItemContestManager.getInstance().displayDialog();
         FarmStatsManager.count("contests","MOTD","click");
      }
   }
}

