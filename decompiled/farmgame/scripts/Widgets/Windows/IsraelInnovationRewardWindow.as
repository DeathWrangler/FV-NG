package Widgets.Windows
{
   import Managers.IsraelInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class IsraelInnovationRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private var m_featureName:String;
      
      private var m_highLighterMCArray:Array;
      
      private var m_progressLevelArray_mc:Array;
      
      private var m_progressLevelArray_tf:Array;
      
      public const ProgressLevelTextArray:Array = ["Family Farm House","Town Farm","Agro Export Complex"];
      
      public const ProgressLevelPointArray:Array = ["100-200","200-280","281 and above"];
      
      public const ProgressLevelSubtextArray:Array = ["GROWER","EXPORTER","TYCOON"];
      
      private const BACK_BT:String = "okay_bt";
      
      private var m_knowMoreMC:MovieClip;
      
      private var m_knowMoreCloseBt:FarmButton;
      
      private var m_rewardTooltip:FarmTextTooltip;
      
      private var m_idleNPC:MovieClip;
      
      private var m_informNPC:MovieClip;
      
      private var m_previewMCArray:Array = [];
      
      private var m_rewardMCArray:Array = [];
      
      private var m_knowMoreBt:FarmAnimatedButton;
      
      private const FINALREWARD_WELCOME_SEEN_FLAG:String = "Final_Reward_Welcome_flag";
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      public function IsraelInnovationRewardWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "THE GRAND PRIZE!";
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            m_window["npc_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("idle_ani_mc"))
         {
            this.m_idleNPC = m_window["idle_ani_mc"] as MovieClip;
            this.playIdleNPCAnimation();
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = "Harvest your grand prize everyday for goodies till 22 Oct!";
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            m_window["body2_tf"].visible = true;
            m_window["body2_tf"].text = "Harvest your grand prize everyday for goodies till 22 Oct!";
         }
         if(m_window.hasOwnProperty(this.BACK_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.BACK_BT],"AWESOME",onClose));
         }
         if(m_window.hasOwnProperty("inform_ani_mc"))
         {
            this.m_informNPC = m_window["inform_ani_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
            addWidget(this.m_npc1Tf = new ZwTextField(this.m_talkMc["npc1_tf"],"npc1"));
            addWidget(this.m_npc2Tf = new ZwTextField(this.m_talkMc["npc2_tf"],"Default NPC Text"));
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talkAutoMc = m_window.talk_auto_mc as MovieClip;
            this.m_talkAutoMc.visible = false;
            if(this.m_talkAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_autoTalkMc = this.m_talkAutoMc.talk_mc as MovieClip;
               this.m_autoTalkMc.visible = true;
               this.m_autoNpc1Tf = new ZwTextField(this.m_autoTalkMc["npc1_tf"]," Auto npc1");
               this.m_autoNpc2Tf = new ZwTextField(this.m_autoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.FINALREWARD_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("You reap what you sow","When the Farm-Off ends you will get a cool prize, depending on your final score.");
            this.playInformNPCAnimation();
         }
         else
         {
            this.playIdleNPCAnimation();
         }
         for(i = 0; i < 3; i++)
         {
            if(m_window.hasOwnProperty("info" + (i + 1).toString() + "_tf"))
            {
               m_window["info" + (i + 1).toString() + "_tf"].visible = true;
               m_window["info" + (i + 1).toString() + "_tf"].text = "Get an average score between " + this.ProgressLevelPointArray[i] + " to win this";
            }
         }
         for(i = 0; i < 3; i++)
         {
            if(m_window.hasOwnProperty("name" + (i + 1).toString() + "_tf"))
            {
               m_window["name" + (i + 1).toString() + "_tf"].visible = true;
               m_window["name" + (i + 1).toString() + "_tf"].text = this.ProgressLevelTextArray[i];
            }
         }
         this.m_highLighterMCArray = [];
         this.m_progressLevelArray_mc = [];
         this.m_progressLevelArray_tf = [];
         for(i = 0; i < 3; i++)
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
               if(this.manager.overAllProgressLevel() != i)
               {
                  this.m_previewMCArray[i].registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver(i));
                  this.m_previewMCArray[i].registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut(i));
               }
               this.m_rewardTooltip = new FarmTextTooltip(this.ProgressLevelTextArray[i]);
               this.m_previewMCArray[i].attachTooltip(this.m_rewardTooltip);
            }
            if(m_window.hasOwnProperty("consumable_" + (i + 1).toString() + "_ani"))
            {
               this.m_rewardMCArray[i] = m_window["consumable_" + (i + 1).toString() + "_ani"] as MovieClip;
               this.m_rewardMCArray[i].visible = false;
            }
         }
         this.updateHighLighter();
      }
      
      public function onMouseOver(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_rewardMCArray[slotIndex].visible = true;
            (m_rewardMCArray[slotIndex] as MovieClip).gotoAndPlay(2);
         };
      }
      
      public function onMouseOut(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            (m_rewardMCArray[slotIndex] as MovieClip).gotoAndPlay(61);
            m_rewardMCArray[slotIndex].visible = true;
         };
      }
      
      private function updateHighLighter() : void
      {
         var activeRewardIndex:int = this.manager.overAllProgressLevel();
         if(activeRewardIndex >= 0)
         {
            this.m_highLighterMCArray[activeRewardIndex].visible = true;
            this.m_progressLevelArray_mc[activeRewardIndex].gotoAndStop(2);
            this.m_rewardMCArray[activeRewardIndex].visible = true;
            this.m_rewardMCArray[activeRewardIndex].play();
         }
      }
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance();
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
      
      public function listenForInformAnimationEnd(e:Event = null) : void
      {
         if(this.m_informNPC.currentFrame == 220)
         {
            this.m_informNPC.stop();
            this.m_informNPC.visible = false;
         }
      }
      
      public function playIdleNPCAnimation() : void
      {
         var child:MovieClip = null;
         var grandChildIndex:int = 0;
         var grandChild:MovieClip = null;
         this.m_idleNPC.visible = true;
         for(var childIndex:int = 1; childIndex < this.m_idleNPC.numChildren; childIndex++)
         {
            child = this.m_idleNPC.getChildAt(childIndex) as MovieClip;
            if(child)
            {
               child.play();
               for(grandChildIndex = 1; grandChildIndex < child.numChildren; grandChildIndex++)
               {
                  grandChild = child.getChildAt(grandChildIndex) as MovieClip;
                  if(grandChild)
                  {
                     grandChild.play();
                  }
               }
            }
         }
         this.m_idleNPC.play();
      }
      
      public function playInformNPCAnimation() : void
      {
         var child:MovieClip = null;
         var grandChildIndex:int = 0;
         var grandChild:MovieClip = null;
         this.m_idleNPC.visible = false;
         this.m_informNPC.visible = true;
         for(var childIndex:int = 1; childIndex < this.m_informNPC.numChildren; childIndex++)
         {
            child = this.m_informNPC.getChildAt(childIndex) as MovieClip;
            if(child)
            {
               child.play();
               for(grandChildIndex = 1; grandChildIndex < child.numChildren; grandChildIndex++)
               {
                  grandChild = child.getChildAt(grandChildIndex) as MovieClip;
                  if(grandChild)
                  {
                     grandChild.play();
                  }
               }
            }
         }
         this.m_informNPC.play();
         this.m_informNPC.addEventListener(Event.ENTER_FRAME,this.listenForInformAnimationEnd,false,0,true);
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.FINALREWARD_WELCOME_SEEN_FLAG);
      }
      
      private function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_autoNpc2Tf.text = text;
         this.m_autoNpc1Tf.text = title;
         this.m_talkAutoMc.visible = true;
         this.m_talkAutoMc.gotoAndPlay(1);
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
         this.m_talkMc.visible = true;
      }
      
      public function hideNPCCallout() : void
      {
         this.m_talkMc.visible = false;
      }
   }
}

