package Widgets.Windows
{
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BoraBoraInnovationScreenshotPopUp extends FarmWindow
   {
      
      private var m_okatBt:FarmAnimatedTextButton;
      
      private var m_featureName:String;
      
      private var m_screenshotPopMc:MovieClip;
      
      private var m_noBt:FarmAnimatedTextButton;
      
      public function BoraBoraInnovationScreenshotPopUp(featureName:String, windowAssetRelUrl:String)
      {
         this.m_featureName = featureName;
         super(windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("screenshot_popup_mc"))
         {
            this.m_screenshotPopMc = m_window["screenshot_popup_mc"] as MovieClip;
            this.m_screenshotPopMc.visible = true;
            if(this.m_screenshotPopMc.hasOwnProperty("header_tf"))
            {
            }
            if(this.m_screenshotPopMc.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_noBt = new FarmAnimatedTextButton(this.m_screenshotPopMc["okay_bt"],"Okay!",this.onOkayClick));
               this.m_noBt.visible = true;
            }
            if(this.m_screenshotPopMc.hasOwnProperty("share_bt"))
            {
               addWidget(this.m_okatBt = new FarmAnimatedTextButton(this.m_screenshotPopMc["share_bt"],"Skip",this.onNoBtClick));
               this.m_okatBt.visible = true;
            }
         }
      }
      
      private function onNoBtClick(e:Event = null) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
            this.manager.showNewCycleStartWindow();
         }
         super.close();
      }
      
      private function onOkayClick(e:Event = null) : void
      {
         super.close();
         this.manager.setCycleStartEntry();
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.close();
         }
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance(this.m_featureName);
      }
   }
}

