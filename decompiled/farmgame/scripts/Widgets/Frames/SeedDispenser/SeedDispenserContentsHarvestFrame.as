package Widgets.Frames.SeedDispenser
{
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.SeedDispenserHarvestFManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.SeedDispenserManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.SeedDispenser.SeedDispenserContentsWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public final class SeedDispenserContentsHarvestFrame extends ZwFrame
   {
      
      private var m_parentWindow:SeedDispenserContentsWindow;
      
      private var m_item:FarmItem;
      
      private var m_titleTextField:FarmTextField;
      
      private var m_countTextField:FarmTextField;
      
      private var m_moreTextField:FarmTextField;
      
      private var m_timerTextField:FarmTextField;
      
      private var m_timer:Timer;
      
      private var m_readyFrame:ZwFrame;
      
      private var m_harvestTextField:FarmTextField;
      
      private var m_harvestButton:FarmAnimatedTextButton;
      
      private var m_speedUpFrame:ZwFrame;
      
      private var m_costTextField:FarmTextField;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      public function SeedDispenserContentsHarvestFrame(element:DisplayObject, parentWindow:SeedDispenserContentsWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         this.m_titleTextField = addWidget(new FarmTextField(m_element.title_tf,"")) as FarmTextField;
         this.m_countTextField = addWidget(new FarmTextField(m_element.count_tf,"")) as FarmTextField;
         this.m_moreTextField = addWidget(new FarmTextField(m_element.more_tf,"")) as FarmTextField;
         this.m_timerTextField = addWidget(new FarmTextField(m_element.timer_tf,"")) as FarmTextField;
         this.m_readyFrame = addWidget(new ZwFrame(m_element.ready_mc)) as ZwFrame;
         this.m_harvestTextField = this.m_readyFrame.addWidget(new FarmTextField(m_element.ready_mc.generic_tf,ZLocUtils.t("Dialogs","SeedDispenser_HarvestMessage",{"item":this.m_parentWindow.building.getItem().friendlyTitle}))) as FarmTextField;
         this.m_harvestButton = this.m_readyFrame.addWidget(new FarmAnimatedTextButton(m_element.ready_mc.harvest_bt,ZLocUtils.t("Dialogs","SeedDispenser_HarvestNow"),this.onHarvestButtonClick)) as FarmAnimatedTextButton;
         this.m_speedUpFrame = addWidget(new ZwFrame(m_element.speed_mc)) as ZwFrame;
         this.m_costTextField = this.m_readyFrame.addWidget(new FarmTextField(m_element.speed_mc.cost_tf,String(this.m_parentWindow.building.getHarvestReadyNowCashPrice()))) as FarmTextField;
         this.m_buyButton = this.m_readyFrame.addWidget(new FarmAnimatedTextButton(m_element.speed_mc.buy_bt,ZLocUtils.t("Dialogs","SeedDispenser_SpeedUp"),this.onBuyButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         this.m_titleTextField = null;
         this.m_countTextField = null;
         this.m_moreTextField = null;
         this.m_timerTextField = null;
         this.m_readyFrame = null;
         this.m_harvestTextField = null;
         this.m_harvestButton = null;
         this.m_speedUpFrame = null;
         this.m_costTextField = null;
         this.m_buyButton = null;
         this.stopTimer();
         super.release();
      }
      
      public function populate(item:FarmItem) : void
      {
         this.m_item = item;
         this.refresh();
      }
      
      public function refresh() : void
      {
         var harvester:SeedDispenserHarvestFManager = null;
         if(Boolean(this.m_parentWindow) && Boolean(this.m_parentWindow.building))
         {
            harvester = this.m_parentWindow.building.harvester as SeedDispenserHarvestFManager;
            if(harvester)
            {
               if(harvester.harvestReward)
               {
                  this.m_titleTextField.text = ZLocUtils.t("Dialogs","SeedDispenser_HarvestSeeds");
                  this.m_moreTextField.text = ZLocUtils.t("Dialogs","SeedDispenser_MoreSeeds");
                  this.m_countTextField.text = String(SeedDispenserManager.getSeedPackageSize(this.m_parentWindow.featureName,this.m_parentWindow.building.expand.storageLevel));
               }
               else
               {
                  this.m_titleTextField.text = ZLocUtils.t("Dialogs","SeedDispenser_HarvestCoins");
                  this.m_moreTextField.text = ZLocUtils.t("Dialogs","SeedDispenser_MoreCoins");
                  this.m_countTextField.text = String(harvester.getHarvestAmount());
               }
               switch(this.m_parentWindow.building.getState())
               {
                  case FeatureBuilding.STATE_RIPE:
                     this.m_readyFrame.visible = this.m_harvestButton.enabled = true;
                     this.m_speedUpFrame.visible = this.m_buyButton.enabled = false;
                     this.m_moreTextField.visible = false;
                     this.stopTimer();
                     break;
                  case FeatureBuilding.STATE_BARE:
                     this.m_speedUpFrame.visible = this.m_buyButton.enabled = true;
                     this.m_moreTextField.visible = true;
                     this.m_readyFrame.visible = this.m_harvestButton.enabled = false;
                     this.startTimer();
               }
            }
         }
      }
      
      private function startTimer() : void
      {
         if(!this.m_timer)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         if(this.m_timerTextField)
         {
            this.m_timerTextField.text = "";
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var timeLeft:int = 0;
         var parsedTime:Array = null;
         var formattedTime:String = null;
         if(Boolean(this.m_timerTextField) && Boolean(this.m_parentWindow) && Boolean(this.m_parentWindow.building))
         {
            timeLeft = this.m_parentWindow.building.getGrowTimeLeft() / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(timeLeft > 0)
            {
               parsedTime = FarmGameUtil.parseTimeLeft(timeLeft);
               formattedTime = FarmGameUtil.numberToStringPadZeros(parsedTime[1]) + ":" + FarmGameUtil.numberToStringPadZeros(parsedTime[2]) + ":" + FarmGameUtil.numberToStringPadZeros(parsedTime[3]);
               this.m_timerTextField.text = formattedTime;
            }
            else
            {
               this.refresh();
            }
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var building:FeatureBuilding = null;
         if(this.m_buyButton.enabled)
         {
            this.m_buyButton.enabled = false;
            building = this.m_parentWindow.building;
            if(building)
            {
               building.frictionlessHarvestReadyNow(this.frictionlessHarvestReadyNowCallback);
               FarmStatsManager.count(building.getItemName(),"instaharvest","dialog");
            }
         }
      }
      
      private function frictionlessHarvestReadyNowCallback(result:Object) : void
      {
         this.refresh();
      }
      
      private function onHarvestButtonClick(event:MouseEvent) : void
      {
         if(this.m_harvestButton.enabled)
         {
            this.m_parentWindow.building.onClick();
            this.m_parentWindow.close();
         }
      }
   }
}

