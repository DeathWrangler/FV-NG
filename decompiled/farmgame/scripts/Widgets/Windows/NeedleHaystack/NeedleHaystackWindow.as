package Widgets.Windows.NeedleHaystack
{
   import Classes.Minigames.MinigameData;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.NeedleHaystack.NeedleHaystackHayBaleSlot;
   import Widgets.Windows.Minigame.MinigameWindow;
   import com.greensock.TimelineLite;
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import com.greensock.easing.Elastic;
   import com.greensock.plugins.FrameLabelPlugin;
   import com.greensock.plugins.FramePlugin;
   import com.greensock.plugins.TweenPlugin;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class NeedleHaystackWindow extends MinigameWindow
   {
      
      TweenPlugin.activate([FrameLabelPlugin,FramePlugin]);
      
      private const NEEDLE_ICON:String = "assets/newsfeed/part_needle.png";
      
      private const SADCOW_ICON:String = "assets/dialogs/FV_Support/FV_FortuneWheel/FW_slotCow.png";
      
      private const SHUFFLE_TIME:int = 5;
      
      private var m_numAnimKey:int = 3;
      
      private var m_streak:int = 0;
      
      private var m_tutorialTextField:ZwTextField = null;
      
      private var m_meterBw:ZwFrame = null;
      
      private var m_timeLine:TimelineLite = null;
      
      private var m_haybales:ZwBaseWidget = null;
      
      private var m_bales:ZwBaseWidget = null;
      
      private var m_frames:Array = null;
      
      private var m_winningBale:int = -1;
      
      private var m_haySlots:Array = null;
      
      private var m_startDialogFrame:ZwFrame = null;
      
      public function NeedleHaystackWindow(minigameData:MinigameData)
      {
         super(minigameData);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_window.streak_tf != null)
         {
            addWidget(this.m_tutorialTextField = new ZwTextField(m_window.streak_tf,ZLocUtils.t("Dialogs","NeedleHaystack_WatchBales")),false);
         }
         if(m_window.close_bt != null)
         {
            m_window.close_bt.addEventListener(MouseEvent.MOUSE_OVER,this.closeMouseOver);
            m_window.close_bt.addEventListener(MouseEvent.MOUSE_OUT,this.closeMouseOut);
         }
         this.initializeDifficultyMeter();
         this.initializeStartWindow();
         this.initializeHayBaleFrame();
         this.showStartGame();
         this.setAfterMessage();
      }
      
      private function initializeStartWindow() : void
      {
         if(m_window.start_mc != null)
         {
            addWidget(this.m_startDialogFrame = new ZwFrame(m_window.start_mc));
            if(this.m_startDialogFrame.element.play_bt != null)
            {
               this.m_startDialogFrame.addWidget(new FarmAnimatedTextButton(this.m_startDialogFrame.element.play_bt,ZLocUtils.t("Dialogs","NeedleHaystack_BuyButtonText"),this.playGame),hasTokens());
            }
            if(this.m_startDialogFrame.element.buy_bt != null)
            {
               this.m_startDialogFrame.addWidget(new FarmAnimatedCashButton(this.m_startDialogFrame.element.buy_bt,ZLocUtils.t("Dialogs","NeedleHaystack_BuyButtonText"),getTokenCost().toString(),this.playGame),!hasTokens());
            }
            if(this.m_startDialogFrame.element.copy_tf != null)
            {
               this.m_startDialogFrame.addWidget(new ZwTextField(this.m_startDialogFrame.element.copy_tf,""));
            }
         }
      }
      
      private function initializeDifficultyMeter() : void
      {
         if(m_window.meter_mc != null)
         {
            addWidget(this.m_meterBw = new ZwFrame(m_window.meter_mc));
            (this.m_meterBw.element as MovieClip).gotoAndStop(difficulty);
            if(this.m_meterBw.element.title_tf != null)
            {
               this.m_meterBw.addWidget(new ZwTextField(this.m_meterBw.element.title_tf,ZLocUtils.t("Dialogs","NeedleHaystack_TicketReward")));
            }
            if(this.m_meterBw.element.generic_tf != null)
            {
               this.m_meterBw.addWidget(new ZwTextField(this.m_meterBw.element.generic_tf));
            }
         }
      }
      
      private function initializeHayBaleFrame() : void
      {
         var cardHolder:ZwFrame = null;
         var slot:NeedleHaystackHayBaleSlot = null;
         this.m_haySlots = new Array();
         if(m_window.bales_mc != null)
         {
            addWidget(this.m_haybales = new ZwBaseWidget(m_window.bales_mc));
            (this.m_haybales.element as MovieClip).gotoAndStop(1);
            if(this.m_haybales.element.bale_mc != null)
            {
               this.m_bales = new ZwBaseWidget(this.m_haybales.element.bale_mc);
               (this.m_bales.element as MovieClip).gotoAndStop(1);
            }
         }
         var i:int = 1;
         while(m_window["hay" + i])
         {
            this.m_haySlots.push(new NeedleHaystackHayBaleSlot(m_window["hay" + i]));
            i++;
         }
         for each(slot in this.m_haySlots)
         {
            addWidget(slot);
            if(slot.element.card_mc != null)
            {
               slot.addWidget(cardHolder = new ZwFrame(slot.element.card_mc),false);
               slot.setSlotCallback(this.onSelect);
               this.addWinningWidgets(cardHolder);
            }
         }
      }
      
      private function addWinningWidgets(frame:ZwFrame) : void
      {
         if(frame.element.title_tf != null)
         {
            frame.addWidget(new ZwTextField(frame.element.title_tf,ZLocUtils.t("Dialogs","NeedleHaystack_WinTitle")));
         }
         if(frame.element.buy_bt != null)
         {
            frame.addWidget(new FarmAnimatedCashButton(frame.element.buy_bt,ZLocUtils.t("Dialogs","NeedleHaystack_BuyPlayAgainText"),getTokenCost().toString(),this.playGameAgain));
         }
         if(frame.element.play_bt != null)
         {
            frame.addWidget(new FarmAnimatedTextButton(frame.element.play_bt,ZLocUtils.t("Dialogs","NeedleHaystack_FreePlayAgainText"),this.playGameAgain));
         }
         if(frame.element.icon_mc != null)
         {
            frame.addWidget(new FarmIcon(frame.element.icon_mc,this.NEEDLE_ICON));
         }
         if(frame.element.win_mc != null)
         {
            frame.addWidget(new ZwBaseWidget(frame.element.win_mc));
         }
         if(frame.element.strak_tf != null)
         {
            frame.addWidget(new ZwTextField(frame.element.streak_tf));
         }
      }
      
      private function playGame(event:Event = null) : void
      {
         var statsText:String = null;
         buyToken(false);
         if(hasTokens())
         {
            this.hideStartGame();
            statsText = freeTokens > 0 ? "free_play" : "paid_play";
            StatsManager.count(getGameStatCounterName(),"play","click",statsText);
            this.setupAnimation();
         }
      }
      
      private function playGameAgain(event:Event = null) : void
      {
         var frame:ZwFrame = null;
         var statsText:String = null;
         var cardWidget:ZwFrame = null;
         buyToken(true);
         if(hasTokens())
         {
            frame = getWidget(event.target.parent.parent) as ZwFrame;
            if(frame != null && frame.element.card_mc != null)
            {
               cardWidget = frame.getWidget(frame.element.card_mc) as ZwFrame;
               this.hideWinnerTab(cardWidget);
            }
            statsText = freeTokens > 0 ? "free_play" : "paid_play";
            StatsManager.count(getGameStatCounterName(),"replay","click",statsText);
            this.setupAnimation();
         }
      }
      
      private function setupAnimation() : void
      {
         this.m_frames = [1,2,3];
         if(this.m_tutorialTextField != null)
         {
            this.m_tutorialTextField.text = ZLocUtils.t("Dialogs","NeedleHaystack_WatchBales");
            this.m_tutorialTextField.visible = true;
         }
         this.m_winningBale = Math.random() * 2 + 1;
         this.setHaystackVisibility(false);
         this.showNeedleStart();
      }
      
      private function playAnimation() : void
      {
         this.m_timeLine = new TimelineLite({"onComplete":this.onAnimationComplete});
         this.m_timeLine.stop();
         var range:int = difficulty * this.m_numAnimKey;
         for(var i:int = 0; i < range; i++)
         {
            this.m_frames.sort(this.randomSort);
            this.m_timeLine.append(new TweenLite(this.m_bales.element,0.001,{"frameLabel":"a" + this.m_frames[0] + this.m_frames[1] + this.m_frames[2]}));
            this.m_timeLine.append(new TweenLite(this.m_bales.element,this.SHUFFLE_TIME - difficulty,{"frameLabel":"a" + this.m_frames[0] + this.m_frames[1] + this.m_frames[2] + "end"}));
            this.m_winningBale = this.m_frames.indexOf(this.m_winningBale) + 1;
         }
         this.m_timeLine.play();
      }
      
      private function onSelect(event:Event) : void
      {
         var didWin:Boolean = event.target.parent == this.findHaystackFromIndex(this.m_winningBale).element.image_mc;
         useToken(didWin,0,null);
         if(didWin)
         {
            this.m_streak += 1;
         }
         else
         {
            this.m_streak = 0;
         }
         this.setHighStreakText();
         var frame:ZwFrame = getWidget(event.target.parent.parent) as ZwFrame;
         this.setAfterMessage();
         this.showWinnerTab(frame,didWin);
      }
      
      private function setAfterMessage() : void
      {
         var difficultyText:String = null;
         if(this.m_meterBw != null)
         {
            this.m_meterBw.element.gotoAndStop(difficulty);
            difficultyText = ZLocUtils.t("Dialogs","NeedleHaystack_Level" + difficulty);
            (this.m_meterBw.getWidget(this.m_meterBw.element.generic_tf) as ZwTextField).text = difficultyText;
         }
         refreshTicketCount();
         m_prizes.refresh();
      }
      
      public function showStartGame() : void
      {
         var titleText:String = null;
         this.m_startDialogFrame.visible = true;
         if(hasTokens())
         {
            titleText = ZLocUtils.t("Dialogs","NeedleHaystack_FreeTitle");
         }
         else
         {
            titleText = ZLocUtils.t("Dialogs","NeedleHaystack_PayTitle");
         }
         this.m_startDialogFrame.element.copy_tf.text = titleText;
         this.m_startDialogFrame.element.play_bt.visible = hasTokens();
         this.m_startDialogFrame.element.buy_bt.visible = !hasTokens();
      }
      
      public function hideStartGame() : void
      {
         this.m_startDialogFrame.visible = false;
      }
      
      private function showWinnerTab(frame:ZwFrame, didWin:Boolean) : void
      {
         var titleText:String = null;
         var iconUrl:String = null;
         var icon:FarmIcon = null;
         this.setHaystackVisibility(false);
         var cardWidget:ZwFrame = frame.getWidget(frame.element.card_mc) as ZwFrame;
         if(cardWidget != null)
         {
            cardWidget.visible = true;
            cardWidget.element.scaleX = 1;
            cardWidget.element.scayeY = 1;
            if(didWin)
            {
               titleText = ZLocUtils.t("Dialogs","NeedleHaystack_WinTitle");
               iconUrl = this.NEEDLE_ICON;
            }
            else
            {
               titleText = ZLocUtils.t("Dialogs","NeedleHaystack_LoseTitle");
               iconUrl = this.SADCOW_ICON;
            }
            cardWidget.element.title_tf.visible = true;
            cardWidget.element.title_tf.text = titleText;
            cardWidget.element.win_mc.visible = didWin;
            cardWidget.element.loose_mc.visible = !didWin;
            cardWidget.element.buy_bt.visible = !hasTokens();
            cardWidget.element.play_bt.visible = hasTokens();
            if(this.m_streak > 0)
            {
               cardWidget.element.streak_tf.text = ZLocUtils.t("Dialogs","NeedleHaystack_Streak",{"quantity":this.m_streak});
               cardWidget.element.streak_tf.visible = true;
            }
            else
            {
               cardWidget.element.streak_tf.visible = false;
            }
            icon = cardWidget.getWidget(cardWidget.element.icon_mc) as FarmIcon;
            icon.visible = true;
            icon.loadIcon(iconUrl);
            TweenMax.from(cardWidget.element,3,{
               "scaleX":0,
               "scaleY":0,
               "ease":Elastic.easeOut
            });
         }
      }
      
      private function hideWinnerTab(frame:ZwFrame) : void
      {
         frame.visible = false;
      }
      
      private function showNeedleStart() : void
      {
         var cardWidget:ZwFrame = null;
         var icon:FarmIcon = null;
         var baleFrame:ZwFrame = this.findHaystackFromIndex(this.m_winningBale);
         if(baleFrame != null && baleFrame.element.card_mc != null)
         {
            cardWidget = baleFrame.getWidget(baleFrame.element.card_mc) as ZwFrame;
            if(cardWidget != null)
            {
               cardWidget.visible = true;
               cardWidget.element.scaleX = 1;
               cardWidget.element.scayeY = 1;
               cardWidget.element.win_mc.visible = false;
               cardWidget.element.title_tf.visible = false;
               cardWidget.element.loose_mc.visible = false;
               cardWidget.element.buy_bt.visible = false;
               cardWidget.element.play_bt.visible = false;
               if(this.m_streak > 0)
               {
                  cardWidget.element.streak_tf.text = ZLocUtils.t("Dialogs","NeedleHaystack_Streak",{"quantity":this.m_streak});
                  cardWidget.element.streak_tf.visible = true;
               }
               else
               {
                  cardWidget.element.streak_tf.visible = false;
               }
               icon = cardWidget.getWidget(cardWidget.element.icon_mc) as FarmIcon;
               icon.visible = true;
               icon.loadIcon(this.NEEDLE_ICON);
               TweenMax.from(cardWidget.element,3,{
                  "scaleX":0,
                  "scaleY":0,
                  "ease":Elastic.easeOut,
                  "onComplete":this.hideNeedle
               });
            }
         }
      }
      
      private function hideNeedle() : void
      {
         var cardWidget:ZwFrame = null;
         var icon:FarmIcon = null;
         var baleFrame:ZwFrame = this.findHaystackFromIndex(this.m_winningBale);
         if(baleFrame != null && baleFrame.element.card_mc != null)
         {
            cardWidget = baleFrame.getWidget(baleFrame.element.card_mc) as ZwFrame;
            if(cardWidget != null)
            {
               cardWidget.visible = true;
               cardWidget.element.scaleX = 0;
               cardWidget.element.scayeY = 0;
               cardWidget.element.win_mc.visible = false;
               cardWidget.element.title_tf.visible = false;
               cardWidget.element.loose_mc.visible = false;
               cardWidget.element.buy_bt.visible = false;
               cardWidget.element.play_bt.visible = false;
               if(this.m_streak > 0)
               {
                  cardWidget.element.streak_tf.text = ZLocUtils.t("Dialogs","NeedleHaystack_Streak",{"quantity":this.m_streak});
                  cardWidget.element.streak_tf.visible = true;
               }
               else
               {
                  cardWidget.element.streak_tf.visible = false;
               }
               icon = cardWidget.getWidget(cardWidget.element.icon_mc) as FarmIcon;
               icon.visible = true;
               icon.loadIcon(this.NEEDLE_ICON);
               TweenMax.from(cardWidget.element,1,{
                  "scaleX":1,
                  "scaleY":1,
                  "ease":Elastic.easeOut,
                  "onComplete":this.playAnimation
               });
            }
         }
      }
      
      private function findHaystackFromIndex(index:int) : NeedleHaystackHayBaleSlot
      {
         var result:NeedleHaystackHayBaleSlot = null;
         if(this.m_haySlots != null)
         {
            result = this.m_haySlots[index - 1];
         }
         return result;
      }
      
      private function onAnimationComplete() : void
      {
         this.setHaystackVisibility(true);
         if(this.m_tutorialTextField != null)
         {
            this.m_tutorialTextField.text = ZLocUtils.t("Dialogs","NeedleHaystack_Choose");
         }
      }
      
      private function setHaystackVisibility(visibility:Boolean) : void
      {
         var slot:NeedleHaystackHayBaleSlot = null;
         for each(slot in this.m_haySlots)
         {
            slot.setVisible(visibility);
         }
         this.m_haybales.visible = !visibility;
      }
      
      private function randomSort(objA:Object, objB:Object) : int
      {
         return Math.round(Math.random() * 3) - 1;
      }
      
      private function setHighStreakText() : void
      {
         var names:Array = null;
         var index:int = 0;
         var name:String = null;
         var quantity:int = 0;
         if(this.m_tutorialTextField != null)
         {
            names = (Global.farmGameSettingsManager.getString("randomNames","Rob") as String).split(",");
            index = Math.random() * (names.length - 1);
            name = names[index];
            quantity = Math.random() * 15 + 5;
            this.m_tutorialTextField.text = ZLocUtils.t("Dialogs","NeedleHaystack_HighStreak",{
               "name":name,
               "quantity":quantity
            });
            this.m_tutorialTextField.visible = true;
         }
      }
      
      override public function close() : void
      {
         if(this.m_timeLine != null)
         {
            this.m_timeLine.stop();
            this.m_timeLine.clear();
         }
         TweenMax.killAll();
         super.close();
      }
      
      private function closeMouseOver(event:Event) : void
      {
         event.target.gotoAndStop(2);
      }
      
      private function closeMouseOut(event:Event) : void
      {
         event.target.gotoAndStop(1);
      }
      
      override protected function release() : void
      {
         if(m_window.clost_bt != null)
         {
            m_window.clost_bt.removeEventListener(MouseEvent.MOUSE_OVER,this.closeMouseOver);
            m_window.clost_bt.removeEventListener(MouseEvent.MOUSE_OUT,this.closeMouseOut);
         }
         this.m_tutorialTextField = null;
         this.m_meterBw = null;
         this.m_timeLine = null;
         this.m_haybales = null;
         this.m_bales = null;
         this.m_frames = null;
         this.m_haySlots = null;
         this.m_startDialogFrame = null;
         super.release();
      }
   }
}

