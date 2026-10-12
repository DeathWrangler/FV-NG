package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.AFInnovationManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AFInnovationPlaySoloWindow extends FarmWindowWithTutorial
   {
      
      public static const ICON_SIZE:int = 100;
      
      private static const AF_INNOVATION_FEATURE_SEEN_FLAG:String = "AFInnovation_Tutorial";
      
      private static const NUM_TUTORIAL_SCENES:int = 6;
      
      protected var m_featureName:String;
      
      private const ICON_MC:String = "icon_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const NPC_MC:String = "npc_mc";
      
      private const OKAY_BT:String = "okay_bt";
      
      private const PROFILE1_MC:String = "profile1_mc";
      
      private const PROFILE2_MC:String = "profile2_mc";
      
      private const COUNTER1_MC:String = "counter1_mc";
      
      private const COUNTER2_MC:String = "counter2_mc";
      
      private const SLOT_MC:String = "slots_mc";
      
      private const SHOW_MC:String = "show_mc";
      
      private const OVERLAY_MC:String = "overlay_mc";
      
      private const MESSAGE_MC:String = "message_mc";
      
      private const SHOW_TF:String = "show_tf";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const OVERLAY1_TF:String = "overlay1_tf";
      
      private const OVERLAY2_TF:String = "overlay2_tf";
      
      private var m_counter1:MovieClip;
      
      private var m_counter2:MovieClip;
      
      private var m_message_mc:MovieClip;
      
      private var m_overlay_mc:MovieClip;
      
      private var m_slots_mc:MovieClip;
      
      private var m_profile1_mc:MovieClip;
      
      private var m_profile2_mc:MovieClip;
      
      private var m_player1_icon:FarmIcon;
      
      private var m_slotsArray:Array = new Array();
      
      private var m_player1CounterArray:Array = new Array();
      
      private var m_player2CounterArray:Array = new Array();
      
      private var m_turnCount:int = 0;
      
      private var m_postGame_mc:MovieClip;
      
      private var m_overlayOkay_button:FarmAnimatedButton;
      
      private var m_postGameOkay_button:FarmAnimatedButton;
      
      private var m_npc_mc:MovieClip;
      
      private var m_timer:Timer;
      
      private var m_timerText:ZwTextField;
      
      private var m_currentTimeCount:Number;
      
      private var m_counter1_tf:ZwTextField;
      
      private var m_revealedTilesCountArray:Array = new Array(0,0,0);
      
      private var m_showTutorial:Boolean;
      
      private var m_bodyText:ZwTextField;
      
      private var m_highlight1_mc:MovieClip;
      
      private const HIGHLIGHT1_MC:String = "highlight1_mc";
      
      private const COLOR1_TF:String = "color1_tf";
      
      private const COLOR2_TF:String = "color2_tf";
      
      private const COLOR3_TF:String = "color3_tf";
      
      private const INDICATOR_TF:String = "indicator_tf";
      
      private const SOLO_TF:String = "solo_tf";
      
      private const COUNTER_TF:String = "counter_tf";
      
      public function AFInnovationPlaySoloWindow(featureName:String, assetPath:String, showTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorial = showTutorial;
         Global.player.setSeenFlag(AF_INNOVATION_FEATURE_SEEN_FLAG);
         super(this.m_featureName,assetPath,NUM_TUTORIAL_SCENES,true,true,showTutorial);
      }
      
      override protected function postLoadComplete() : void
      {
         var iconUrl:String = null;
         var counterIndex:int = 0;
         var counter2Index:int = 0;
         var i:int = 0;
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_Title")));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(this.m_bodyText = new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_body")));
            this.m_bodyText.visible = false;
         }
         if(m_window.hasOwnProperty(this.COLOR1_TF))
         {
            addWidget(new ZwTextField(m_window[this.COLOR1_TF],"Very close"));
         }
         if(m_window.hasOwnProperty(this.COLOR2_TF))
         {
            addWidget(new ZwTextField(m_window[this.COLOR2_TF],"Close"));
         }
         if(m_window.hasOwnProperty(this.COLOR3_TF))
         {
            addWidget(new ZwTextField(m_window[this.COLOR3_TF],"Far"));
         }
         if(m_window.hasOwnProperty(this.INDICATOR_TF))
         {
            addWidget(new ZwTextField(m_window[this.INDICATOR_TF],"Clues"));
         }
         if(m_window.hasOwnProperty(this.SOLO_TF))
         {
            addWidget(new ZwTextField(m_window[this.SOLO_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_SoloGameMessageText")));
         }
         if(m_window.hasOwnProperty(this.TIMER_TF))
         {
            addWidget(this.m_timerText = new ZwTextField(m_window[this.TIMER_TF],""));
         }
         if(m_window.hasOwnProperty(this.COUNTER1_MC))
         {
            this.m_counter1 = m_window[this.COUNTER1_MC] as MovieClip;
            this.m_counter1.visible = true;
            for(counterIndex = 0; counterIndex < this.manager.turnsInSoloMode; counterIndex++)
            {
               this.m_player1CounterArray[counterIndex] = this.m_counter1["count_mc_" + counterIndex.toString()] as MovieClip;
               (this.m_player1CounterArray[counterIndex] as MovieClip).gotoAndStop(1);
            }
            if(this.m_counter1.hasOwnProperty(this.COUNTER_TF))
            {
               this.m_counter1_tf = new ZwTextField(this.m_counter1[this.COUNTER_TF],"Your turns");
            }
         }
         if(m_window.hasOwnProperty(this.COUNTER2_MC))
         {
            this.m_counter2 = m_window[this.COUNTER2_MC] as MovieClip;
            this.m_counter2.visible = false;
            for(counter2Index = 0; counter2Index < this.manager.turnsInSoloMode; counter2Index++)
            {
               this.m_player2CounterArray[counter2Index] = this.m_counter2["count_mc_" + counter2Index.toString()] as MovieClip;
               (this.m_player2CounterArray[counter2Index] as MovieClip).gotoAndStop(1);
            }
         }
         if(m_window.hasOwnProperty(this.MESSAGE_MC))
         {
            this.m_message_mc = m_window[this.MESSAGE_MC] as MovieClip;
            this.m_message_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.NPC_MC))
         {
            this.m_npc_mc = m_window[this.NPC_MC] as MovieClip;
            this.m_npc_mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.OVERLAY_MC))
         {
            this.m_overlay_mc = m_window[this.OVERLAY_MC] as MovieClip;
            if(this.m_showTutorial)
            {
               this.m_overlay_mc.visible = false;
            }
            else
            {
               this.m_overlay_mc.visible = true;
            }
            this.m_overlay_mc[this.OVERLAY1_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_FindSoloGameText1");
            this.m_overlay_mc[this.OVERLAY2_TF].text = "";
            this.m_overlayOkay_button = new FarmAnimatedButton(this.m_overlay_mc[this.OKAY_BT],null);
            this.m_overlayOkay_button.visible = false;
         }
         if(m_window.hasOwnProperty(this.SHOW_MC))
         {
            this.m_postGame_mc = m_window[this.SHOW_MC] as MovieClip;
            this.m_postGame_mc.visible = false;
            this.m_postGameOkay_button = new FarmAnimatedButton(this.m_postGame_mc[this.OKAY_BT],null);
            this.m_postGameOkay_button.visible = false;
         }
         if(m_window.hasOwnProperty(this.SLOT_MC))
         {
            this.m_slots_mc = m_window[this.SLOT_MC] as MovieClip;
            this.m_slots_mc.visible = true;
            for(i = 0; i < 100; i++)
            {
               this.m_slotsArray[i] = new FarmButton(this.m_slots_mc["slot_" + i.toString() + "_mc"],null);
               var _temp_3:* = this.m_slotsArray[i];
               MouseEvent.CLICK;
               _temp_3.callback = this.makeClickListener(i);
               (this.m_slotsArray[i].element as MovieClip).gotoAndStop(1);
            }
         }
         if(m_window.hasOwnProperty(this.PROFILE1_MC))
         {
            this.m_profile1_mc = m_window[this.PROFILE1_MC] as MovieClip;
            if(this.m_profile1_mc)
            {
               this.m_profile1_mc.visible = true;
               this.m_player1_icon = new FarmIcon(this.m_profile1_mc[this.ICON_MC]);
               this.m_player1_icon.setIconSize(ICON_SIZE,ICON_SIZE);
               this.m_player1_icon.setSmoothing(true);
               iconUrl = Global.player.picture;
               this.m_player1_icon.loadIcon(iconUrl);
               this.m_profile1_mc["name_tf"].text = Global.player.firstName;
            }
         }
         if(m_window.hasOwnProperty(this.PROFILE2_MC))
         {
            this.m_profile2_mc = m_window[this.PROFILE2_MC] as MovieClip;
            if(this.m_profile2_mc)
            {
               this.m_profile2_mc.visible = false;
            }
         }
         super.postLoadComplete();
         if(this.m_showTutorial)
         {
            showTutorial();
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      private function enableGridButtons() : void
      {
         for(var i:int = 0; i < 100; i++)
         {
            this.m_slotsArray[i].enabled = true;
         }
      }
      
      private function disableGridButtons() : void
      {
         for(var i:int = 0; i < 100; i++)
         {
            this.m_slotsArray[i].enabled = false;
         }
      }
      
      private function get manager() : AFInnovationManager
      {
         return AFInnovationManager.getInstance(this.m_featureName);
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      public function makeClickListener(i:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            FarmStatsManager.count("Hand_of_Destiny_Game","Move_Duration","","solo","","",m_currentTimeCount);
            var y:* = i % 10;
            var x:* = (i - y) / 10;
            var colorState:* = manager.determineCellColor(x,y);
            ++m_revealedTilesCountArray[colorState - 2];
            if(m_slotsArray[i])
            {
               m_slotsArray[i].enabled = false;
               m_slotsArray[i].callback = null;
               (m_slotsArray[i].element as MovieClip).gotoAndStop(colorState);
               m_player1CounterArray[m_turnCount].gotoAndStop(3);
               if(colorState == 5)
               {
                  m_timerText.visible = false;
                  finishGameWithReward();
                  FarmStatsManager.count("Hand_of_Destiny_Game","Reward_Clicked","","solo","","",m_turnCount + 1);
               }
               else
               {
                  ++m_turnCount;
                  goToNextStep();
               }
            }
         };
      }
      
      public function finishGameWithReward() : void
      {
         FarmStatsManager.count("Hand_of_Destiny_Game","Reward_None",this.m_revealedTilesCountArray[0],this.m_revealedTilesCountArray[1],"","",this.m_revealedTilesCountArray[2]);
         this.disableGridButtons();
         this.stopTurnResponseTimer();
         this.m_postGame_mc.visible = true;
         this.m_postGameOkay_button.visible = true;
         this.m_postGame_mc[this.SHOW_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWonTitle");
         this.m_postGameOkay_button.element["generic_tf"].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWonButtonText");
         this.m_postGameOkay_button.callback = this.manager.finishGameWithReward;
      }
      
      public function startGame() : void
      {
         this.enableGridButtons();
         if(this.manager.shouldDeductRunes == true)
         {
            this.manager.deductRunesForGame();
         }
         this.m_overlay_mc.visible = false;
         this.m_player1CounterArray[0].gotoAndStop(2);
         this.startTurnResponseTimer();
         var rewardIndex:Number = this.manager.prizeX + this.manager.prizeY * 10;
         FarmStatsManager.count("Hand_of_Destiny_Game","Gameboard_creation","solo",rewardIndex.toString(),"","",this.manager.getConsumableCount());
      }
      
      public function goToNextStep() : void
      {
         this.stopTurnResponseTimer();
         if(this.m_turnCount == this.manager.turnsInSoloMode)
         {
            FarmStatsManager.count("Hand_of_Destiny_Game","Reward_None",this.m_revealedTilesCountArray[0],this.m_revealedTilesCountArray[1],"","",this.m_revealedTilesCountArray[2]);
            this.m_overlay_mc.visible = true;
            this.m_overlayOkay_button.visible = true;
            this.m_overlay_mc[this.OVERLAY1_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_GameLostText1");
            this.m_overlay_mc[this.OVERLAY2_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_GameLostText2");
            this.m_overlayOkay_button.callback = this.ShowRewardPosition;
            this.disableGridButtons();
            this.m_timerText.visible = false;
            this.manager.finishGameWithOutReward();
         }
         else
         {
            this.startTurnResponseTimer();
            this.m_player1CounterArray[this.m_turnCount].gotoAndStop(2);
         }
      }
      
      public function ShowRewardPosition(event:Event) : void
      {
         this.m_overlay_mc.visible = false;
         this.m_postGame_mc.visible = true;
         this.m_postGameOkay_button.visible = true;
         this.m_postGame_mc[this.SHOW_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_RevealPrizeText1");
         this.m_postGameOkay_button.element["generic_tf"].text = "Oh!";
         this.m_postGameOkay_button.callback = this.closeWindow;
         var prizeSlotIndex:Number = this.manager.prizeX * 10 + this.manager.prizeY;
         if(prizeSlotIndex >= 0 && prizeSlotIndex < 100 && Boolean(this.m_slotsArray[prizeSlotIndex]))
         {
            (this.m_slotsArray[prizeSlotIndex].element as MovieClip).gotoAndStop(5);
         }
      }
      
      public function closeWindow(event:Event) : void
      {
         this.close();
         this.manager.showMainUI();
      }
      
      override public function close() : void
      {
         this.m_timerText = null;
         this.stopTurnResponseTimer();
         super.close();
      }
      
      public function stopTurnResponseTimer() : void
      {
         if(this.m_timer)
         {
            this.m_currentTimeCount = 0;
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshTimerText();
      }
      
      private function startTurnResponseTimer() : void
      {
         this.m_currentTimeCount = 0;
         this.m_timer = new Timer(FarmGameUtil.NUM_MSECS_IN_SECOND);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function refreshTimerText() : void
      {
         var timerStr:String = null;
         if(this.m_currentTimeCount > this.manager.DEFAULT_WAITING_PERIOD)
         {
            this.m_player1CounterArray[this.m_turnCount].gotoAndStop(4);
            ++this.m_turnCount;
            this.goToNextStep();
            FarmStatsManager.count("Hand_of_Destiny_Game","Missed_Move","","solo","","",this.m_turnCount);
         }
         else if(this.m_timerText)
         {
            timerStr = (this.manager.DEFAULT_WAITING_PERIOD - this.m_currentTimeCount).toString();
            this.m_timerText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_SoloGameTimerText",{"timer":timerStr});
            this.m_currentTimeCount += 1;
            this.m_timerText.visible = true;
         }
      }
   }
}

