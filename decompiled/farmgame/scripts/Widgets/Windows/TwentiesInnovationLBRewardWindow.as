package Widgets.Windows
{
   import Managers.TwentiesInnovationManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class TwentiesInnovationLBRewardWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_reward_mc:MovieClip;
      
      private var m_size_mc:MovieClip;
      
      private var m_subtitle_tf:ZwTextField;
      
      public function TwentiesInnovationLBRewardWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var weekCount:int = 0;
         super.postLoadComplete();
         var weekData:Object = this.manager.getCurrentWeek();
         weekCount = int(weekData.count);
         if(m_window.hasOwnProperty("reward_mc"))
         {
            this.m_reward_mc = m_window["reward_mc"] as MovieClip;
            this.m_reward_mc.visible = true;
            this.m_reward_mc.gotoAndStop(weekCount);
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            this.m_subtitle_tf = new ZwTextField(m_window["subtitle_tf"],"Rank 4 and below: Super Fertilizer");
            addWidget(this.m_subtitle_tf,true);
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_size_mc = m_window["size_mc"] as MovieClip;
            this.m_size_mc.visible = true;
         }
      }
      
      private function get manager() : TwentiesInnovationManager
      {
         return TwentiesInnovationManager.getInstance();
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.close();
      }
   }
}

