package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class EmailCampaignConfirmWindow extends FarmWindow
   {
      
      private const ASSET_URL:String = "assets/dialogs/FV_confirmation_EmailCampaign.swf";
      
      private var m_yes_bt:FarmAnimatedTextButton;
      
      private var m_description_tf:ZwTextField;
      
      public function EmailCampaignConfirmWindow()
      {
         FarmStatsManager.count("view","ingamepopup","consumable_boost_email_confirm","view");
         super(this.ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.mainWindow)
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.body_tf))
         {
            addWidget(this.m_description_tf = new ZwTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","EmailCampaignConfirmWindow_Body")));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.yes_bt))
         {
            addWidget(this.m_yes_bt = new FarmAnimatedTextButton(m_window.mainWindow.yes_bt,ZLocUtils.t("Dialogs","EmailCampaignConfirmWindow_YesBTText"),this.onClose));
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
   }
}

