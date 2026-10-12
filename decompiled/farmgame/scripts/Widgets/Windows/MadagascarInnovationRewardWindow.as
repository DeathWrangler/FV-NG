package Widgets.Windows
{
   import Managers.MadagascarInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MadagascarInnovationRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private var m_featureName:String;
      
      private var m_highLighterMCArray:Array;
      
      private var m_progressLevelArray_mc:Array;
      
      private var m_progressLevelArray_tf:Array;
      
      public const ProgressLevelTextArray:Array = ["Hospital Level 1","Hospital Level 2","Hospital Level 3","Hospital Level 4","Hospital Level 5"];
      
      public const ProgressLevelPointArray:Array = ["1 week","2 weeks","3 weeks","4 weeks","5 weeks"];
      
      public const ProgressLevelSubtextArray:Array = this.ProgressLevelTextArray;
      
      private const BACK_BT:String = "okay_bt";
      
      private var m_knowMoreMC:MovieClip;
      
      private var m_knowMoreCloseBt:FarmButton;
      
      private var m_previewMCArray:Array = [];
      
      private var m_rewardMCArray:Array = [];
      
      private var m_knowMoreBt:FarmAnimatedButton;
      
      private const FINALREWARD_WELCOME_SEEN_FLAG:String = "Final_Reward_Welcome_flag";
      
      public function MadagascarInnovationRewardWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            addWidget(this.m_knowMoreBt = new FarmAnimatedButton(m_window.whatisthis_mc,this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("knowMore_mc"))
         {
            this.m_knowMoreMC = m_window.knowMore_mc as MovieClip;
            this.m_knowMoreMC.visible = false;
            if(this.m_knowMoreMC.hasOwnProperty("close_bt"))
            {
               this.m_knowMoreCloseBt = new FarmButton(this.m_knowMoreMC["close_bt"],this.onKnowMoreMcClose);
               this.m_knowMoreBt.attachTooltip(new FarmTextTooltip("Know More"));
            }
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "Build It To Win It!";
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            m_window["npc_mc"].visible = true;
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = "Keep upgrading the Hospital to harvest it everyday till April 26th!";
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            m_window["body2_tf"].visible = true;
            m_window["body2_tf"].text = "Keep upgrading the Hospital to harvest it everyday till April 26th!";
         }
         if(m_window.hasOwnProperty(this.BACK_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.BACK_BT],"AWESOME",onClose));
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.FINALREWARD_WELCOME_SEEN_FLAG);
         }
         for(var j:int = 0; j < this.ProgressLevelTextArray.length; j++)
         {
            if(m_window.hasOwnProperty("info" + (j + 1).toString() + "_tf"))
            {
               m_window["info" + (j + 1).toString() + "_tf"].visible = true;
               m_window["info" + (j + 1).toString() + "_tf"].text = "Get the Healthy Rating for at least " + this.ProgressLevelPointArray[j] + " to get this building!";
            }
         }
         this.m_highLighterMCArray = [];
         this.m_progressLevelArray_mc = [];
         this.m_progressLevelArray_tf = [];
         for(var i:int = 0; i < this.ProgressLevelTextArray.length; i++)
         {
            this.m_highLighterMCArray[i] = m_window["highlighter" + (i + 1).toString() + "_mc"] as MovieClip;
            this.m_highLighterMCArray[i].visible = false;
            this.m_progressLevelArray_mc[i] = m_window["level" + (i + 1).toString() + "_mc"] as MovieClip;
            this.m_progressLevelArray_mc[i].visible = true;
            this.m_progressLevelArray_mc[i].gotoAndStop(1);
            this.m_progressLevelArray_tf[i] = new ZwTextField(this.m_progressLevelArray_mc[i]["level_tf"],this.ProgressLevelSubtextArray[i]);
            if(m_window.hasOwnProperty("hitArea" + (i + 1).toString() + "_mc"))
            {
               addWidget(this.m_previewMCArray[i] = new ZwFrame(m_window["hitArea" + (i + 1).toString() + "_mc"]),true);
               if(this.manager.getRewardLevel() - 1 != i)
               {
                  this.m_previewMCArray[i].registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver(i));
                  this.m_previewMCArray[i].registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut(i));
               }
            }
            if(m_window.hasOwnProperty("consumable_" + (i + 1).toString() + "_ani"))
            {
               this.m_rewardMCArray[i] = m_window["consumable_" + (i + 1).toString() + "_ani"] as MovieClip;
               this.m_rewardMCArray[i].visible = false;
            }
         }
         if(this.m_previewMCArray[0])
         {
            this.m_previewMCArray[0].attachTooltip(new FarmTextTooltip("This building is not harvestable!"));
         }
         this.updateHighLighter();
      }
      
      public function onMouseOver(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            if(slotIndex == 0)
            {
               return;
            }
            m_rewardMCArray[slotIndex].visible = true;
            (m_rewardMCArray[slotIndex] as MovieClip).gotoAndPlay(2);
         };
      }
      
      public function onMouseOut(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            if(slotIndex == 0)
            {
               return;
            }
            (m_rewardMCArray[slotIndex] as MovieClip).gotoAndPlay(61);
            m_rewardMCArray[slotIndex].visible = true;
         };
      }
      
      private function updateHighLighter() : void
      {
         var activeRewardIndex:int = this.manager.getRewardLevel() - 1;
         if(activeRewardIndex >= 0)
         {
            if(activeRewardIndex > 0)
            {
               this.m_highLighterMCArray[activeRewardIndex].visible = true;
               this.m_rewardMCArray[activeRewardIndex].visible = true;
               this.m_rewardMCArray[activeRewardIndex].play();
            }
            this.m_progressLevelArray_mc[activeRewardIndex].gotoAndStop(2);
         }
      }
      
      private function get manager() : MadagascarInnovationManager
      {
         return MadagascarInnovationManager.getInstance();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.m_knowMoreMC.visible = true;
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
      
      private function onKnowMoreMcClose(e:Event = null) : void
      {
         this.m_knowMoreMC.visible = false;
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.FINALREWARD_WELCOME_SEEN_FLAG);
      }
   }
}

