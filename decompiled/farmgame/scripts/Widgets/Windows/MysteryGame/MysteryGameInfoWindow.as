package Widgets.Windows.MysteryGame
{
   import Classes.util.ZLocUtils;
   import Display.MysteryBoxBalloonDialog;
   import Managers.FarmStatsManager;
   import Managers.MiniDartsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class MysteryGameInfoWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_MysteryInfoNew.swf";
      
      private static const NEW_ASSET_URL:String = "assets/dialogs/FV_MysteryInfoNew_2.swf";
      
      private static const REVAMP_ASSET_URL:String = "assets/dialogs/FV_motd_GardenOfGifts_2015.swf";
      
      private var m_mysteryBalloonDialog:MysteryBoxBalloonDialog;
      
      public function MysteryGameInfoWindow(mysteryBalloonDialog:MysteryBoxBalloonDialog = null)
      {
         var asset:String = ASSET_URL;
         if(MysteryBoxBalloonDialog.IN_LOOT_TABLE_VARIANT)
         {
            asset = NEW_ASSET_URL;
         }
         if(MiniDartsManager.getInstance().isFeatureActive())
         {
            asset = REVAMP_ASSET_URL;
         }
         if(mysteryBalloonDialog)
         {
            this.m_mysteryBalloonDialog = mysteryBalloonDialog;
         }
         super(asset,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         if(MiniDartsManager.getInstance().isFeatureActive())
         {
            this.setLocText();
         }
         else if(MysteryBoxBalloonDialog.IN_LOOT_TABLE_VARIANT)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","MysteryBoxGameNewWayToPlayV2")));
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","MysteryBoxGameNewWayInfoV2")));
            addWidget(new FarmAnimatedTextButton(m_window.growNow_bt,ZLocUtils.t("Dialogs","StartPlaying"),this.onClose));
         }
         else
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","MysteryBoxGameNewWayToPlay")));
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","MysteryBoxGameNewWayInfo")));
            addWidget(new FarmAnimatedTextButton(m_window.growNow_bt,ZLocUtils.t("Dialogs","StartPlaying"),this.onClose));
         }
      }
      
      private function setLocText() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","minidarts_revamp_motd_title")));
         addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","minidarts_revamp_motd_body")));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","minidarts_revamp_motd_cta"),this.onClose));
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_mysteryBalloonDialog)
         {
            this.m_mysteryBalloonDialog.onMotdCloseCallback();
         }
         FarmStatsManager.count("MOTD","close","MOTD_DARTGAMEv2","","",Global.worldManager.currentWorldType);
         super.close();
      }
   }
}

