package Widgets.Windows.MOTD
{
   import Classes.util.ExternalUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Transactions.TSawSpecificMOTD;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public class TwitterIntegrationWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_Tweed_MOTD.swf";
      
      private var m_headline:ZwTextField = null;
      
      private var m_bodyCopy:ZwTextField = null;
      
      private var m_connect:FarmAnimatedTextButton = null;
      
      public function TwitterIntegrationWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(ObjectUtil.pathExists(m_window,"mainWindow"))
         {
            addWidget(new ZwFrame(m_window.mainWindow));
            if(ObjectUtil.pathExists(m_window,"mainWindow","headline_tf"))
            {
               this.m_headline = addWidget(new ZwTextField(m_window.mainWindow.headline_tf,ZLocUtils.t("Dialogs","twitter_MOTD_headline"))) as ZwTextField;
            }
            if(ObjectUtil.pathExists(m_window,"mainWindow","bodycopy_tf"))
            {
               this.m_bodyCopy = addWidget(new ZwTextField(m_window.mainWindow.bodycopy_tf,ZLocUtils.t("Dialogs","twitter_MOTD_body"))) as ZwTextField;
            }
            if(ObjectUtil.pathExists(m_window,"mainWindow","connect_bt"))
            {
               this.m_connect = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.connect_bt,ZLocUtils.t("Dialogs","twitter_MOTD_button_text"),this.onClickConnect)) as FarmAnimatedTextButton;
            }
            if(ObjectUtil.pathExists(m_window,"mainWindow","close_bt"))
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClickClose)) as FarmButton;
            }
         }
      }
      
      public function onClickConnect(evt:MouseEvent) : void
      {
         FarmStatsManager.count("MOTD","OK","MOTD_TWITTER");
         FarmStatsManager.count("twitter","opt_click","in","MOTD");
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("onGetTwitterUrl",this.onGetTwitterUrl);
            ExternalUtil.instance.call("onGetTwitterUrl");
            onClose(evt);
         }
      }
      
      public function onGetTwitterUrl(url:String) : void
      {
         if(url)
         {
            GlobalEngine.socialNetwork.redirect(url,null,"_blank",false);
            if(Boolean(m_currentMOTD) && Boolean(m_currentMOTD.motdSeenFlag) && !Global.player.isMotdSeenFlagSet(m_currentMOTD.motdSeenFlag))
            {
               TransactionManager.addTransaction(new TSawSpecificMOTD(m_currentMOTD));
            }
            close();
         }
      }
      
      public function onClickClose(evt:MouseEvent) : void
      {
         FarmStatsManager.count("MOTD","click","MOTD_TWITTER_X");
         this.m_headline.text = ZLocUtils.t("Dialogs","twitter_MOTD_headline_2");
         this.m_bodyCopy.text = ZLocUtils.t("Dialogs","twitter_MOTD_body_2");
         removeWidget(this.m_connect);
         if(ObjectUtil.pathExists(m_window,"mainWindow","connect_bt"))
         {
            this.m_connect = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.connect_bt,ZLocUtils.t("Dialogs","twitter_MOTD_button_text_2"),this.onFinalClose)) as FarmAnimatedTextButton;
         }
         removeWidget(m_closeButton);
      }
      
      public function onFinalClose(evt:MouseEvent) : void
      {
         FarmStatsManager.count("MOTD","OK","MOTD_TWITTER_DECLINE");
         FarmStatsManager.count("twitter","opt_click","out","MOTD");
         TransactionManager.addTransaction(new TGenericTransaction("UserService","setTwitterOptOut"));
         onClose(evt);
      }
   }
}

