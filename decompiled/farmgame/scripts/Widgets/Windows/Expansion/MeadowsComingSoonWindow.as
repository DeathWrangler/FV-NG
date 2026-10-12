package Widgets.Windows.Expansion
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.util.ZLocUtils;
   import Managers.WorldStatManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class MeadowsComingSoonWindow extends FarmWindow
   {
      
      public static const DIALOGNAME_LAVENDER:String = "xmw_meadow_lavender";
      
      public static const DIALOGNAME_TULIP:String = "xmw_meadow_tulip";
      
      private var m_meadowDialog:String = null;
      
      private var m_acceptText:String = null;
      
      public function MeadowsComingSoonWindow(assetPath:String = "assets/decorations/FV_meadowsPrompt.swf", parameters:XML = null)
      {
         super(assetPath,true,true);
         this.m_meadowDialog = parameters.dialogName;
         this.m_acceptText = ZLocUtils.t("Dialogs",this.m_meadowDialog + "_dialog");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(this.m_meadowDialog == DIALOGNAME_LAVENDER && Boolean(m_window.comingSoonLavender_mc))
         {
            addWidget(new ZwFrame(m_window.comingSoonLavender_mc));
         }
         else if(this.m_meadowDialog == DIALOGNAME_TULIP && Boolean(m_window.comingSoonTulip_mc))
         {
            addWidget(new ZwFrame(m_window.comingSoonTulip_mc));
         }
         if(m_window.okay_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.okay_bt,this.m_acceptText,this.acceptPrompt));
         }
         WorldStatManager.trackWorldComingSoonDialog(this.m_meadowDialog,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
      }
      
      private function acceptPrompt(event:Event) : void
      {
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_meadowDialog = null;
         this.m_acceptText = null;
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         WorldStatManager.trackWorldComingSoonDialog(this.m_meadowDialog,StatsTrackingConstants.STATS_X);
         super.onClose(event);
      }
   }
}

