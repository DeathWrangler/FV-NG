package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.MatchMaking.MatchMakingManager;
   import Classes.util.ZLocUtils;
   import Managers.AFInnovationManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Timer;
   
   public class AFInnovationP2PGameWindow extends FarmWindowWithTutorial
   {
      
      private static const AF_INNOVATION_FEATURE_SEEN_FLAG:String = "AFInnovation_Tutorial";
      
      public static const ICON_SIZE:int = 100;
      
      private static const NUM_TUTORIAL_SCENES:int = 6;
      
      private const STATE_GET_CELL:int = 0;
      
      private const STATE_SET_CELL:int = 1;
      
      private const DEFAULT_CONNECTION_WAITING_PERIOD:Number = 30000;
      
      private const ICON_MC:String = "icon_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const NPC_MC:String = "npc_mc";
      
      private const PROFILE1_MC:String = "profile1_mc";
      
      private const PROFILE2_MC:String = "profile2_mc";
      
      private const COUNTER1_MC:String = "counter1_mc";
      
      private const COUNTER2_MC:String = "counter2_mc";
      
      private const SLOT_MC:String = "slots_mc";
      
      private const SHOW_MC:String = "show_mc";
      
      private const OVERLAY_MC:String = "overlay_mc";
      
      private const CONNECT_MC:String = "connect_mc";
      
      private const MESSAGE1_MC:String = "message1_mc";
      
      private const MESSAGE2_MC:String = "message2_mc";
      
      private const HIGHLIGHT1_MC:String = "highlight1_mc";
      
      private const HIGHLIGHT2_MC:String = "highlight2_mc";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const COLOR1_TF:String = "color1_tf";
      
      private const COLOR2_TF:String = "color2_tf";
      
      private const COLOR3_TF:String = "color3_tf";
      
      private const INDICATOR_TF:String = "indicator_tf";
      
      private const COUNTER_TF:String = "counter_tf";
      
      private const SEND_MC:String = "send_mc";
      
      private const OVERLAY1_TF:String = "overlay1_tf";
      
      private const OVERLAY2_TF:String = "overlay2_tf";
      
      private const SOLO_TF:String = "solo_tf";
      
      protected var m_featureName:String;
      
      private var m_counter1:MovieClip;
      
      private var m_counter2:MovieClip;
      
      private var m_message1_mc:MovieClip;
      
      private var m_message2_mc:MovieClip;
      
      private var m_highlight1_mc:MovieClip;
      
      private var m_highlight2_mc:MovieClip;
      
      private var m_overlay_mc:MovieClip;
      
      private var m_slots_mc:MovieClip;
      
      private var m_profile1_mc:MovieClip;
      
      private var m_profile2_mc:MovieClip;
      
      private var m_player1_icon:FarmIcon;
      
      private var m_player2_icon:FarmIcon;
      
      private var m_player2_icon_url:String;
      
      private var m_playerStatus:Number;
      
      private var m_playerTurnCount:int = 0;
      
      private var m_postGame_mc:MovieClip;
      
      private var m_overlayOkay_button:FarmAnimatedTextButton;
      
      private var m_overlayText1:FarmTextField;
      
      private var m_overlayText2:FarmTextField;
      
      private var m_postGameOkay_button:FarmAnimatedButton;
      
      private var m_playerState:int = 0;
      
      private var m_gameId:String;
      
      private var m_player2UID:String;
      
      private var m_totalTurnCount:int;
      
      private var m_npc_mc:MovieClip;
      
      private var m_connectionTimer:Timer;
      
      private const DUMMY_SLOT_INDEX:int = -1;
      
      private var m_timer:Timer;
      
      private var m_timerText:ZwTextField;
      
      private var m_currentTimeCount:Number;
      
      private var m_slotsArray:Array = new Array();
      
      private var m_player1CounterArray:Array = new Array();
      
      private var m_player2CounterArray:Array = new Array();
      
      private var m_earlyconnectionTimer:Timer;
      
      private var m_send_mc:MovieClip;
      
      private var m_sendHello_button:FarmAnimatedButton;
      
      private var m_sendClap_button:FarmAnimatedButton;
      
      private var m_sendThumbsUp_button:FarmAnimatedButton;
      
      private var m_sendPeace_button:FarmAnimatedButton;
      
      private var m_player2FirstName:String;
      
      private var m_counter1_tf:ZwTextField;
      
      private var m_counter2_tf:ZwTextField;
      
      private var m_gameStarted:Boolean = false;
      
      private var m_revealedTilesCountArray:Array = new Array(0,0,0);
      
      private var m_overlayText1String:String;
      
      private var m_overlayText2String:String;
      
      private var m_overlayButtonText:String;
      
      private var m_overlayButtonCallback:Function;
      
      private var m_showTutorial:Boolean;
      
      private var m_bodyText:ZwTextField;
      
      private var m_solo_tf:ZwTextField;
      
      private var m_videoButton:FarmAnimatedTextButton;
      
      private var m_gameFinished:Boolean = false;
      
      public function AFInnovationP2PGameWindow(featureName:String, assetPath:String, showTutorial:Boolean = false)
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
         if(m_window.hasOwnProperty(this.TIMER_TF))
         {
            addWidget(this.m_timerText = new ZwTextField(m_window[this.TIMER_TF],Global.player.firstName + " : "));
         }
         if(m_window.hasOwnProperty(this.COLOR1_TF))
         {
            addWidget(new ZwTextField(m_window[this.COLOR1_TF],"Very close"));
         }
         if(m_window.hasOwnProperty(this.SOLO_TF))
         {
            addWidget(this.m_solo_tf = new ZwTextField(m_window[this.SOLO_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_SoloGameMessageText")));
            this.m_solo_tf.visible = false;
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
            this.m_counter2.visible = true;
            for(counter2Index = 0; counter2Index < this.manager.turnsInSoloMode; counter2Index++)
            {
               this.m_player2CounterArray[counter2Index] = this.m_counter2["count_mc_" + counter2Index.toString()] as MovieClip;
               (this.m_player2CounterArray[counter2Index] as MovieClip).gotoAndStop(1);
            }
            if(this.m_counter2.hasOwnProperty(this.COUNTER_TF))
            {
               addWidget(this.m_counter2_tf = new ZwTextField(this.m_counter2[this.COUNTER_TF],"Player turns"));
            }
         }
         if(m_window.hasOwnProperty(this.MESSAGE1_MC))
         {
            this.m_message1_mc = m_window[this.MESSAGE1_MC] as MovieClip;
            this.m_message1_mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.MESSAGE2_MC))
         {
            this.m_message2_mc = m_window[this.MESSAGE2_MC] as MovieClip;
            this.m_message2_mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.HIGHLIGHT1_MC))
         {
            this.m_highlight1_mc = m_window[this.HIGHLIGHT1_MC] as MovieClip;
            this.m_highlight1_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.HIGHLIGHT2_MC))
         {
            this.m_highlight2_mc = m_window[this.HIGHLIGHT2_MC] as MovieClip;
            this.m_highlight2_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.SEND_MC))
         {
            this.m_send_mc = m_window[this.SEND_MC] as MovieClip;
            this.m_send_mc.visible = true;
            this.m_send_mc["send_tf"].text = "Send message";
            this.m_sendHello_button = new FarmAnimatedButton(this.m_send_mc["send1_bt"],this.onClickHelloButton);
            this.m_sendHello_button.visible = true;
            this.m_sendClap_button = new FarmAnimatedButton(this.m_send_mc["send2_bt"],this.onClickClapButton);
            this.m_sendClap_button.visible = true;
            this.m_sendThumbsUp_button = new FarmAnimatedButton(this.m_send_mc["send3_bt"],this.onClickThumbsUpButton);
            this.m_sendThumbsUp_button.visible = true;
            this.m_sendPeace_button = new FarmAnimatedButton(this.m_send_mc["send4_bt"],this.onClickPeaceButton);
            this.m_sendPeace_button.visible = true;
         }
         if(m_window.hasOwnProperty(this.CONNECT_MC))
         {
            this.m_overlay_mc = m_window[this.CONNECT_MC] as MovieClip;
            this.m_overlay_mc.visible = true;
            if(this.m_showTutorial)
            {
               this.m_overlay_mc.visible = false;
            }
            else
            {
               this.m_overlay_mc.visible = true;
            }
            this.m_overlayText1 = new FarmTextField(this.m_overlay_mc[this.OVERLAY1_TF]);
            this.m_overlayText2 = new FarmTextField(this.m_overlay_mc[this.OVERLAY2_TF]);
            addWidget(this.m_overlayOkay_button = new FarmAnimatedTextButton(this.m_overlay_mc["okay_bt"],null),false);
         }
         if(m_window.hasOwnProperty(this.SHOW_MC))
         {
            this.m_postGame_mc = m_window[this.SHOW_MC] as MovieClip;
            this.m_postGame_mc.visible = false;
            this.m_postGameOkay_button = new FarmAnimatedButton(this.m_postGame_mc["okay_bt"],null);
            this.m_postGameOkay_button.visible = false;
         }
         if(m_window.hasOwnProperty(this.SLOT_MC))
         {
            this.m_slots_mc = m_window[this.SLOT_MC] as MovieClip;
            this.m_slots_mc.visible = true;
            for(i = 0; i < 100; i++)
            {
               this.m_slotsArray[i] = new FarmButton(this.m_slots_mc["slot_" + i.toString() + "_mc"],null);
               var _temp_6:* = this.m_slotsArray[i];
               MouseEvent.CLICK;
               _temp_6.callback = this.makeClickListener(i);
               this.m_slotsArray[i].enabled = false;
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
               this.m_profile2_mc.visible = true;
               this.m_player2_icon = new FarmIcon(this.m_profile2_mc[this.ICON_MC]);
               this.m_player2_icon.setIconSize(ICON_SIZE,ICON_SIZE);
               this.m_player2_icon.setSmoothing(true);
               if(this.m_player2_icon_url)
               {
                  this.m_player2_icon.loadIcon(this.m_player2_icon_url);
               }
            }
         }
         if(m_window.hasOwnProperty(this.NPC_MC))
         {
            this.m_npc_mc = m_window[this.NPC_MC] as MovieClip;
            this.m_npc_mc.visible = false;
         }
         super.postLoadComplete();
         if(m_window.tutorial_mc.video_bt)
         {
            m_tutorial.addWidget(this.m_videoButton = new FarmAnimatedTextButton(m_window.tutorial_mc.video_bt,"Watch Video",this.onWatchVideoButtonClick));
         }
         if(this.m_showTutorial)
         {
            this.showTutorial();
         }
         this.refreshOverlay();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      private function get manager() : AFInnovationManager
      {
         return AFInnovationManager.getInstance(this.m_featureName);
      }
      
      public function get gameStarted() : Boolean
      {
         return this.m_gameStarted;
      }
      
      public function onClickHelloButton(event:MouseEvent) : void
      {
         var gamestatus:String = this.m_gameFinished == true ? "end_game" : "between_game";
         FarmStatsManager.count("Hand_of_Destiny_Game","Emojis","hello",gamestatus,this.m_gameId);
         this.m_message1_mc.gotoAndStop(1);
         MatchMakingManager.getInstance().sendMessage("GameMessage" + this.m_gameId + ":" + "Hi",this.m_player2UID);
      }
      
      public function onClickClapButton(event:MouseEvent) : void
      {
         var gamestatus:String = this.m_gameFinished == true ? "end_game" : "between_game";
         FarmStatsManager.count("Hand_of_Destiny_Game","Emojis","clap",gamestatus,this.m_gameId);
         this.m_message1_mc.gotoAndStop(2);
         MatchMakingManager.getInstance().sendMessage("GameMessage" + this.m_gameId + ":" + "Clap",this.m_player2UID);
      }
      
      public function onClickThumbsUpButton(event:MouseEvent) : void
      {
         var gamestatus:String = this.m_gameFinished == true ? "end_game" : "between_game";
         FarmStatsManager.count("Hand_of_Destiny_Game","Emojis","thumbsup",gamestatus,this.m_gameId);
         this.m_message1_mc.gotoAndStop(3);
         MatchMakingManager.getInstance().sendMessage("GameMessage" + this.m_gameId + ":" + "ThumbsUp",this.m_player2UID);
      }
      
      public function onClickPeaceButton(event:MouseEvent) : void
      {
         var gamestatus:String = this.m_gameFinished == true ? "end_game" : "between_game";
         FarmStatsManager.count("Hand_of_Destiny_Game","Emojis","peace",gamestatus,this.m_gameId);
         this.m_message1_mc.gotoAndStop(4);
         MatchMakingManager.getInstance().sendMessage("GameMessage" + this.m_gameId + ":" + "Peace",this.m_player2UID);
      }
      
      override protected function release() : void
      {
         this.m_playerTurnCount = 0;
         this.m_totalTurnCount = 0;
         super.release();
      }
      
      public function makeClickListener(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            FarmStatsManager.count("Hand_of_Destiny_Game","Move_Duration","","p2p",m_gameId,"",m_currentTimeCount);
            var y:* = slotIndex % 10;
            var x:* = (slotIndex - y) / 10;
            var colorState:* = manager.determineCellColor(x,y);
            ++m_revealedTilesCountArray[colorState - 2];
            if(m_slotsArray[slotIndex])
            {
               m_slotsArray[slotIndex].enabled = false;
               m_slotsArray[slotIndex].callback = null;
               (m_slotsArray[slotIndex].element as MovieClip).gotoAndStop(colorState);
               m_player1CounterArray[m_playerTurnCount].gotoAndStop(3);
               if(colorState == 5)
               {
                  FarmStatsManager.count("Hand_of_Destiny_Game","Reward_Clicked","","p2p",m_gameId,"",m_playerTurnCount + 1);
                  m_gameFinished = true;
                  m_timerText.visible = false;
                  finishGameWithReward();
               }
               else
               {
                  ++m_playerTurnCount;
                  ++m_totalTurnCount;
                  goToNextStep();
               }
               MatchMakingManager.getInstance().sendMessage("GameMove" + m_gameId + ":" + slotIndex,m_player2UID);
            }
         };
      }
      
      public function finishGameWithReward() : void
      {
         FarmStatsManager.count("Hand_of_Destiny_Game","Reward",this.m_revealedTilesCountArray[0],this.m_revealedTilesCountArray[1],this.m_gameId,"",this.m_revealedTilesCountArray[2]);
         this.disableGridButtons();
         this.stopTurnResponseTimer();
         this.m_postGame_mc.visible = true;
         this.m_postGameOkay_button.visible = true;
         this.m_postGame_mc["show_tf"].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWonTitle");
         this.m_postGameOkay_button.element["generic_tf"].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWonButtonText");
         this.m_postGameOkay_button.callback = this.manager.finishGameWithReward;
      }
      
      public function initializeGameBoard(uid:String, gameId:String, playerStatus:int) : void
      {
         this.m_gameStarted = true;
         this.m_gameId = gameId;
         this.m_player2UID = uid;
         this.m_player2_icon_url = Global.getFBPicUrl(uid);
         if(this.m_player2_icon)
         {
            this.m_player2_icon.loadIcon(this.m_player2_icon_url);
         }
         this.m_playerStatus = playerStatus;
         if(this.m_playerStatus == AFInnovationManager.PRIMARY_USER)
         {
            this.manager.createP2PGameBoard(uid);
         }
         else
         {
            this.startEarlyConnectionTimer();
         }
         MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
      }
      
      public function exchangeFirstName() : void
      {
         MatchMakingManager.getInstance().sendMessage("FirstName" + this.m_gameId + ":" + Global.player.firstName,this.m_player2UID);
      }
      
      public function startEarlyConnectionTimer() : void
      {
         this.setOverlayText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameInitMessage1"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameInitMessage2"));
         this.m_earlyconnectionTimer = new Timer(this.DEFAULT_CONNECTION_WAITING_PERIOD,1);
         this.m_earlyconnectionTimer.addEventListener(TimerEvent.TIMER,this.onEarlyConnectionTimerExpired);
         this.m_earlyconnectionTimer.start();
      }
      
      public function onEarlyConnectionTimerExpired(event:TimerEvent) : void
      {
         this.stopEarlyConnectionTimer();
         this.m_overlay_mc.visible = false;
         this.m_overlay_mc = m_window[this.OVERLAY_MC] as MovieClip;
         this.m_overlayText1 = new FarmTextField(this.m_overlay_mc[this.OVERLAY1_TF]);
         this.m_overlayText2 = new FarmTextField(this.m_overlay_mc[this.OVERLAY2_TF]);
         this.m_overlayOkay_button = new FarmAnimatedTextButton(this.m_overlay_mc["okay_bt"],null);
         this.m_overlay_mc.visible = true;
         this.setOverlayText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_NetworkErrorMessage1"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_NetworkErrorMessage2"),"Okay");
         this.m_overlayOkay_button.callback = this.closeP2PAndOpenMainWindow;
      }
      
      private function stopEarlyConnectionTimer() : void
      {
         if(this.m_earlyconnectionTimer)
         {
            this.m_earlyconnectionTimer.stop();
            this.m_earlyconnectionTimer.removeEventListener(TimerEvent.TIMER,this.onEarlyConnectionTimerExpired);
         }
      }
      
      public function closeP2PAndOpenMainWindow(event:MouseEvent) : void
      {
         this.manager.closeP2PAndOpenMainWindow();
      }
      
      public function startGame() : void
      {
         if(this.manager.shouldDeductRunes == true)
         {
            this.manager.deductRunesForGame();
         }
         this.exchangeFirstName();
         this.m_totalTurnCount = 0;
         this.m_playerTurnCount = 0;
         this.m_overlay_mc.visible = false;
         this.m_overlay_mc = m_window[this.OVERLAY_MC] as MovieClip;
         this.m_overlayText1 = new FarmTextField(this.m_overlay_mc[this.OVERLAY1_TF]);
         this.m_overlayText2 = new FarmTextField(this.m_overlay_mc[this.OVERLAY2_TF]);
         this.m_overlayOkay_button = new FarmAnimatedTextButton(this.m_overlay_mc["okay_bt"],null);
         if(this.m_playerStatus == AFInnovationManager.PRIMARY_USER)
         {
            this.activatePlayerturn();
         }
         else
         {
            this.activatePlayer2Turn();
         }
         var initiator:String = this.manager.playerStatus == AFInnovationManager.PRIMARY_USER ? "player1" : "player2";
         var rewardIndex:Number = this.manager.prizeX + this.manager.prizeY * 10;
         FarmStatsManager.count("Hand_of_Destiny_Game","Gameboard_creation",initiator,rewardIndex.toString(),this.m_gameId,"",this.manager.getConsumableCount());
      }
      
      private function activatePlayerturn() : void
      {
         this.startTurnResponseTimer();
         this.m_playerState = this.STATE_SET_CELL;
         this.m_player1CounterArray[this.m_playerTurnCount].gotoAndStop(2);
         this.enableGridButtons();
         this.m_highlight1_mc.visible = true;
         this.m_highlight2_mc.visible = false;
      }
      
      private function activatePlayer2Turn() : void
      {
         this.startTurnResponseTimer();
         this.m_playerState = this.STATE_GET_CELL;
         this.m_player2CounterArray[this.m_totalTurnCount - this.m_playerTurnCount].gotoAndStop(2);
         this.disableGridButtons();
         this.m_highlight2_mc.visible = true;
         this.m_highlight1_mc.visible = false;
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
      
      public function refreshOverlay() : void
      {
         if(Boolean(this.m_overlayText1String) && Boolean(this.m_overlayText1))
         {
            this.m_overlayText1.text = this.m_overlayText1String;
         }
         if(Boolean(this.m_overlayText2String) && Boolean(this.m_overlayText2))
         {
            this.m_overlayText2.text = this.m_overlayText2String;
         }
         if(Boolean(this.m_overlayButtonText) && Boolean(this.m_overlayOkay_button))
         {
            this.m_overlayOkay_button.text = this.m_overlayButtonText;
         }
         if(this.m_overlayButtonCallback is Function && Boolean(this.m_overlayOkay_button))
         {
            this.m_overlayOkay_button.callback = this.m_overlayButtonCallback;
         }
      }
      
      public function setOverlayText(text1:String, text2:String, buttonText:String = null, callback:Function = null) : void
      {
         if(this.m_overlayText1)
         {
            this.m_overlayText1.text = text1;
         }
         if(this.m_overlayText2)
         {
            this.m_overlayText2.text = text2;
         }
         if(buttonText != null && buttonText != "")
         {
            if(this.m_overlayOkay_button)
            {
               this.m_overlayOkay_button.visible = true;
               this.m_overlayOkay_button.enabled = true;
               this.m_overlayOkay_button.text = buttonText;
            }
         }
         if(callback is Function)
         {
            if(this.m_overlayOkay_button)
            {
               this.m_overlayOkay_button.callback = callback;
            }
         }
         this.m_overlayText1String = text1;
         this.m_overlayText2String = text2;
         this.m_overlayButtonText = buttonText;
         this.m_overlayButtonCallback = callback;
      }
      
      public function goToNextStep() : void
      {
         this.stopTurnResponseTimer();
         if(this.m_totalTurnCount == this.manager.turnsInP2PMode)
         {
            this.m_gameFinished = true;
            FarmStatsManager.count("Hand_of_Destiny_Game","Reward_None",this.m_revealedTilesCountArray[0],this.m_revealedTilesCountArray[1],this.m_gameId,"",this.m_revealedTilesCountArray[2]);
            this.m_timerText.visible = false;
            this.m_timerText = null;
            this.m_overlay_mc.visible = true;
            this.m_overlayOkay_button.visible = true;
            this.setOverlayText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_GameLostText1"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_GameLostText2"),"Okay",this.ShowRewardPosition);
            this.disableGridButtons();
            this.manager.finishGameWithOutReward();
         }
         else if(this.m_playerState == this.STATE_SET_CELL)
         {
            this.activatePlayer2Turn();
            this.startP2ConnectionTimer();
         }
         else
         {
            this.activatePlayerturn();
         }
      }
      
      public function startP2ConnectionTimer() : void
      {
         this.m_connectionTimer = new Timer(this.DEFAULT_CONNECTION_WAITING_PERIOD,1);
         this.m_connectionTimer.addEventListener(TimerEvent.TIMER,this.onP2ConnectionTimerExpired);
         this.m_connectionTimer.start();
      }
      
      public function ShowRewardPosition(event:Event) : void
      {
         this.m_overlay_mc.visible = false;
         this.m_postGame_mc.visible = true;
         this.m_postGameOkay_button.visible = true;
         this.m_postGame_mc["show_tf"].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_RevealPrizeText1");
         this.m_postGameOkay_button.element["generic_tf"].text = "Oh!";
         this.m_postGameOkay_button.callback = this.closeWindowAndShowMainUI;
         var prizeSlotIndex:Number = this.manager.prizeX * 10 + this.manager.prizeY;
         if(prizeSlotIndex >= 0 && prizeSlotIndex < 100 && Boolean(this.m_slotsArray[prizeSlotIndex]))
         {
            (this.m_slotsArray[prizeSlotIndex].element as MovieClip).gotoAndStop(5);
         }
      }
      
      public function closeWindowAndShowMainUI(event:Event) : void
      {
         this.close();
         this.manager.showMainUI();
      }
      
      public function closeWindow(event:Event) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         this.m_timerText = null;
         MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
         this.stopTurnResponseTimer();
         this.m_gameStarted = false;
         super.close();
      }
      
      private function onchatMessageReceived(e:DataEvent) : void
      {
         var slotIndex:int = 0;
         var MessageSignature:String = null;
         var firstName:String = null;
         if(e.data.indexOf("GameMove" + this.m_gameId) != -1)
         {
            slotIndex = int(e.data.split(":")[1]);
            this.updatePlayer2Response(slotIndex);
            if(this.m_connectionTimer)
            {
               this.m_connectionTimer.stop();
               this.m_connectionTimer.removeEventListener(TimerEvent.TIMER,this.onP2ConnectionTimerExpired);
            }
         }
         else if(e.data.indexOf("GameMessage" + this.m_gameId) != -1)
         {
            MessageSignature = e.data.split(":")[1];
            switch(MessageSignature)
            {
               case "Hi":
                  this.m_message2_mc.gotoAndStop(1);
                  break;
               case "Clap":
                  this.m_message2_mc.gotoAndStop(2);
                  break;
               case "ThumbsUp":
                  this.m_message2_mc.gotoAndStop(3);
                  break;
               case "Peace":
                  this.m_message2_mc.gotoAndStop(4);
            }
         }
         else if(e.data.indexOf("GetGameBoard" + this.m_gameId) != -1)
         {
            this.stopEarlyConnectionTimer();
            this.manager.getP2PGameBoard(this.m_player2UID);
         }
         else if(e.data.indexOf("GameReady" + this.m_gameId) != -1)
         {
            this.stopEarlyConnectionTimer();
            this.startGame();
         }
         else if(e.data.indexOf("FirstName" + this.m_gameId) != -1)
         {
            firstName = e.data.split(":")[1];
            this.m_profile2_mc["name_tf"].text = firstName;
            this.m_player2FirstName = firstName;
            this.m_counter2_tf.text = this.m_player2FirstName + "\'s turns";
         }
      }
      
      private function updatePlayer2Response(slotIndex:int) : void
      {
         var y:int = 0;
         var x:int = 0;
         var colorState:int = 0;
         if(slotIndex >= 0 && slotIndex < 100)
         {
            this.m_player2CounterArray[this.m_totalTurnCount - this.m_playerTurnCount].gotoAndStop(3);
            ++this.m_totalTurnCount;
            y = slotIndex % 10;
            x = (slotIndex - y) / 10;
            colorState = this.manager.determineCellColor(x,y);
            ++this.m_revealedTilesCountArray[colorState - 2];
            if(this.m_slotsArray[slotIndex])
            {
               this.m_slotsArray[slotIndex].enabled = false;
               this.m_slotsArray[slotIndex].callback = null;
               (this.m_slotsArray[slotIndex].element as MovieClip).gotoAndStop(colorState);
               if(colorState == 5)
               {
                  this.m_timerText.visible = false;
                  this.m_gameFinished = true;
                  this.finishGameWithReward();
               }
               else
               {
                  this.goToNextStep();
               }
            }
         }
         else
         {
            this.m_player2CounterArray[this.m_totalTurnCount - this.m_playerTurnCount].gotoAndStop(4);
            ++this.m_totalTurnCount;
            this.goToNextStep();
         }
      }
      
      public function initiateGame() : void
      {
         if(this.m_playerStatus == AFInnovationManager.PRIMARY_USER)
         {
            MatchMakingManager.getInstance().sendMessage("GetGameBoard" + this.m_gameId,this.m_player2UID);
            this.startEarlyConnectionTimer();
         }
         else
         {
            MatchMakingManager.getInstance().sendMessage("GameReady" + this.m_gameId,this.m_player2UID);
            this.startGame();
         }
      }
      
      public function onP2ConnectionTimerExpired(event:TimerEvent) : void
      {
         if(this.m_connectionTimer)
         {
            this.m_connectionTimer.stop();
            this.m_connectionTimer.removeEventListener(TimerEvent.TIMER,this.onP2ConnectionTimerExpired);
         }
         this.switchToSoloMode();
      }
      
      public function switchToSoloMode() : void
      {
         this.m_counter2.visible = false;
         this.m_profile2_mc.visible = false;
         this.m_message1_mc.visible = false;
         this.m_message2_mc.visible = false;
         this.m_send_mc.visible = false;
         this.m_npc_mc.visible = true;
         this.m_timerText.visible = false;
         this.m_overlay_mc.visible = true;
         this.setOverlayText("We lost connection from other user.","The game will restart in Solo mode with solo rules.","Continue");
         this.m_overlayOkay_button.visible = true;
         this.m_overlayOkay_button.callback = this.startWithNewSoloGame;
      }
      
      public function startWithNewSoloGame(event:Event) : void
      {
         FarmStatsManager.count("Hand_of_Destiny_Game","switch_solo","","",this.m_gameId);
         this.close();
         this.manager.shouldDeductRunes = false;
         this.manager.openPlaySoloWindow();
      }
      
      private function refreshTimerText() : void
      {
         if(this.m_currentTimeCount > this.manager.DEFAULT_WAITING_PERIOD)
         {
            this.stopTurnResponseTimer();
            if(this.m_playerState == this.STATE_SET_CELL)
            {
               MatchMakingManager.getInstance().sendMessage("GameMove" + this.m_gameId + ":" + this.DUMMY_SLOT_INDEX.toString(),this.m_player2UID);
               this.m_player1CounterArray[this.m_playerTurnCount].gotoAndStop(4);
               ++this.m_playerTurnCount;
               ++this.m_totalTurnCount;
               this.goToNextStep();
               FarmStatsManager.count("Hand_of_Destiny_Game","Missed_Move","","p2p",this.m_gameId,"",this.m_playerTurnCount);
            }
            else if(this.m_timerText)
            {
               this.m_timerText.color = 16711680;
            }
         }
         else if(this.m_timerText)
         {
            if(this.m_playerState == this.STATE_SET_CELL)
            {
               this.m_timerText.text = Global.player.firstName + "\'s turn ends in " + (this.manager.DEFAULT_WAITING_PERIOD - this.m_currentTimeCount).toString() + " seconds";
            }
            else
            {
               this.m_timerText.text = this.m_player2FirstName + "\'s turn ends in " + (this.manager.DEFAULT_WAITING_PERIOD - this.m_currentTimeCount).toString() + " seconds";
            }
            this.m_currentTimeCount += 1;
            this.m_timerText.visible = true;
         }
      }
      
      private function startTurnResponseTimer() : void
      {
         this.m_currentTimeCount = 0;
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshTimerText();
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
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         super.onTutorialOkayButtonClick(event);
         tutorialButtonText = "Next";
         if(tutorialSceneNumber >= totalScenes)
         {
            this.close();
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = "Next";
      }
      
      public function onWatchVideoButtonClick(event:MouseEvent) : void
      {
         var gameTutorialURL:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameTutorialURL");
         navigateToURL(new URLRequest(gameTutorialURL),"_blank");
         this.close();
         this.manager.mainWindow.untintWindow();
         this.manager.mainWindow.enableInput = true;
      }
   }
}

