package Widgets.Windows
{
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BoraboraInnovationStageComplete extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_stageCompleteMc:MovieClip;
      
      private var m_okayBt:FarmAnimatedTextButton;
      
      private var m_speech:MovieClip;
      
      private var m_stage:int;
      
      public function BoraboraInnovationStageComplete(featureName:String, windowAssetRelUrl:String, stage:int)
      {
         this.m_featureName = featureName;
         this.m_stage = stage;
         super(windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var stageName:String = null;
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("stage_complete_mc"))
         {
            this.m_stageCompleteMc = m_window["stage_complete_mc"] as MovieClip;
            this.m_stageCompleteMc.visible = true;
            if(this.m_stageCompleteMc.hasOwnProperty("subheader_tf"))
            {
               addWidget(new ZwTextField(this.m_stageCompleteMc["subheader_tf"],"Keep up the good work!\n" + "Continue decorating the wedding and we\'ll be the best in no time!"));
            }
            if(this.m_stageCompleteMc.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_okayBt = new FarmAnimatedTextButton(this.m_stageCompleteMc["okay_bt"],"Awesome!",this.onOkayBtClick));
               this.m_okayBt.visible = true;
            }
            if(this.m_stageCompleteMc.hasOwnProperty("speechbuble_mc"))
            {
               this.m_speech = this.m_stageCompleteMc["speechbuble_mc"] as MovieClip;
               this.m_speech.visible = true;
               if(this.m_speech.hasOwnProperty("speechbuble_tf"))
               {
                  stageName = this.m_stage == 1 ? "Special" : "Best";
                  addWidget(new ZwTextField(this.m_speech["speechbuble_tf"],"The venue looks amazing! \n" + stageName + " Decors have been unlocked for you now!"));
               }
               if(this.m_speech.hasOwnProperty("speechbubleheader_tf"))
               {
               }
            }
         }
      }
      
      private function onOkayBtClick(e:Event = null) : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
            this.manager.mainWindow.NpcCalloutDeco();
         }
         close();
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance(this.m_featureName);
      }
   }
}

