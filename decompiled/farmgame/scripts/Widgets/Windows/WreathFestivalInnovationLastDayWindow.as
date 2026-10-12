package Widgets.Windows
{
   import Managers.WreathFestivalInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class WreathFestivalInnovationLastDayWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_index:int = 0;
      
      private var m_mainscreen_mc:MovieClip;
      
      private var m_title_tf:TextField;
      
      private var m_subtitle_tf:TextField;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function WreathFestivalInnovationLastDayWindow(featureName:String, assetPath:String = "", playIndex:int = 0)
      {
         this.m_featureName = featureName;
         this.m_index = playIndex;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            this.m_mainscreen_mc = m_window["mainWindow"] as MovieClip;
            if(this.m_mainscreen_mc.hasOwnProperty("tittle_tf"))
            {
               this.m_title_tf = TextField(this.m_mainscreen_mc["tittle_tf"]);
            }
            if(this.m_mainscreen_mc.hasOwnProperty("subtext_tf"))
            {
               this.m_subtitle_tf = TextField(this.m_mainscreen_mc["subtext_tf"]);
            }
            if(this.m_mainscreen_mc.hasOwnProperty("accept_bt"))
            {
               addWidget(this.m_accept_bt = new FarmAnimatedTextButton(this.m_mainscreen_mc["accept_bt"],"",this.onAcceptClick));
            }
            this.m_mainscreen_mc.visible = true;
            this.updateMessages();
         }
      }
      
      private function updateMessages() : void
      {
         if(Boolean(this.m_title_tf) && Boolean(this.m_subtitle_tf) && Boolean(this.m_accept_bt))
         {
            if(this.m_index == 0)
            {
               this.m_title_tf.text = "THE COMPETITION IS OVER!";
               this.m_subtitle_tf.text = "Refresh game to check your final rewards!\n\nKeep playing Farmville for more fun features and win cool rewards!";
               this.m_accept_bt.text = "Alright!";
            }
            else if(this.m_index == 1)
            {
               this.m_title_tf.text = "The competition is almost over!";
               this.m_subtitle_tf.text = "Keep playing for leaderboard rewards. \n\nYou can still earn a better reward by ranking up!";
               this.m_accept_bt.text = "Let\'s Go!";
            }
            else if(this.m_index == 2)
            {
               this.m_title_tf.text = "The competition ends soon!";
               this.m_subtitle_tf.text = "Finish tasks and earn points for the grand prize!\n\nKeep playing! Better average gives better bonus rewards!";
               this.m_accept_bt.text = "Okay!";
            }
         }
      }
      
      public function onAcceptClick(e:Event = null) : void
      {
         if(this.m_index == 0)
         {
            if(this.manager.mainWindow)
            {
               this.manager.mainWindow.close();
            }
         }
         this.close();
      }
      
      private function get manager() : WreathFestivalInnovationManager
      {
         return WreathFestivalInnovationManager.getInstance();
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.enableInput = true;
            this.manager.mainWindow.untintWindow();
         }
         super.close();
      }
   }
}

