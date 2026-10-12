package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.BeanstalkHoverManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class BeanstalkToasterWindow extends AutoCloseToasterWindow
   {
      
      private const ASSET_PATH:String = "assets/dialogs/FV_Beanstalk_toaster2.swf";
      
      private var m_manager:BeanstalkHoverManager = null;
      
      public function BeanstalkToasterWindow(manager:BeanstalkHoverManager)
      {
         super(this.ASSET_PATH);
         this.m_manager = manager;
         m_timeToLive = 10000;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("headline_tf"))
         {
            addWidget(new ZwTextField(m_window["headline_tf"],ZLocUtils.t("Dialogs","Retention_beanstalk_wither_toaster")));
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],ZLocUtils.t("Dialogs","Retention_Beanstalk_ToasterRegrow"),this.onToasterRegrow));
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t("Dialogs","Retention_beanstalk_wither_title")));
         }
      }
      
      private function onToasterRegrow(event:MouseEvent) : void
      {
         FarmStatsManager.featureSample(BeanstalkHoverManager.BEANSTALK_STATS_KINGDOM,"regrow","toaster",this.m_manager.getRegrowHeight().toString(),this.m_manager.getRegrowPrice().toString());
         this.m_manager.showRegrowConfirmation();
      }
   }
}

