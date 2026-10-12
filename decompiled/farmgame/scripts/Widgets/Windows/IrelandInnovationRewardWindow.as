package Widgets.Windows
{
   import Managers.OrderBoard.IrelandInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class IrelandInnovationRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private var m_featureName:String;
      
      private var m_highLighterMCArray:Array;
      
      private var m_progressLevelArray_mc:Array;
      
      private var m_progressLevelArray_tf:Array;
      
      public const ProgressLevelTextArray:Array = ["Warriors Barrack","Titans Barrack","Legendary Barrack"];
      
      public const ProgressLevelPointArray:Array = ["5-14","15-24","24 and above"];
      
      public const ProgressLevelSubtextArray:Array = ["EXPERT","PROFESSIONAL","CHAMPION"];
      
      private const BACK_BT:String = "okay_bt";
      
      private var m_knowMoreMC:MovieClip;
      
      private var m_knowMoreCloseBt:FarmButton;
      
      private var m_rewardTooltip:FarmTextTooltip;
      
      private var m_idleNPC:MovieClip;
      
      private var m_informNPC:MovieClip;
      
      private var m_previewMCArray:Array = [];
      
      private var m_rewardMCArray:Array = [];
      
      private var m_knowMoreBt:FarmAnimatedButton;
      
      private const FINALREWARD_WELCOME_SEEN_FLAG:String = "Ireland_Final_Reward_Welcome_flag";
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_icon_mc:MovieClip;
      
      private var m_iconMCArray:Array = [];
      
      private var m_iconMcWidgetArray:Array = [];
      
      private var m_iconGlowMCArray:Array = [];
      
      private var m_meterMc:MovieClip;
      
      private const MAX_POINT:int = 1100;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 627;
      
      private const POINTS_TF:String = "points_tf";
      
      private var m_pointerMc:MovieClip;
      
      private var m_meter_mc:MovieClip;
      
      public function IrelandInnovationRewardWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "All about the Bonus";
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            m_window["subtitle_tf"].visible = true;
            m_window["subtitle_tf"].text = "On feature end, you may be eligible for a Bonus Reward based on whether you stay a Baron or become a King!";
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            m_window["npc_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("pointer_mc"))
         {
            this.m_pointerMc = m_window["pointer_mc"] as MovieClip;
            this.m_pointerMc.visible = true;
         }
         if(m_window.hasOwnProperty("meter_mc"))
         {
            this.m_meterMc = m_window["meter_mc"] as MovieClip;
            this.m_meterMc.visible = true;
            this.updateProgressBar(this.m_meterMc);
         }
         if(m_window.hasOwnProperty("idle_ani_mc"))
         {
            this.m_idleNPC = m_window["idle_ani_mc"] as MovieClip;
            this.playIdleNPCAnimation();
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            this.m_icon_mc = m_window["icon_mc"] as MovieClip;
            this.m_icon_mc.visible = true;
            this.m_icon_mc.gotoAndPlay(this.manager.getKeyBuildingLevel() + 1);
         }
         if(m_window.hasOwnProperty("point1_tf"))
         {
            m_window["point1_tf"].visible = true;
            m_window["point1_tf"].text = "220";
         }
         if(m_window.hasOwnProperty("point2_tf"))
         {
            m_window["point2_tf"].visible = true;
            m_window["point2_tf"].text = "450";
         }
         if(m_window.hasOwnProperty("point3_tf"))
         {
            m_window["point3_tf"].visible = true;
            m_window["point3_tf"].text = "650";
         }
         if(m_window.hasOwnProperty("point4_tf"))
         {
            m_window["point4_tf"].visible = true;
            m_window["point4_tf"].text = "860";
         }
         if(m_window.hasOwnProperty("point5_tf"))
         {
            m_window["point5_tf"].visible = true;
            m_window["point5_tf"].text = "1100";
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = "Harvest your grand prize everyday for goodies till April 21!";
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            m_window["body2_tf"].visible = true;
            m_window["body2_tf"].text = "Harvest your grand prize everyday for goodies till April 21!";
         }
         if(m_window.hasOwnProperty(this.BACK_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.BACK_BT],"AWESOME!",onClose));
         }
         if(m_window.hasOwnProperty("inform_ani_mc"))
         {
            this.m_informNPC = m_window["inform_ani_mc"] as MovieClip;
         }
         for(var i:int = 0; i < 6; i++)
         {
            if(m_window.hasOwnProperty("icon" + i.toString() + "_mc"))
            {
               this.m_iconMCArray[i] = m_window["icon" + i.toString() + "_mc"] as MovieClip;
               this.m_iconMCArray[i].visible = true;
               this.m_iconMcWidgetArray[i] = new ZwFrame(m_window["icon" + i.toString() + "_mc"]);
               this.m_iconMcWidgetArray[i].registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver(i));
               this.m_iconMcWidgetArray[i].registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut(i));
               this.m_iconGlowMCArray[i] = this.m_iconMCArray[i]["glow_mc"] as MovieClip;
            }
         }
         var level:int = this.manager.getKeyBuildingLevel();
         if(level > 4)
         {
            level = 4;
         }
         this.m_iconGlowMCArray[level].visible = true;
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.FINALREWARD_WELCOME_SEEN_FLAG);
         }
      }
      
      public function onMouseOver(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_icon_mc.gotoAndPlay(slotIndex + 1);
            m_iconGlowMCArray[slotIndex].visible = true;
            var level:* = manager.getKeyBuildingLevel();
            level = 5;
            if(level)
            {
               level--;
            }
            m_iconGlowMCArray[level + 1].visible = false;
         };
      }
      
      public function onMouseOut(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_icon_mc.gotoAndPlay(manager.getKeyBuildingLevel() + 1);
            m_iconGlowMCArray[slotIndex].visible = false;
            var level:* = manager.getKeyBuildingLevel();
            level = 5;
            if(level)
            {
               level--;
            }
            m_iconGlowMCArray[level + 1].visible = true;
         };
      }
      
      private function updateHighLighter() : void
      {
         var activeRewardIndex:int = 1;
         if(activeRewardIndex >= 0)
         {
            this.m_highLighterMCArray[activeRewardIndex].visible = true;
            this.m_progressLevelArray_mc[activeRewardIndex].gotoAndStop(2);
            this.m_rewardMCArray[activeRewardIndex].visible = true;
            this.m_rewardMCArray[activeRewardIndex].play();
         }
      }
      
      private function get manager() : IrelandInnovationManager
      {
         return IrelandInnovationManager.getInstance();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.m_knowMoreMC.visible = true;
      }
      
      override public function close() : void
      {
         if(this.manager.m_mainWindow)
         {
            this.manager.m_mainWindow.untintWindow();
            this.manager.m_mainWindow.enableInput = true;
         }
         super.close();
      }
      
      private function updateProgressBar(meter_mc:MovieClip) : void
      {
         meter_mc.visible = true;
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints > this.MAX_POINT)
         {
            dayPoints = this.MAX_POINT;
         }
         var barWidth:Number = dayPoints * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(meter_mc.bar_fill_mc)
         {
            if(dayPoints == 0)
            {
               (meter_mc.bar_fill_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(meter_mc.bar_fill_mc,2,{"width":barWidth});
            }
         }
         if(Boolean(this.m_pointerMc) && Boolean(this.m_pointerMc[this.POINTS_TF]))
         {
            (this.m_pointerMc[this.POINTS_TF] as TextField).text = int(dayPoints).toString();
         }
      }
      
      private function onKnowMoreMcClose(e:Event = null) : void
      {
         this.m_knowMoreMC.visible = false;
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

