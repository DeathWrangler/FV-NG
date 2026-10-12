package Widgets.Windows
{
   import Managers.AmsterdamInnovationManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class AmsterdamInnovationLeaderboardRewardWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_titleTf:ZwTextField;
      
      private var m_league1_mc:MovieClip;
      
      private var m_league2_mc:MovieClip;
      
      private var m_league3_mc:MovieClip;
      
      private var m_league4_mc:MovieClip;
      
      private var m_weekCount:int;
      
      public function AmsterdamInnovationLeaderboardRewardWindow(assetPath:String = "", featureName:String = null)
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var cureWeekObject:Object = this.manager.getCurrentWeek();
         this.m_weekCount = cureWeekObject.count;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window["title_tf"],"Week " + this.m_weekCount.toString() + " League Reward"));
            this.m_titleTf.visible = true;
         }
         if(m_window.hasOwnProperty("league1_mc"))
         {
            this.m_league1_mc = m_window["league1_mc"] as MovieClip;
            this.m_league1_mc.visible = false;
         }
         if(m_window.hasOwnProperty("league2_mc"))
         {
            this.m_league2_mc = m_window["league2_mc"] as MovieClip;
            this.m_league2_mc.visible = false;
         }
         if(m_window.hasOwnProperty("league3_mc"))
         {
            this.m_league3_mc = m_window["league3_mc"] as MovieClip;
            this.m_league3_mc.visible = false;
         }
         if(m_window.hasOwnProperty("league4_mc"))
         {
            this.m_league4_mc = m_window["league4_mc"] as MovieClip;
            this.m_league4_mc.visible = false;
         }
         this.updateLeagueFrames();
      }
      
      private function updateLeagueFrames() : void
      {
         var currLeague:int = this.manager.getCurrentLeague();
         switch(currLeague)
         {
            case 0:
               if(this.m_league1_mc)
               {
                  this.m_league1_mc.visible = true;
                  this.m_league1_mc.gotoAndStop(this.m_weekCount);
               }
               break;
            case 1:
               if(this.m_league2_mc)
               {
                  this.m_league2_mc.visible = true;
                  this.m_league2_mc.gotoAndStop(this.m_weekCount);
               }
               break;
            case 2:
               if(this.m_league3_mc)
               {
                  this.m_league3_mc.visible = true;
                  this.m_league3_mc.gotoAndStop(this.m_weekCount);
               }
               break;
            case 3:
               if(this.m_league4_mc)
               {
                  this.m_league4_mc.visible = true;
                  this.m_league4_mc.gotoAndStop(this.m_weekCount);
               }
         }
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
      
      private function get manager() : AmsterdamInnovationManager
      {
         return AmsterdamInnovationManager.getInstance(this.m_featureName);
      }
   }
}

