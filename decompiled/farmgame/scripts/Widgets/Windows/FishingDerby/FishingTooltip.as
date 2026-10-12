package Widgets.Windows.FishingDerby
{
   import Classes.Doobers.FishingRewardView;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUDWidgets.HUDHomeWidget;
   import Engine.Helpers.Vector2;
   import Engine.IsoMath;
   import Engine.Managers.TransactionManager;
   import Managers.FishingDerbyManager;
   import Managers.ToasterManager;
   import Transactions.TFishing;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import com.greensock.TweenLite;
   import com.greensock.easing.Quad;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FishingTooltip extends FarmWindow
   {
      
      public static const ASSET_PATH:String = "assets/dialogs/Angler/FV_fishing_tooltip.swf";
      
      private static const FTUE_FLAG:String = "fishingDerby_gameFTUE";
      
      public static const FISHING_CATCH:String = "fishing_cath";
      
      private var m_ftueFrame:ZwFrame;
      
      private var m_spinner:ZwBaseWidget;
      
      private var m_miniGameComplete:Boolean;
      
      private var m_extraData:Object;
      
      private var m_transactionResult:Object;
      
      private var m_rod:ZwBaseWidget;
      
      private var m_angle:Number;
      
      private var m_direction:int;
      
      private var m_timeLeft:Number;
      
      private var m_timerField:ZwTextField;
      
      private var m_numClicks:int;
      
      private var m_counterWrapper:ZwBaseWidget;
      
      private var m_counterField:ZwTextField;
      
      private var m_missFieldWrapper:ZwBaseWidget;
      
      private var m_missField:ZwTextField;
      
      private var m_gameSpeed:Number;
      
      private var m_timer:Timer;
      
      private var m_castButton:FarmButton;
      
      private var m_startGameButton:FarmAnimatedTextButton;
      
      public function FishingTooltip(extraData:Object)
      {
         super(ASSET_PATH);
         this.m_miniGameComplete = false;
         this.m_extraData = extraData;
         this.m_direction = 1;
         this.m_numClicks = 0;
         this.m_gameSpeed = 3;
         this.m_timeLeft = 7;
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.decrementSeconds);
         TransactionManager.addTransaction(new TFishing(TFishing.CAST_BOBBER,this.m_extraData,function(result:Object):void
         {
            m_transactionResult = result;
            reelInFish();
         }));
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
      }
      
      private function showWhatIsThis(even:Event) : void
      {
         this.m_ftueFrame.visible = true;
      }
      
      override protected function onShow() : void
      {
         Global.world.addEventListener(HUDHomeWidget.TRAVEL_HOME,this.stopGame);
         addWidget(this.m_spinner = new ZwBaseWidget(m_window.mc_loader),false);
         addWidget(this.m_rod = new ZwBaseWidget(m_window.rod_mc));
         addWidget(this.m_castButton = new FarmButton(m_window.cast_bt));
         addWidget(this.m_timerField = new ZwTextField(m_window.timer_tf,":7s"));
         addWidget(this.m_counterWrapper = new ZwBaseWidget(m_window.clickCounter_mc));
         addWidget(this.m_counterField = new ZwTextField(m_window.clickCounter_mc.clickCounter_tf));
         this.m_counterField.text = "x" + this.m_numClicks.toString();
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_bt,""));
         addWidget(this.m_ftueFrame = new ZwFrame(m_window.ftue_mc),false);
         this.m_ftueFrame.addWidget(new ZwTextField(m_window.ftue_mc.title_tf,ZLocUtils.t_pk("Dialogs","FishingTooltip_Title")));
         this.m_ftueFrame.addWidget(new ZwTextField(m_window.ftue_mc.generic_tf,ZLocUtils.t_pk("Dialogs","FishingTooltip_Text")));
         this.m_ftueFrame.addWidget(new ZwTextField(m_window.ftue_mc.generic2_tf,ZLocUtils.t_pk("Dialogs","FishingTooltipPrizeLimit_Text")));
         this.m_ftueFrame.addWidget(this.m_startGameButton = new FarmAnimatedTextButton(m_window.ftue_mc.accept_bt,ZLocUtils.t_pk("Dialogs","FishingTooltip_Buton"),this.startGame));
         if(!Global.player.getSeenFlag(FTUE_FLAG))
         {
            this.m_ftueFrame.visible = true;
            this.m_startGameButton.visible = true;
            Global.player.setSeenFlag(FTUE_FLAG);
         }
         else
         {
            this.m_ftueFrame.visible = true;
            this.m_startGameButton.visible = false;
            this.startGame();
         }
      }
      
      private function startGame(event:Event = null) : void
      {
         this.m_startGameButton.visible = false;
         this.m_timer.start();
         Global.stage.addEventListener(MouseEvent.CLICK,this.onMouseClik);
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function stopGame(event:Event) : void
      {
         Global.world.removeEventListener(HUDHomeWidget.TRAVEL_HOME,this.stopGame);
         this.close();
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var rodMovieClip:MovieClip = this.m_rod.element as MovieClip;
         rodMovieClip.rotation += this.m_direction * this.m_gameSpeed;
         if(rodMovieClip.rotation > 45 && this.m_direction > 0)
         {
            this.m_direction *= -1;
         }
         if(rodMovieClip.rotation < -45 && this.m_direction < 0)
         {
            this.m_direction *= -1;
         }
      }
      
      private function decrementSeconds(event:Event) : void
      {
         --this.m_timeLeft;
         this.m_timerField.text = ":" + this.m_timeLeft + "s";
         if(this.m_timeLeft <= 0)
         {
            this.m_timer.stop();
            this.m_miniGameComplete = true;
            this.reelInFish();
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      private function onMouseClik(event:MouseEvent) : void
      {
         var rodMovieClip:MovieClip = null;
         var scaleTween:TweenLite = null;
         if(!this.m_miniGameComplete)
         {
            rodMovieClip = this.m_rod.element as MovieClip;
            scaleTween = null;
            if(rodMovieClip.rotation > -20 && rodMovieClip.rotation < 20)
            {
               ++this.m_numClicks;
               this.m_counterField.text = "x" + this.m_numClicks.toString();
               this.m_gameSpeed = Math.min(20,this.m_gameSpeed + Math.random() * 1);
               scaleTween = new TweenLite(this.m_counterWrapper.element as MovieClip,0.35,{
                  "scaleX":3,
                  "scaleY":3,
                  "ease":Quad.easeInOut,
                  "onComplete":function():void
                  {
                     scaleTween.reverse();
                  },
                  "onReverseComplete":function():void
                  {
                     if(m_counterWrapper.element as MovieClip != null)
                     {
                        (m_counterWrapper.element as MovieClip).scaleX = 1;
                        (m_counterWrapper.element as MovieClip).scaleY = 1;
                     }
                  }
               });
            }
         }
      }
      
      override public function close() : void
      {
         Global.stage.removeEventListener(MouseEvent.CLICK,this.onMouseClik);
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         Global.world.dispatchEvent(new Event(FISHING_CATCH));
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.decrementSeconds);
         }
         this.m_miniGameComplete = true;
         this.showDoober();
         super.close();
      }
      
      private function showDoober() : void
      {
         var collectibleName:String = null;
         var farmItem:FarmItem = null;
         var screen:Vector2 = null;
         var fishingDoober:FishingRewardView = null;
         if(this.m_transactionResult != null && this.m_transactionResult.hasOwnProperty("name") && this.m_transactionResult.hasOwnProperty("collection"))
         {
            collectibleName = this.m_transactionResult.name as String;
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(collectibleName);
            if(farmItem != null)
            {
               screen = IsoMath.tilePosToPixelPos(this.m_extraData.x,this.m_extraData.y,0);
               fishingDoober = new FishingRewardView("fishing",1,farmItem.iconRelativeUrl,screen);
               fishingDoober.startLoad();
               fishingDoober.x = screen.x;
               fishingDoober.y = screen.y;
               GlobalEngine.viewport.uiBase.addChild(fishingDoober);
            }
         }
      }
      
      private function reelInFish() : void
      {
         if(this.m_transactionResult != null && this.m_miniGameComplete)
         {
            if(this.m_transactionResult.hasOwnProperty("name") && this.m_transactionResult.hasOwnProperty("collection"))
            {
               TransactionManager.addTransaction(new TFishing(TFishing.MINIGAME_BONUS,{"count":this.m_numClicks},function(result:Object):void
               {
                  FishingDerbyManager.instance.setMiniGamePrize(result);
               }));
            }
            ToasterManager.getInstance().add(new FishingDerbyToasterWindow(this.m_transactionResult));
            FishingDerbyManager.conditionallyShowCollectionCompleteToaster(this.m_transactionResult);
            FishingDerbyManager.conditionallyShowUnlockBootCollection(this.m_transactionResult);
            this.close();
         }
         else if(this.m_transactionResult == null && this.m_miniGameComplete)
         {
            this.m_spinner.visible = true;
            (this.m_spinner.element as MovieClip).play();
         }
      }
   }
}

