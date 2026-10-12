package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AmexTreeMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_ServeTree_MOTD.swf";
      
      public function AmexTreeMOTDWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.cashAnimated_mc)
         {
            (m_window.cashAnimated_mc as MovieClip).stop();
         }
         addWidget(new ZwTextField(m_window.line1_tf,ZLocUtils.t("Dialogs","MOTD_AmexTree_line1")));
         addWidget(new ZwTextField(m_window.line2_tf,ZLocUtils.t("Dialogs","MOTD_AmexTree_line2")));
         addWidget(new ZwTextField(m_window.legal_tf,ZLocUtils.t("Dialogs","AmexTree_MOTD_footer")));
         addWidget(new FarmAnimatedTextButton(m_window.place_btn,ZLocUtils.t("Dialogs","PlaceNow"),this.onClickAccept));
      }
      
      override public function show() : void
      {
         super.show();
         FarmStatsManager.count("serve_tree","MOTD","view");
         if(Boolean(m_window) && Boolean(m_window.cashAnimated_mc))
         {
            (m_window.cashAnimated_mc as MovieClip).visible = true;
            (m_window.cashAnimated_mc as MovieClip).play();
         }
      }
      
      private function onClickAccept(event:Event) : void
      {
         FarmStatsManager.count("serve_tree","MOTD","click");
         if(m_acceptCallback != null)
         {
            m_acceptCallback.call();
         }
         super.onClose(event);
      }
   }
}

