package Widgets.Windows
{
   import Classes.util.FarmGameUtil;
   import Managers.OrderBoard.FarmRunV5Manager;
   import Replay.ArrayUtils;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.FarmRunV5GameCardSlot;
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmRunV5GameWindow extends FarmWindow
   {
      
      private static const MAX_MATCHES:Number = 8;
      
      private static const NUM_CELLS:Number = 16;
      
      private static const COUNTDOWN_TOTAL:Number = 3;
      
      private static const POWER_UP_COST:Number = 1;
      
      private static const BOOST_IN_SECS:Number = 10;
      
      private static const TEN_MINUTES:Number = 10 * 60;
      
      private static const PROGRESS_BAR_WIDTH:Number = 100;
      
      private static const GAME_DURATION_IN_SECS:Number = 30;
      
      private static const REPLAY_DURATION_IN_SECS:Number = 10;
      
      private static const TIMER_DELAY_IN_MSECS:Number = 1000;
      
      private static const LAST_ROUND:Number = 2;
      
      private var m_loadedImagesCount:int = 0;
      
      private var m_timeRemaining:int;
      
      private var m_gameDuration:int;
      
      private var m_featureName:String;
      
      private var m_isReplay:Boolean;
      
      private var m_talkMc:MovieClip;
      
      private var m_talk_tf:ZwTextField;
      
      private var m_world1_mc:MovieClip;
      
      private var m_world2_mc:MovieClip;
      
      private var m_world3_mc:MovieClip;
      
      private var m_world4_mc:MovieClip;
      
      private var m_gameTimerFrame:ZwFrame;
      
      private var m_curGameTimeTextField:ZwTextField;
      
      private var m_curGameTimerBar:ZwFrame;
      
      private var m_gameboardSlotFrame:GenericSlotContainerFrame;
      
      private var m_lastClickedSlot:FarmRunV5GameCardSlot;
      
      private var m_countdownFrame:ZwFrame;
      
      private var m_countdownTF:ZwTextField;
      
      private var m_powerupsFrame:ZwFrame;
      
      private var m_powerupBT:ZwFrame;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_buyHeaderTF:ZwTextField;
      
      private var m_amountTF:ZwTextField;
      
      private var m_overlayMC:MovieClip;
      
      private var m_loaderMC:MovieClip;
      
      private var m_pairedList:Array;
      
      private var m_powerUpCount:int = 0;
      
      private var m_slotsData:Array = [];
      
      public function FarmRunV5GameWindow(featureName:String = "", assetUrl:String = null, isReplay:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_isReplay = isReplay;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.slotContainer_mc != null)
         {
            addWidget(this.m_gameboardSlotFrame = new GenericSlotContainerFrame(m_window.slotContainer_mc,FarmRunV5GameCardSlot,this.m_slotsData,this));
            this.m_gameboardSlotFrame.visible = true;
         }
         if(m_window.countdown_mc)
         {
            addWidget(this.m_countdownFrame = new ZwFrame(m_window.countdown_mc));
            if(this.m_countdownFrame.element.generic_tf)
            {
               this.m_countdownTF = new ZwTextField(this.m_countdownFrame.element.generic_tf,"3");
               this.m_countdownFrame.addWidget(this.m_countdownTF);
            }
            this.m_countdownFrame.visible = false;
         }
         if(m_window.powerups_mc)
         {
            addWidget(this.m_powerupsFrame = new ZwFrame(m_window.powerups_mc));
            if(this.m_powerupsFrame.element.powerup_bt)
            {
               this.m_powerupBT = new ZwFrame(this.m_powerupsFrame.element.powerup_bt);
               this.m_powerupsFrame.addWidget(this.m_powerupBT);
               if(this.m_powerupBT.element.buyAll_bt != null)
               {
                  this.m_buyButton = new FarmAnimatedCashButton(this.m_powerupBT.element.buyAll_bt,"buy","1",this.onBuyExtraTimeClick);
                  this.m_buyButton.visible = true;
                  this.m_powerupBT.addWidget(this.m_buyButton);
               }
               if(this.m_powerupBT.element.header_tf != null)
               {
                  this.m_buyHeaderTF = new ZwTextField(this.m_powerupBT.element.header_tf,"EXTRA TIME");
                  this.m_buyHeaderTF.visible = true;
                  this.m_powerupBT.addWidget(this.m_buyHeaderTF);
               }
               if(this.m_powerupBT.element.value_tf != null)
               {
                  this.m_amountTF = new ZwTextField(this.m_powerupBT.element.value_tf,"+10");
                  this.m_amountTF.visible = true;
                  this.m_powerupBT.addWidget(this.m_amountTF);
               }
               this.m_powerupBT.visible = true;
            }
            this.m_powerupsFrame.visible = true;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            if(Boolean(this.m_talkMc) && this.m_talkMc.hasOwnProperty("npc_tf"))
            {
               addWidget(this.m_talk_tf = new ZwTextField(this.m_talkMc["npc_tf"]));
               this.m_talk_tf.visible = true;
            }
            this.m_talkMc.visible = false;
         }
         if(m_window.round_tf)
         {
            addWidget(new ZwTextField(m_window.round_tf,"Round " + this.manager.miniGameActiveRound.toString())).visible = true;
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlayMC = m_window["overlay_mc"] as MovieClip;
            this.m_overlayMC.visible = true;
         }
         if(m_window.hasOwnProperty("loader_mc"))
         {
            this.m_loaderMC = m_window["loader_mc"] as MovieClip;
            this.m_loaderMC.visible = true;
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
         if(m_window.timer_mc != null)
         {
            addWidget(this.m_gameTimerFrame = new ZwFrame(m_window.timer_mc));
            if(this.m_gameTimerFrame.element.timer_tf != null)
            {
               this.m_curGameTimeTextField = new ZwTextField(this.m_gameTimerFrame.element.timer_tf,"30");
               this.m_gameTimerFrame.addWidget(this.m_curGameTimeTextField);
            }
            if(this.m_gameTimerFrame.element.meter_mc != null)
            {
               this.m_curGameTimerBar = new ZwFrame(this.m_gameTimerFrame.element.meter_mc);
               this.m_gameTimerFrame.addWidget(this.m_curGameTimerBar);
            }
            this.m_gameTimerFrame.visible = true;
         }
         this.buildGameData();
      }
      
      private function getCurrentTimeLeftAsString() : String
      {
         var timeArray:Array = FarmGameUtil.parseTimeLeft(this.m_timeRemaining);
         if(timeArray[2] > 0)
         {
            return timeArray[2] + ":" + FarmGameUtil.numberToStringPadZeros(timeArray[3]);
         }
         return timeArray[3];
      }
      
      private function getCurrentTimeLeftAsPercent() : Number
      {
         return this.m_timeRemaining / (this.m_gameDuration + BOOST_IN_SECS * this.m_powerUpCount) * 100;
      }
      
      private function updateTimeRemainingText() : void
      {
         if(Boolean(this.m_curGameTimeTextField) && Boolean(this.m_timeRemaining))
         {
            this.m_curGameTimeTextField.text = this.getCurrentTimeLeftAsString();
         }
      }
      
      private function buildGameData() : void
      {
         this.m_lastClickedSlot = null;
         this.m_pairedList = this.m_isReplay ? this.manager.activeMiniGamePairedSlots : [];
         this.m_gameDuration = this.m_isReplay ? int(REPLAY_DURATION_IN_SECS) : int(GAME_DURATION_IN_SECS);
         this.m_timeRemaining = this.m_gameDuration;
         if(!this.m_isReplay)
         {
            this.createRandomBoardSlotsData();
         }
         else
         {
            this.m_slotsData = this.manager.activeMiniGameLayout;
         }
         this.m_gameboardSlotFrame.setData(this.m_slotsData);
         this.updateTimeRemainingText();
         this.initSlots();
      }
      
      private function hideLoader() : void
      {
         this.m_overlayMC.visible = false;
         this.m_loaderMC.visible = false;
      }
      
      private function rewardExtraTime(seconds:uint) : void
      {
         this.m_timeRemaining += seconds;
         this.m_powerUpCount += 1;
      }
      
      private function get manager() : FarmRunV5Manager
      {
         return FarmRunV5Manager.getInstance(this.m_featureName);
      }
      
      private function incrementLoadedImageCount(onImageLoadingComplete:Function = null) : Function
      {
         return function():void
         {
            m_loadedImagesCount += 1;
            if(onImageLoadingComplete != null && m_loadedImagesCount == NUM_CELLS)
            {
               onImageLoadingComplete();
            }
         };
      }
      
      private function conditionallyDisableBuyTimeButton() : void
      {
         var canBuyTime:Boolean = this.m_gameDuration + BOOST_IN_SECS * this.m_powerUpCount < TEN_MINUTES;
         this.m_buyButton.enabled = canBuyTime;
         this.m_buyButton.applyGrayOut = !canBuyTime;
      }
      
      private function onBuyExtraTimeClick(event:Event = null) : void
      {
         this.manager.spendFarmCashService(FarmRunV5Manager.TYPE_MINI_GAME_TIME_BOOST,this.onFarmCashSpendSuccess);
      }
      
      private function onFarmCashSpendSuccess() : void
      {
         this.rewardExtraTime(BOOST_IN_SECS);
         this.conditionallyDisableBuyTimeButton();
         if(Boolean(this.m_curGameTimeTextField) && Boolean(this.m_curGameTimeTextField.element))
         {
            this.manager.displayPowerupButtonStatusText(this.m_curGameTimeTextField.element,BOOST_IN_SECS,"Seconds");
         }
         if(Boolean(this.m_buyButton) && Boolean(this.m_buyButton.parent) && Boolean(this.m_buyButton.parent.element))
         {
            this.manager.displayPowerupButtonStatusText(this.m_buyButton.parent.element,POWER_UP_COST,"Farm Cash",false);
         }
      }
      
      private function isGameOver() : Boolean
      {
         return this.m_timeRemaining == 0 || this.m_pairedList.length == MAX_MATCHES;
      }
      
      private function onGameTimerTick(event:Event) : void
      {
         if(this.isGameOver())
         {
            this.updateNPCTimeOverText();
            this.close();
            return;
         }
         if(this.m_timeRemaining-- == 10)
         {
            this.updateNPCBuyMoreTimeText();
         }
         this.updateTimeRemainingText();
         (this.m_curGameTimerBar.element as MovieClip).gotoAndStop(PROGRESS_BAR_WIDTH - Math.floor(this.getCurrentTimeLeftAsPercent()));
      }
      
      override public function close() : void
      {
         this.manager.stopTimer(this.onGameTimerTick);
         this.manager.saveGameProgress(this.m_slotsData,this.m_pairedList);
         super.close();
         this.manager.openScoreBoard(true,this.m_pairedList.length == MAX_MATCHES);
      }
      
      private function initSlots() : void
      {
         var i:int;
         var cells:Array = this.m_gameboardSlotFrame.slots;
         for(i = 0; i < cells.length; i++)
         {
            (cells[i] as FarmRunV5GameCardSlot).initSlot(this.incrementLoadedImageCount(function():void
            {
               hideLoader();
               if(!m_isReplay)
               {
                  startPeekCountDown();
                  toggleSlotsPreview();
               }
               else
               {
                  manager.startTimer(TIMER_DELAY_IN_MSECS,onGameTimerTick);
               }
            }));
         }
      }
      
      private function toggleSlotsPreview(show:Boolean = true) : void
      {
         var cells:Array = this.m_gameboardSlotFrame.slots;
         for(var i:int = 0; i < cells.length; i++)
         {
            if(show)
            {
               (cells[i] as FarmRunV5GameCardSlot).peek();
            }
            else
            {
               (cells[i] as FarmRunV5GameCardSlot).hide();
            }
         }
      }
      
      private function startPeekCountDown() : void
      {
         if(this.m_countdownFrame != null)
         {
            this.onPeekCountDownTick(COUNTDOWN_TOTAL);
            this.m_countdownFrame.visible = true;
            this.m_countdownTF.visible = true;
         }
         this.updateNPCTextBeforeQuiz();
      }
      
      private function onPeekCountDownTick(countdownTime:int) : void
      {
         var countdownMC:MovieClip = null;
         var scale:Number = NaN;
         if(countdownTime == 0)
         {
            this.manager.startTimer(TIMER_DELAY_IN_MSECS,this.onGameTimerTick);
            this.stopPeekCountDown();
         }
         else if(this.m_countdownFrame)
         {
            countdownMC = this.m_countdownFrame.element as MovieClip;
            scale = parseFloat((countdownTime / 2).toString());
            countdownMC.scaleX = scale;
            countdownMC.scaleY = scale;
            this.m_countdownTF.text = countdownTime.toString();
            countdownTime--;
            TweenLite.delayedCall(1,this.onPeekCountDownTick,[countdownTime]);
         }
      }
      
      private function stopPeekCountDown() : void
      {
         if(this.m_countdownFrame != null)
         {
            this.m_countdownFrame.visible = false;
            this.toggleSlotsPreview(false);
            TweenLite.killDelayedCallsTo(this.onPeekCountDownTick);
         }
         this.updateNPCBuyMoreTimeText();
      }
      
      public function get miniGameAssetsDir() : String
      {
         var worldFriendlyName:String = Global.worldManager.getWorldFriendlyName(this.manager.getFarmrunWorldFromPoints());
         return worldFriendlyName.split(" ").map(function(item:String, index:int, arr:Array):String
         {
            return item.toLowerCase();
         }).join("");
      }
      
      public function isSlotPaired(cellId:uint) : Boolean
      {
         return this.m_pairedList.indexOf(cellId) > -1;
      }
      
      public function handleSlotClick(cell:FarmRunV5GameCardSlot) : void
      {
         var currId:uint = 0;
         var prevId:uint = 0;
         if(!this.m_lastClickedSlot)
         {
            this.m_lastClickedSlot = cell;
         }
         else
         {
            currId = cell.slotId;
            prevId = this.m_lastClickedSlot.slotId;
            if(currId == prevId)
            {
               this.updateNPCCorrectMatchText();
               this.m_pairedList.push(currId);
               this.m_lastClickedSlot.match();
               cell.match();
            }
            else
            {
               this.updateNPCIncorrectMatchText();
               this.m_lastClickedSlot.noMatch();
               cell.noMatch();
            }
            if(this.m_timeRemaining > 2)
            {
               TweenLite.delayedCall(2,this.updateNPCBuyMoreTimeText);
            }
            this.m_lastClickedSlot = null;
         }
      }
      
      private function createRandomBoardSlotsData() : void
      {
         var assetPool:Array = this.manager.miniGameAssetPool;
         if(assetPool.length != MAX_MATCHES)
         {
            return;
         }
         for(var i:uint = 0; i < MAX_MATCHES; i++)
         {
            this.m_slotsData.push({
               "id":i,
               "asset":assetPool[i]
            });
            this.m_slotsData.push({
               "id":i,
               "asset":assetPool[i]
            });
         }
         ArrayUtils.shuffle(this.m_slotsData);
      }
      
      public function updateNPCTextBeforeQuiz() : void
      {
         if(this.m_talkMc)
         {
            this.m_talkMc.visible = true;
            if(this.m_talk_tf)
            {
               if(this.manager.miniGameActiveRound != LAST_ROUND)
               {
                  this.m_talk_tf.text = "You have 30 seconds to find all the pairs!";
               }
               else
               {
                  this.m_talk_tf.text = "Next round is starting. Get ready!";
               }
            }
         }
      }
      
      public function updateNPCCorrectMatchText() : void
      {
         if(this.m_talkMc)
         {
            this.m_talkMc.visible = true;
            if(this.m_talk_tf)
            {
               this.m_talk_tf.text = "Well Done! Now find all the matches before time runs out.";
            }
         }
      }
      
      public function updateNPCIncorrectMatchText() : void
      {
         if(this.m_talkMc)
         {
            this.m_talkMc.visible = true;
            if(this.m_talk_tf)
            {
               this.m_talk_tf.text = "Uh Oh.\nTry another tile!";
            }
         }
      }
      
      public function updateNPCBuyMoreTimeText() : void
      {
         if(Boolean(this.m_talkMc) && this.m_pairedList.length != MAX_MATCHES)
         {
            this.m_talkMc.visible = true;
            if(this.m_talk_tf)
            {
               if(this.m_timeRemaining <= 10)
               {
                  this.m_talk_tf.text = "Hurry up! \nFind all the matching pairs!";
               }
               else
               {
                  this.m_talk_tf.text = "You can also buy more time!";
               }
            }
         }
      }
      
      public function updateNPCTimeOverText() : void
      {
         if(this.m_talkMc)
         {
            this.m_talkMc.visible = true;
            if(this.m_talk_tf)
            {
               this.m_talk_tf.text = "Uh oh! \nTime got over.";
            }
         }
      }
   }
}

