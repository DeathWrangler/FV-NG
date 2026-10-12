package Widgets.Windows
{
   import Engine.Utilities;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.OrderBoard.FarmRunV5Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmRunV5OrderboardFrame;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmRunV5OrderBoardWindow extends FarmWindowWithTutorial
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "body_tf";
      
      private var m_featureName:String = null;
      
      private var m_descriptionTf:ZwTextField;
      
      private var m_world1_mc:MovieClip;
      
      private var m_world2_mc:MovieClip;
      
      private var m_world3_mc:MovieClip;
      
      private var m_world4_mc:MovieClip;
      
      public var m_talkMc:MovieClip;
      
      public var m_pointerMc:MovieClip;
      
      private var m_taskFrame:FarmRunV5OrderboardFrame;
      
      private var m_loadingTf:ZwTextField;
      
      protected var m_DumptutorialScene:int = 0;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      protected const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      private var m_highlightMc:MovieClip;
      
      private var m_okayBt:FarmAnimatedTextButton;
      
      private var m_taskPointsMc:MovieClip;
      
      private var m_taskPointsTf:ZwTextField;
      
      public var m_talk_tf:ZwTextField;
      
      public function FarmRunV5OrderBoardWindow(featureName:String, assetURL:String)
      {
         this.m_featureName = featureName;
         FarmRunV5Manager.getInstance(featureName).parseTaskObjectsFromCOnfig(featureName);
         super(featureName,assetURL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[TITLE_TF],"FARM RUN")).visible = true;
         }
         if(m_window.hasOwnProperty(BODY_TF))
         {
            addWidget(this.m_descriptionTf = new ZwTextField(m_window[BODY_TF],"Finish 4 orders to earn points in the challenge!"));
         }
         if(m_window.hasOwnProperty("world1BG_mc"))
         {
            this.m_world1_mc = m_window["world1BG_mc"] as MovieClip;
            this.m_world1_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world2BG_mc"))
         {
            this.m_world2_mc = m_window["world2BG_mc"] as MovieClip;
            this.m_world2_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world3BG_mc"))
         {
            this.m_world3_mc = m_window["world3BG_mc"] as MovieClip;
            this.m_world3_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world4BG_mc"))
         {
            this.m_world4_mc = m_window["world4BG_mc"] as MovieClip;
            this.m_world4_mc.visible = false;
         }
         var worldId:int = this.manager.getworldIndexFromName(this.manager.getFarmrunWorldFromPoints());
         var worldElement:String = "world" + (worldId + 1) + "BG_mc";
         if(m_window.hasOwnProperty(worldElement))
         {
            m_window[worldElement].visible = true;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
         }
         if(Boolean(this.m_talkMc) && this.m_talkMc.hasOwnProperty("npc_tf"))
         {
            addWidget(this.m_talk_tf = new ZwTextField(this.m_talkMc["npc_tf"]));
            this.m_talk_tf.visible = true;
         }
         if(m_window.hasOwnProperty("highlight_mc"))
         {
            this.m_highlightMc = m_window.highlight_mc as MovieClip;
            this.m_highlightMc.visible = false;
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(this.m_okayBt = new FarmAnimatedTextButton(m_window["okay_bt"],"Okay",null));
            this.m_okayBt.visible = false;
         }
         if(m_window.hasOwnProperty("tasks_mc"))
         {
            this.m_taskFrame = new FarmRunV5OrderboardFrame(m_window["tasks_mc"],this,this.m_featureName,this.manager);
            this.m_taskFrame.visible = true;
            if(m_window["tasks_mc"].hasOwnProperty("points_mc"))
            {
               this.m_taskPointsMc = m_window["tasks_mc"].points_mc as MovieClip;
               if(this.m_taskPointsMc.hasOwnProperty("points_tf"))
               {
                  addWidget(this.m_taskPointsTf = new ZwTextField(this.m_taskPointsMc["points_tf"],"25"));
                  this.m_taskPointsTf.visible = true;
               }
               this.m_taskPointsMc.visible = true;
            }
         }
      }
      
      public function updateOnOrderboardEnd(openGameWindow:Boolean) : void
      {
         if(this.m_highlightMc)
         {
            this.m_highlightMc.visible = true;
         }
         if(this.m_okayBt)
         {
            this.m_okayBt.visible = true;
            this.m_okayBt.enabled = true;
            this.m_okayBt.callback = openGameWindow ? this.showScoreboardUI : this.closeWindow;
         }
         if(m_closeButton)
         {
            m_closeButton.visible = false;
            m_closeButton.enabled = false;
         }
         if(FeatureOptionsInventoryManager.getInstance().getCount(this.manager.currency) >= 1000 && Boolean(this.m_descriptionTf))
         {
            this.m_descriptionTf.text = "Hurray! All tasks complete! You’ve been awarded 25 points!";
         }
      }
      
      public function showScoreboardUI(evt:MouseEvent) : void
      {
         this.manager.openScoreBoard();
         this.close();
      }
      
      public function closeWindow(evt:MouseEvent) : void
      {
         this.manager.displayMainWindowNPC();
         this.close();
      }
      
      public function showDumpTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         this.m_DumptutorialScene = 1;
         if(this.m_DumpTutorial)
         {
            element = this.m_DumpTutorial.element as MovieClip;
            element.gotoAndStop(1);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window[this.DUMPFTUE_MC].okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            this.m_DumpTutorial.visible = true;
         }
      }
      
      public function refreshTaskFrame() : void
      {
         if(this.m_loadingTf)
         {
            this.m_loadingTf.visible = false;
         }
         this.m_taskFrame.refresh();
      }
      
      public function updateNPCTextAfterQuiz() : void
      {
         var currentFarmrunWorld:String = null;
         if(this.m_talkMc)
         {
            this.m_talkMc.visible = true;
            if(this.m_talk_tf)
            {
               this.m_talk_tf.text = "Wonderful\nYou can start the bonus round\nnow to win upto 16 points.";
               currentFarmrunWorld = this.manager.getFarmrunWorldFromPoints();
               if(Global.worldManager.currentWorldType != currentFarmrunWorld)
               {
                  this.m_talk_tf.text = "Hurray!\nAll tasks complete!\nYou’ve been awarded 25 points.";
               }
               if(this.manager.getFeatureProgress() >= FarmRunV5Manager.VAL_FINAL_MILESTONE)
               {
                  this.m_talk_tf.text = "\nWhat a race to victory!";
               }
            }
         }
      }
      
      private function get manager() : FarmRunV5Manager
      {
         return FarmRunV5Manager.getInstance(this.m_featureName);
      }
      
      public function resumeWindow() : void
      {
         untintWindow();
         enableInput = true;
         this.refreshTaskFrame();
      }
      
      public function closeWindowForTasks() : void
      {
         super.close();
         if(this.manager.m_window)
         {
            this.manager.m_window.close();
         }
      }
      
      override public function close() : void
      {
         super.close();
         if(this.manager.m_window)
         {
            this.manager.m_window.untintWindow();
            Utilities.toggleInputAndChildren(Global.ui,false);
            Utilities.toggleInputAndChildren(this.manager.m_window,true);
            this.manager.m_window.enableInput = true;
         }
      }
   }
}

