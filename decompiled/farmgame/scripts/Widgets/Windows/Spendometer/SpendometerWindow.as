package Widgets.Windows.Spendometer
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.QueuedIcons.SpendometerQueuedIcon;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.SpendometerManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import fl.transitions.Tween;
   import fl.transitions.easing.Strong;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class SpendometerWindow extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Spendometer/FV_spendometer_main.swf";
      
      private var m_callBack:Function;
      
      private var m_itemCodes:Array;
      
      private var m_itemThresholdsSorted:Array;
      
      private var m_currentItemCode:String;
      
      private var m_startingProgress:int;
      
      private var m_endProgress:int;
      
      private var m_totalProgressReqForReward:int;
      
      private var m_currentlyShowingItemCode:String;
      
      private var m_unlockedItemsCount:int = 0;
      
      private var m_currentAnimationCallback:Function = null;
      
      private var m_source:String;
      
      private var m_titleTF:FarmTextField;
      
      private var m_subtitleTF:FarmTextField;
      
      private var m_rightArrow:FarmAnimatedButton;
      
      private var m_leftArrow:FarmAnimatedButton;
      
      private var m_slots:Array = [];
      
      private var m_slotsAnimations:Array = [];
      
      private var m_slotContainer:ZwWidget;
      
      private var m_starContainer:ZwFrame;
      
      private var m_stars:Array = [];
      
      private var m_timeRemTF:FarmTextField;
      
      private var m_timeRemAmountTF:FarmTextField;
      
      public function SpendometerWindow(dialogAsset:String, callBack:Function = null, source:String = "undef")
      {
         super(dialogAsset);
         this.m_callBack = callBack;
         this.m_source = source;
         this.initMemberVars();
         FarmStatsManager.count(SpendometerManager.FEATURE_OPTIONS_KEY,"main_dialog",source,"view");
      }
      
      public static function display(callBack:Function = null, source:String = "undef") : void
      {
         var popUp:SpendometerWindow = null;
         popUp = new SpendometerWindow(ASSET_NAME,callBack,source);
         UI.displayPopup(popUp);
      }
      
      private function initMemberVars() : void
      {
         this.m_itemCodes = SpendometerManager.instance.getRewardItemsCode();
         this.m_itemThresholdsSorted = SpendometerManager.instance.getSortedThresholds();
         this.m_currentItemCode = SpendometerManager.instance.getLastShownItemCode();
         this.m_startingProgress = SpendometerManager.instance.getLastShownProgressCount();
         this.m_totalProgressReqForReward = SpendometerManager.instance.getTotalCountReqForItemCode(this.m_currentItemCode);
         if(this.m_currentItemCode == SpendometerManager.instance.getActualCurentItemCode())
         {
            this.m_endProgress = SpendometerManager.instance.getActualCurrentProgressCount();
         }
         else
         {
            this.m_endProgress = this.m_totalProgressReqForReward;
         }
      }
      
      private function updateMemberVars() : void
      {
         this.m_currentItemCode = SpendometerManager.instance.getLastShownItemCode();
         this.m_startingProgress = SpendometerManager.instance.getLastShownProgressCount();
         this.m_totalProgressReqForReward = SpendometerManager.instance.getTotalCountReqForItemCode(this.m_currentItemCode);
         if(this.m_currentItemCode == SpendometerManager.instance.getActualCurentItemCode())
         {
            this.m_endProgress = SpendometerManager.instance.getActualCurrentProgressCount();
         }
         else
         {
            this.m_endProgress = this.m_totalProgressReqForReward;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.setupDialog();
      }
      
      private function setupDialog() : void
      {
         this.m_currentlyShowingItemCode = this.m_currentItemCode;
         this.setupBase();
         this.setupArrows();
         this.setupRewardsItemsContext();
         this.kickStartAnimations();
      }
      
      private function setupBase() : void
      {
         addWidget(new ZwWidget(m_window.mainWindow),true);
         addWidget(this.m_titleTF = new FarmTextField(m_window.mainWindow.title_tf,"Spend & Earn Rewards"),true);
         addWidget(this.m_timeRemTF = new FarmTextField(m_window.mainWindow.timeRemaining_tf,"Time Remaining :"),true);
         var parsedTime:Array = FarmGameUtil.parseTimeLeft(SpendometerManager.instance.getTimeRemaining());
         addWidget(this.m_timeRemAmountTF = new FarmTextField(m_window.mainWindow.time_tf,FarmGameUtil.getFormattedTimeLeftText(parsedTime)),true);
         addWidget(this.m_subtitleTF = new FarmTextField(m_window.mainWindow.discription_tf,"Shop Farm Cash items in the market place and collect these unique rewards!"),true);
         m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose)) as FarmButton;
      }
      
      private function setupArrows() : void
      {
         addWidget(this.m_leftArrow = new FarmAnimatedButton(m_window.mainWindow.arrowLeft_bt,this.onLeftArrowClicked),true);
         addWidget(this.m_rightArrow = new FarmAnimatedButton(m_window.mainWindow.arrowRight_bt,this.onRightArrowClicked),true);
      }
      
      private function updateArrows() : void
      {
         this.m_leftArrow.enabled = true;
         this.m_rightArrow.enabled = true;
         if(this.m_itemThresholdsSorted.indexOf(SpendometerManager.instance.getRewardItemThreshold(this.m_currentlyShowingItemCode)) == 0)
         {
            this.m_leftArrow.enabled = false;
         }
         if(this.m_itemThresholdsSorted.indexOf(SpendometerManager.instance.getRewardItemThreshold(this.m_currentlyShowingItemCode)) == this.m_itemThresholdsSorted.length - 1)
         {
            this.m_rightArrow.enabled = false;
         }
      }
      
      private function disableButtons() : void
      {
         this.m_leftArrow.enabled = false;
         this.m_rightArrow.enabled = false;
         m_closeButton.enabled = false;
      }
      
      private function enableButtons() : void
      {
         if(m_closeButton)
         {
            m_closeButton.enabled = true;
            this.updateArrows();
         }
      }
      
      private function onLeftArrowClicked(eve:Event = null) : void
      {
         var leftTween:Tween = null;
         var timer:Timer = null;
         var currentIndex:int = this.m_itemThresholdsSorted.indexOf(SpendometerManager.instance.getRewardItemThreshold(this.m_currentlyShowingItemCode));
         var newIndex:int = currentIndex - 1;
         if(newIndex >= 0)
         {
            this.m_currentlyShowingItemCode = SpendometerManager.instance.getItemCodeForThreshold(this.m_itemThresholdsSorted[newIndex]);
            leftTween = new Tween(this.m_slotContainer.element as MovieClip,"x",Strong.easeIn,(this.m_slotContainer.element as MovieClip).x,(this.m_slotContainer.element as MovieClip).x + this.getPerMoveDisplacement(currentIndex,newIndex),0.8,true);
            leftTween.start();
            this.disableButtons();
            timer = new Timer(800,1);
            timer.addEventListener(TimerEvent.TIMER,function(e:Event):void
            {
               enableButtons();
               timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
            });
            timer.start();
         }
      }
      
      private function onRightArrowClicked(eve:Event = null) : void
      {
         var rightTween:Tween = null;
         var timer:Timer = null;
         var currentIndex:int = this.m_itemThresholdsSorted.indexOf(SpendometerManager.instance.getRewardItemThreshold(this.m_currentlyShowingItemCode));
         var newIndex:int = currentIndex + 1;
         if(newIndex < this.m_itemThresholdsSorted.length)
         {
            this.m_currentlyShowingItemCode = SpendometerManager.instance.getItemCodeForThreshold(this.m_itemThresholdsSorted[newIndex]);
            rightTween = new Tween(this.m_slotContainer.element as MovieClip,"x",Strong.easeIn,(this.m_slotContainer.element as MovieClip).x,(this.m_slotContainer.element as MovieClip).x + this.getPerMoveDisplacement(currentIndex,newIndex),0.8,true);
            rightTween.start();
            this.disableButtons();
            timer = new Timer(800,1);
            timer.addEventListener(TimerEvent.TIMER,function(e:Event):void
            {
               enableButtons();
               timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
            });
            timer.start();
         }
      }
      
      private function getPerMoveDisplacement(startIndex:int, endIndex:int) : Number
      {
         return Number((this.m_slots[startIndex].element as MovieClip).x - (this.m_slots[endIndex].element as MovieClip).x);
      }
      
      private function setupRewardsItemsContext() : void
      {
         var itemCode:String = null;
         var item:FarmItem = null;
         var slot:ZwFrame = null;
         var state:int = 0;
         var icon:FarmIcon = null;
         var animation:ZwWidget = null;
         var star:ZwWidget = null;
         var button:FarmAnimatedTextButton = null;
         var startingPos:int = 0;
         addWidget(this.m_slotContainer = new ZwWidget(m_window.mainWindow.animationSlot_mc),true);
         addWidget(this.m_starContainer = new ZwFrame(m_window.mainWindow.levelStar_mc),true);
         var encounteredUnlockedItem:Boolean = false;
         for(var i:int = 0; i < this.m_itemThresholdsSorted.length; i++)
         {
            itemCode = SpendometerManager.instance.getItemCodeForThreshold(this.m_itemThresholdsSorted[i]);
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(item)
            {
               slot = new ZwFrame(this.m_slotContainer.element["slot_" + i + "_mc"]);
               addWidget(slot,true);
               slot.addWidget(new ZwFrame(slot.element.slotParent_mc),true);
               state = SpendometerManager.instance.getRewardItemState(itemCode);
               if(state == SpendometerManager.REWARD_STATE_COLLECTED)
               {
                  button = new FarmAnimatedTextButton(slot.element.slotParent_mc.accept_bt,"Collected",this.onCollectClicked);
                  slot.addWidget(button,true);
                  button.enabled = false;
                  ++this.m_unlockedItemsCount;
               }
               else if(state == SpendometerManager.REWARD_STATE_READY)
               {
                  slot.addWidget(new FarmAnimatedTextButton(slot.element.slotParent_mc.accept_bt,"Collect",this.onCollectClicked),true);
                  ++this.m_unlockedItemsCount;
               }
               else if(state == SpendometerManager.REWARD_STATE_INCOMPLETE)
               {
                  if(!encounteredUnlockedItem)
                  {
                     ++this.m_unlockedItemsCount;
                     encounteredUnlockedItem = true;
                     slot.addWidget(new FarmTextField(slot.element.slotParent_mc.spendFC_tf,"Spend " + SpendometerManager.instance.getTotalCountReqForItemCode(itemCode) + " Cash"),true);
                     slot.addWidget(new ZwWidget(slot.element.slotParent_mc.toolTip_mc),true);
                     slot.addWidget(new FarmTextField(slot.element.slotParent_mc.toolTip_mc.toolTipMSG_tf,"Spend another " + (SpendometerManager.instance.getTotalCountReqForItemCode(itemCode) - SpendometerManager.instance.getActualCurrentProgressCount()) + " cash in the Market Place"),true);
                     slot.addWidget(new FarmAnimatedTextButton(slot.element.slotParent_mc.toolTip_mc.gotoMarket_bt,"Shop Now!",this.showMarket),true);
                  }
                  else
                  {
                     slot.addWidget(new ZwWidget(slot.element.slotParent_mc.lockIcon_mc),true);
                  }
               }
               icon = new FarmIcon(slot.element.slotParent_mc.icon_mc);
               icon.setIconSize(slot.element.slotParent_mc.icon_mc.width,slot.element.slotParent_mc.icon_mc.height);
               icon.loadIcon(item.iconUrl);
               slot.addWidget(icon,true);
               animation = new ZwWidget(slot.element.slotParent_mc.progressCircle_mc);
               slot.addWidget(animation,true);
               if(i < this.m_itemThresholdsSorted.indexOf(SpendometerManager.instance.getRewardItemThreshold(this.m_currentItemCode)))
               {
                  ((animation.element as MovieClip).getChildByName("loader_mc") as MovieClip).gotoAndStop(100);
               }
               else if(i == this.m_itemThresholdsSorted.indexOf(SpendometerManager.instance.getRewardItemThreshold(this.m_currentItemCode)))
               {
                  startingPos = int(100 * this.m_startingProgress / this.m_totalProgressReqForReward);
                  startingPos = startingPos > 0 ? (startingPos <= 100 ? startingPos : 100) : 1;
                  ((animation.element as MovieClip).getChildByName("loader_mc") as MovieClip).gotoAndStop(startingPos);
               }
               else
               {
                  ((animation.element as MovieClip).getChildByName("loader_mc") as MovieClip).gotoAndStop(1);
               }
               this.m_slotsAnimations.push(animation);
               this.m_slots.push(slot);
               star = new ZwWidget(this.m_starContainer.element["star_" + i + "_mc"]);
               this.m_stars.push(star);
               this.m_starContainer.addWidget(star,true);
            }
         }
         addWidget(new FarmTextField(m_window.mainWindow.unlock_tf,"Rewards Unlocked :"),true);
         addWidget(new FarmTextField(m_window.mainWindow.unlockNum_tf,this.m_unlockedItemsCount.toString() + "/" + this.m_itemThresholdsSorted.length.toString()),true);
         var numMoves:int = this.m_itemThresholdsSorted.indexOf(SpendometerManager.instance.getRewardItemThreshold(this.m_currentlyShowingItemCode));
         (this.m_slotContainer.element as MovieClip).x += this.getPerMoveDisplacement(0,numMoves);
      }
      
      private function kickStartAnimations() : void
      {
         this.kickStartStarAnimationIfApplicable();
         this.kickStartFillAnimationIfApplicable();
      }
      
      private function kickStartStarAnimationIfApplicable() : void
      {
         var star:MovieClip = null;
         var i:int = 0;
         while(i < this.m_unlockedItemsCount && i < this.m_stars.length)
         {
            star = this.m_stars[i].element as MovieClip;
            if(star)
            {
               star.gotoAndStop(2);
               if(star.getChildByName("startAnimation_mc"))
               {
                  (star.getChildByName("startAnimation_mc") as MovieClip).gotoAndPlay(1);
               }
            }
            i++;
         }
      }
      
      private function kickStartFillAnimationIfApplicable() : void
      {
         var index:int = 0;
         var animation:ZwWidget = null;
         var animationLoaderMC:MovieClip = null;
         var playToFrame:int = 0;
         var startingPos:int = 0;
         if(this.m_startingProgress != this.m_endProgress)
         {
            this.disableButtons();
            index = this.m_itemThresholdsSorted.indexOf(SpendometerManager.instance.getRewardItemThreshold(this.m_currentlyShowingItemCode));
            animation = this.m_slotsAnimations[index];
            if(animation)
            {
               animationLoaderMC = (animation.element as MovieClip).getChildByName("loader_mc") as MovieClip;
               playToFrame = int(100 * this.m_endProgress / this.m_totalProgressReqForReward);
               playToFrame = playToFrame > 100 ? 100 : playToFrame;
               if(playToFrame >= 1)
               {
                  startingPos = int(100 * this.m_startingProgress / this.m_totalProgressReqForReward);
                  startingPos = startingPos > 0 ? (startingPos <= 100 ? startingPos : 100) : 1;
                  if(startingPos < playToFrame)
                  {
                     animationLoaderMC.addEventListener(Event.ENTER_FRAME,this.m_currentAnimationCallback = function(e:Event):void
                     {
                        if(animationLoaderMC.currentFrame == playToFrame)
                        {
                           animationLoaderMC.stop();
                           animationLoaderMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                           if(playToFrame != 100)
                           {
                              SpendometerManager.instance.dialogShown(SpendometerManager.instance.lastShownCount + (m_endProgress - m_startingProgress));
                              enableButtons();
                           }
                        }
                     });
                     animationLoaderMC.gotoAndPlay(startingPos);
                  }
               }
               else
               {
                  animationLoaderMC.gotoAndStop(1);
                  animationLoaderMC.stop();
                  this.enableButtons();
               }
            }
         }
         else
         {
            this.enableButtons();
         }
      }
      
      private function onCollectClicked(eve:Event = null) : void
      {
         var buttonWidget:FarmAnimatedTextButton = null;
         var animationLoaderMC:MovieClip = null;
         SpendometerManager.instance.grantRewardItem(this.m_currentlyShowingItemCode);
         var index:int = this.m_itemThresholdsSorted.indexOf(SpendometerManager.instance.getRewardItemThreshold(this.m_currentlyShowingItemCode));
         if(eve)
         {
            buttonWidget = (this.m_slots[index] as ZwFrame).getWidgetFromEvent(eve) as FarmAnimatedTextButton;
            if(buttonWidget)
            {
               buttonWidget.enabled = false;
            }
         }
         var animation:ZwWidget = this.m_slotsAnimations[index];
         if(animation)
         {
            animationLoaderMC = (animation.element as MovieClip).getChildByName("loader_mc") as MovieClip;
            animationLoaderMC.gotoAndStop(100);
            if(this.m_currentAnimationCallback != null)
            {
               animationLoaderMC.removeEventListener(Event.ENTER_FRAME,this.m_currentAnimationCallback);
            }
            SpendometerManager.instance.dialogShown(SpendometerManager.instance.lastShownCount + (this.m_endProgress - this.m_startingProgress));
         }
         if(index < this.m_itemThresholdsSorted.length - 1)
         {
            this.updateMemberVars();
            this.onRightArrowClicked();
            this.kickStartFillAnimationIfApplicable();
            SpendometerQueuedIcon.updateHUDIcon();
         }
         else
         {
            this.close();
            SpendometerManager.instance.offBoardFeature();
         }
      }
      
      override protected function release() : void
      {
         this.m_callBack = null;
         this.m_currentAnimationCallback = null;
         super.release();
      }
      
      private function showMarket(eve:Event = null) : void
      {
         onClose(eve);
         SpendometerManager.instance.showMarket(eve);
      }
   }
}

