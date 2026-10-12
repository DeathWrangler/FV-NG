package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Transactions.TCommunityV2AutoSend;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Windows.CommunityV2SuccessToasterWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class CommunityV2MOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_CommunityV2.swf";
      
      private var m_opted_in:Boolean = true;
      
      public function CommunityV2MOTDWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var buttonText:String = ZLocUtils.t("Dialogs","Okay");
         FarmStatsManager.count("MOTD","impressions","community_v2_initial");
         m_window.main_mc.visible = true;
         m_window.main_mc.initialDialog_mc.visible = true;
         m_window.main_mc.initialDialog_mc.whatisthis_mc.visible = false;
         m_window.main_mc.recapture_mc.visible = false;
         addWidget(new FarmAnimatedTextButton(m_window.main_mc.initialDialog_mc.okay_bt,buttonText,this.onClickOkay));
         addWidget(new FarmAnimatedButton(m_window.main_mc.initialDialog_mc.CheckBox_mc,this.onCheckboxClick)) as FarmAnimatedButton;
         addWidget(new FarmAnimatedButton(m_window.main_mc.initialDialog_mc.checkMark_mc,this.onCheckboxClick)) as FarmAnimatedButton;
         m_window.main_mc.initialDialog_mc.checkMark_mc.visible = true;
         this.m_opted_in = true;
         m_window.main_mc.initialDialog_mc.checkMark_mc.visible = true;
      }
      
      private function onClickOkay(event:MouseEvent) : void
      {
         var buttonText:String = null;
         FarmStatsManager.count("MOTD","OK","community_v2_initial");
         if(!this.m_opted_in)
         {
            buttonText = ZLocUtils.t("Dialogs","CommunityNeighborsV2_SignUp_Button");
            FarmStatsManager.count("MOTD","impressions","community_v2_recapture");
            m_window.main_mc.initialDialog_mc.visible = false;
            m_window.main_mc.recapture_mc.visible = true;
            m_window.main_mc.recapture_mc.whatisthis_mc.visible = false;
            addWidget(new FarmAnimatedTextButton(m_window.main_mc.recapture_mc.signUp_bt,buttonText,this.onClickSignUp));
            addWidget(new FarmButton(m_window.main_mc.recapture_mc.close_bt,this.onClose));
         }
         else
         {
            super.onClose(event);
            this.setAutoSendCommunityNeighborPermission();
         }
      }
      
      private function onClickSignUp(event:MouseEvent) : void
      {
         FarmStatsManager.count("MOTD","OK","community_v2_recapture");
         this.m_opted_in = true;
         super.onClose(event);
         this.setAutoSendCommunityNeighborPermission();
      }
      
      private function onCheckboxClick(event:MouseEvent) : void
      {
         FarmStatsManager.count("MOTD","click","community_v2_initial_checkbox");
         if(this.m_opted_in)
         {
            this.m_opted_in = false;
            m_window.main_mc.initialDialog_mc.checkMark_mc.visible = false;
         }
         else
         {
            this.m_opted_in = true;
            m_window.main_mc.initialDialog_mc.checkMark_mc.visible = true;
         }
      }
      
      private function setAutoSendCommunityNeighborPermission() : void
      {
         if(this.m_opted_in)
         {
            TransactionManager.addTransaction(new TCommunityV2AutoSend(this.m_opted_in),true);
            ToasterManager.getInstance().add(new CommunityV2SuccessToasterWindow());
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("MOTD","click","community_v2_recapture_x");
         super.onClose(event);
      }
   }
}

