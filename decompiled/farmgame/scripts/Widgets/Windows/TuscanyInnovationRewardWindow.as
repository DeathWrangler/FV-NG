package Widgets.Windows
{
   import Managers.TuscanyInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TuscanyInnovationRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "info1_tf";
      
      private var m_featureName:String;
      
      private var m_highLighterMCArray:Array;
      
      private var m_progressLevelArray_mc:Array;
      
      private var m_progressLevelArray_tf:Array;
      
      public const ProgressLevelTextArray:Array = ["Good","Superb","Classic"];
      
      private const BACK_BT:String = "back_bt";
      
      private var m_knowMoreMC:MovieClip;
      
      private var m_knowMoreCloseBt:FarmButton;
      
      private var m_previewMCArray:Array = [];
      
      private var m_rewardMCArray:Array = [];
      
      private var m_knowMoreBt:FarmAnimatedButton;
      
      public function TuscanyInnovationRewardWindow(featureName:String, assetPath:String = "")
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
            m_window[this.TITLE_TF].text = "Bonus Rewards";
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = "Maintain your Grape Stomping streak and win any one of these Bonus Wineries!";
         }
         if(m_window.hasOwnProperty(this.BACK_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.BACK_BT],"Okay!",onClose));
         }
         this.m_highLighterMCArray = [];
         this.m_progressLevelArray_mc = [];
         this.m_progressLevelArray_tf = [];
         for(var i:int = 0; i < 3; i++)
         {
            this.m_highLighterMCArray[i] = m_window["highlighter" + (i + 1).toString() + "_mc"] as MovieClip;
            this.m_highLighterMCArray[i].visible = false;
            this.m_progressLevelArray_mc[i] = m_window["level" + (i + 1).toString() + "_mc"] as MovieClip;
            this.m_progressLevelArray_mc[i].visible = true;
            this.m_progressLevelArray_mc[i].gotoAndStop(1);
            this.m_progressLevelArray_tf[i] = new ZwTextField(this.m_progressLevelArray_mc[i]["level_tf"],this.ProgressLevelTextArray[i]);
            if(m_window.hasOwnProperty("hitArea" + (i + 1).toString() + "_mc"))
            {
               addWidget(this.m_previewMCArray[i] = new ZwFrame(m_window["hitArea" + (i + 1).toString() + "_mc"]),true);
               if(this.manager.overAllProgressLevel() != i)
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
      
      private function get manager() : TuscanyInnovationManager
      {
         return TuscanyInnovationManager.getInstance();
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
   }
}

