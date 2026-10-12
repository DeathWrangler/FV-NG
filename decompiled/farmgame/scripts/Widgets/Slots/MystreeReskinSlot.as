package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.IMystreeReskinManager;
   import Managers.MystreeReskinManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.IMystreeReskinWindow;
   import Widgets.Windows.MystreeReskinWindow;
   import Widgets.Windows.MystreeReskinWindowWithEMH;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class MystreeReskinSlot extends ZwSlotFrame
   {
      
      private static const STAGE:String = "stage_";
      
      private static const TEND:String = "_tend";
      
      protected static const X:String = "x";
      
      private var m_timer:Timer;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_tendButton:FarmAnimatedTextButton;
      
      private var m_plantButton:FarmAnimatedTextButton;
      
      private var m_getButton:FarmAnimatedTextButton;
      
      private var m_levelMc:MovieClip;
      
      private var m_tendMc:MovieClip;
      
      protected var m_levelTf:ZwTextField;
      
      protected var m_bucketsRequired:ZwTextField;
      
      private var m_timerText:String = "";
      
      private var m_lock:MovieClip;
      
      private var m_plantWait:Vector.<ZwWidget>;
      
      private var m_plantTend:Vector.<ZwWidget>;
      
      private var m_plantMystree:MovieClip;
      
      private var m_getMystree:MovieClip;
      
      private var m_timeRemaining:int = 0;
      
      private var m_featureName:String = "";
      
      protected var m_window:IMystreeReskinWindow;
      
      protected var m_plotId:String;
      
      public function MystreeReskinSlot(element:DisplayObject, featureName:String, window:IMystreeReskinWindow)
      {
         var stageWidget:ZwWidget = null;
         var unlockCost:int = 0;
         var levelData:Dictionary = null;
         var bucketNeeded:int = 0;
         var bucketSpendText:String = null;
         this.m_timer = new Timer(30 * 1000);
         super(element);
         this.m_featureName = featureName;
         this.m_window = window;
         if(m_element.hasOwnProperty("buyCash_bt"))
         {
            unlockCost = this.manager.getPlotUnlockCost();
            addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element.buyCash_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_BuyButtonText"),unlockCost.toString(),this.onBuyClick),false);
         }
         if(m_element.hasOwnProperty("tend_mc"))
         {
            this.m_tendMc = m_element.tend_mc as MovieClip;
            if(m_element.tend_mc.hasOwnProperty("tend_bt"))
            {
               this.m_tendButton = addWidget(new FarmAnimatedTextButton(m_element.tend_mc.tend_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_TendButtonText"),this.onTendClick),true) as FarmAnimatedTextButton;
               this.m_tendButton.visible = true;
            }
            if(m_element.tend_mc.hasOwnProperty("bucketspend_tf"))
            {
               levelData = this.manager.getLevelData(this.saplingLevel.toString());
               bucketNeeded = levelData.hasOwnProperty("quantity") ? int(parseInt(levelData["quantity"])) : 0;
               bucketSpendText = "x" + bucketNeeded.toString();
               this.m_bucketsRequired = new ZwTextField(m_element.tend_mc.bucketspend_tf,bucketSpendText);
               addWidget(this.m_bucketsRequired,true);
               this.m_bucketsRequired.visible = true;
            }
            this.m_tendMc.visible = true;
         }
         if(m_element.hasOwnProperty("plant_bt"))
         {
            addWidget(this.m_plantButton = new FarmAnimatedTextButton(m_element.plant_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_PlantButtonText"),this.onPlantClick),false);
         }
         if(m_element.hasOwnProperty("get_bt"))
         {
            addWidget(this.m_getButton = new FarmAnimatedTextButton(m_element.get_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GetButtonText"),this.onGetMystreeClick),false);
         }
         if(m_element.hasOwnProperty("level_mc"))
         {
            this.m_levelMc = m_element.level_mc as MovieClip;
            if(m_element.level_mc.hasOwnProperty("level_tf"))
            {
               this.m_levelTf = new ZwTextField(m_element.level_mc.level_tf,"");
               addWidget(this.m_levelTf,false);
            }
            this.m_levelMc.visible = true;
         }
         if(m_element.hasOwnProperty("lock_mc"))
         {
            this.m_lock = m_element.lock_mc as MovieClip;
         }
         if(m_element.hasOwnProperty("stage_place"))
         {
            this.m_getMystree = m_element.stage_place as MovieClip;
         }
         if(m_element.hasOwnProperty("stage_empty"))
         {
            this.m_plantMystree = m_element.stage_empty as MovieClip;
         }
         var propName:String = "";
         this.m_plantTend = new Vector.<ZwWidget>();
         this.m_plantWait = new Vector.<ZwWidget>();
         var maxLevel:Number = this.manager.getMaxLevel();
         for(var i:int = 0; i < maxLevel - 1; i++)
         {
            propName = STAGE + i + TEND;
            if(m_element.hasOwnProperty(propName))
            {
               stageWidget = new ZwWidget(m_element[propName]);
               this.m_plantTend.push(stageWidget);
            }
            propName = STAGE + i;
            if(m_element.hasOwnProperty(propName))
            {
               stageWidget = new ZwWidget(m_element[propName]);
               this.m_plantWait.push(stageWidget);
            }
         }
      }
      
      public function get manager() : IMystreeReskinManager
      {
         return MystreeReskinManager.getInstance(this.m_featureName);
      }
      
      private function getTimeRemaining() : String
      {
         var timeLastTended:int = 0;
         var currentTime:int = 0;
         var hours:int = 0;
         var minutes:int = 0;
         if(this.m_plotId)
         {
            timeLastTended = this.manager.getSaplingTendStartFor(this.m_plotId);
            currentTime = GlobalEngine.serverTime / 1000;
            this.m_timeRemaining = this.manager.getTotalTendTimeFor(this.saplingLevel) - (currentTime - timeLastTended);
            hours = this.m_timeRemaining / 3600;
            minutes = (this.m_timeRemaining - hours * 3600) / 60;
            this.m_timerText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Timer",{
               "hours":hours,
               "minutes":minutes
            });
         }
         return this.m_timerText;
      }
      
      protected function onGetMystreeClick(event:Event) : void
      {
         this.manager.getMystree(this.m_plotId);
         if(this.m_window)
         {
            this.m_window.close();
         }
      }
      
      private function hideAllTendSaplings() : void
      {
         for(var i:int = 0; i < this.m_plantTend.length; i++)
         {
            this.m_plantTend[i].visible = false;
         }
      }
      
      private function showTendSaplingStage(stageNo:int) : void
      {
         this.hideAllTendSaplings();
         this.m_plantTend[stageNo].visible = true;
      }
      
      private function hideAllWaitSaplings() : void
      {
         for(var i:int = 0; i < this.m_plantWait.length; i++)
         {
            this.m_plantWait[i].visible = false;
         }
      }
      
      private function showWaitSaplingStage(stageNo:int) : void
      {
         this.hideAllTendSaplings();
         if(stageNo < this.m_plantWait.length)
         {
            this.m_plantWait[stageNo].visible = true;
         }
      }
      
      public function onPlantClick(event:Event) : void
      {
         this.manager.plantSapling(this.m_plotId);
         this.refreshSlotData();
         this.stateTend();
         this.updateLevelText();
         var levelData:Dictionary = this.manager.getLevelData(this.saplingLevel.toString());
         var bucketNeeded:int = levelData.hasOwnProperty("quantity") ? int(parseInt(levelData["quantity"])) : 0;
         if(this.m_bucketsRequired)
         {
            this.m_bucketsRequired.text = X + bucketNeeded.toString();
         }
         if(this.m_featureName == "mystrees_2020")
         {
            this.onTendClick(event);
         }
      }
      
      protected function onTendClick(event:Event) : void
      {
         var hasBuckets:Boolean = this.manager.hasSunshineBuckets(this.m_plotId);
         this.manager.tendSapling(this.m_plotId);
         if(hasBuckets)
         {
            this.tendSapling();
         }
         else if(this.m_window)
         {
            this.m_window.close();
         }
      }
      
      protected function tendSapling() : void
      {
         this.m_window.updateSunshineBuckets();
         this.refreshSlotData();
         if(this.saplingLevel <= this.manager.getMaxLevel() - 1)
         {
            if(this.m_window.isNPCAnimationAvailable())
            {
               this.showTendSaplingStage(this.saplingLevel - 1);
               this.m_window.animateNpc(this.stateWait);
            }
            else
            {
               this.stateWait();
            }
         }
         else
         {
            this.stateGetMystree();
         }
         this.updateLevelText();
         this.updateSpeedUpCashAmount();
      }
      
      private function onBuyClick(event:Event) : void
      {
         var unlockcost:int = this.manager.getPlotUnlockCost();
         UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_BuyPlot_friction",{"cashQuantity":unlockcost.toString()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onBuy,"",true);
      }
      
      private function onBuy(e:GenericPopupEvent) : void
      {
         if(Boolean(e) && e.button == GenericPopup.YES)
         {
            if(this.manager.onBuyPlot(this.m_plotId))
            {
               this.refreshSlotData();
               this.statePlant();
            }
         }
      }
      
      private function stateLocked() : void
      {
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = true;
         }
         if(this.m_lock)
         {
            this.m_lock.visible = true;
         }
      }
      
      protected function statePlant() : void
      {
         if(this.m_plantButton)
         {
            this.m_plantButton.visible = true;
         }
         if(this.m_plantMystree)
         {
            this.m_plantMystree.visible = true;
         }
         this.updateSpeedUpPossible();
         this.updateSpeedupViaAdsPossible();
         this.enableSpeedUp(this.m_plotId);
      }
      
      protected function stateTend() : void
      {
         this.showTendSaplingStage(this.saplingLevel - 1);
         this.m_levelMc.visible = true;
         this.m_levelTf.visible = true;
         this.m_tendMc.visible = true;
         this.m_tendButton.visible = true;
         if(this.m_bucketsRequired)
         {
            this.m_bucketsRequired.visible = true;
         }
         this.m_levelMc.visible = true;
         this.updateSpeedUpPossible();
         this.updateSpeedupViaAdsPossible();
         this.enableSpeedUp(this.m_plotId);
      }
      
      public function stateWait() : void
      {
         this.hideAllTendSaplings();
         this.showWaitSaplingStage(this.saplingLevel - 1);
         this.m_levelMc.visible = true;
         this.m_levelTf.visible = true;
         this.m_levelMc.visible = true;
         if(this.saplingLevel > 0 && this.saplingLevel < MystreeReskinManager.getInstance(this.m_featureName).getMaxLevel())
         {
            this.putTooltipText(null);
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.putTooltipText);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.putTooltipText);
            this.m_timer.start();
         }
         this.updateSpeedUpPossible();
         this.updateSpeedupViaAdsPossible();
         this.enableSpeedUp(this.m_plotId);
      }
      
      private function putTooltipText(e:TimerEvent) : void
      {
         if(Boolean(this.m_plantWait) && Boolean(this.saplingLevel > MystreeReskinManager.PLOT_STATE_EMPTY) && this.saplingLevel < MystreeReskinManager.getInstance(this.m_featureName).getMaxLevel())
         {
            if(this.m_plantWait[this.saplingLevel - 1].tooltip)
            {
               this.m_plantWait[this.saplingLevel - 1].detachTooltip();
            }
            this.m_plantWait[this.saplingLevel - 1].attachTooltip(new FarmTextTooltip(this.getTimeRemaining()));
         }
      }
      
      private function stateGetMystree() : void
      {
         this.m_getMystree.visible = true;
         this.m_getMystree.play();
         this.m_getButton.visible = true;
         this.m_levelTf.visible = true;
         this.updateSpeedUpPossible();
         this.updateSpeedupViaAdsPossible();
         this.enableSpeedUp(this.m_plotId);
      }
      
      protected function refreshSlotData() : void
      {
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = false;
         }
         this.m_tendMc.visible = false;
         this.m_tendButton.visible = false;
         if(this.m_bucketsRequired)
         {
            this.m_bucketsRequired.visible = false;
         }
         if(this.m_plantButton)
         {
            this.m_plantButton.visible = false;
         }
         this.m_getButton.visible = false;
         this.m_levelMc.visible = false;
         this.m_levelTf.text = "";
         this.m_levelTf.visible = false;
         this.updateSpeedUpCashAmount();
         if(this.m_lock)
         {
            this.m_lock.visible = false;
         }
         for(var i:int = 0; i < this.m_plantWait.length; i++)
         {
            this.m_plantWait[i].detachTooltip();
            this.m_plantWait[i].visible = false;
            this.m_plantTend[i].visible = false;
         }
         if(this.m_plantMystree)
         {
            this.m_plantMystree.visible = false;
         }
         this.m_getMystree.visible = false;
         this.hideAllTendSaplings();
         this.hideAllWaitSaplings();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.refreshSlotData();
         this.m_plotId = data.plotNumber;
         this.updateLevelText();
         var levelData:Dictionary = this.manager.getLevelData(this.saplingLevel.toString());
         var bucketNeeded:int = levelData.hasOwnProperty("quantity") ? int(parseInt(levelData["quantity"])) : 0;
         if(this.m_bucketsRequired)
         {
            this.m_bucketsRequired.text = X + bucketNeeded.toString();
         }
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.putTooltipText);
         }
         switch(this.saplingLevel)
         {
            case -1:
               this.stateLocked();
               break;
            case 0:
               this.statePlant();
               break;
            case this.manager.getMaxLevel():
               this.stateGetMystree();
               break;
            default:
               if(!this.manager.canTend(this.m_plotId))
               {
                  this.stateWait();
                  break;
               }
               this.stateTend();
         }
      }
      
      override public function release() : void
      {
         if(this.m_buyButton)
         {
            this.m_buyButton = null;
         }
         if(this.m_tendButton)
         {
            this.m_tendButton.release();
         }
         this.m_tendButton = null;
         this.m_plantButton = null;
         this.m_getButton = null;
         this.m_levelTf = null;
         if(this.m_bucketsRequired)
         {
            this.m_bucketsRequired = null;
         }
         this.m_tendMc = null;
         if(this.m_lock)
         {
            this.m_lock = null;
         }
         for(var i:int = 0; i < this.m_plantWait.length; i++)
         {
            this.m_plantWait[i].detachTooltip();
         }
         this.m_plantWait = null;
         this.m_plantTend = null;
         if(this.m_plantMystree)
         {
            this.m_plantMystree = null;
         }
         this.m_getMystree = null;
         this.m_plotId = null;
         this.m_window = null;
         this.m_timer.stop();
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.putTooltipText);
         super.release();
      }
      
      public function get saplingLevel() : int
      {
         return this.manager.getSaplingLevelFor(this.m_plotId);
      }
      
      protected function updateLevelText() : void
      {
         if(this.saplingLevel == -1)
         {
            this.m_levelTf.text = "";
         }
         else if(this.m_featureName == "mystrees_2020")
         {
            this.m_levelTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_SlotLevel",{"levelNumber":(this.saplingLevel - 2).toString()});
         }
         else
         {
            this.m_levelTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_SlotLevel",{"levelNumber":(this.saplingLevel - 1).toString()});
         }
      }
      
      protected function updateSpeedUpCashAmount() : void
      {
         var cashAmount:int = 0;
         var cashAmt:int = 0;
         var windowName:String = this.manager.getWindowName();
         if(windowName == "AdventurersCamp")
         {
            cashAmount = this.manager.getSpeedUpCost();
            (this.m_window as MystreeReskinWindowWithEMH).setSpeedBtAmount(cashAmount);
            (this.m_window as MystreeReskinWindowWithEMH).setnoOfAnimalAvailableToTend();
         }
         if(windowName == "FurryAndFabulous")
         {
            cashAmt = this.manager.getSpeedUpCost();
            (this.m_window as MystreeReskinWindow).setSpeedBtAmount(cashAmt);
         }
         if(windowName == "CarnivalParades")
         {
            cashAmt = this.manager.getSpeedUpCost();
            (this.m_window as MystreeReskinWindow).setSpeedBtAmount(cashAmt);
         }
      }
      
      protected function updateSpeedUpPossible() : void
      {
         var enable:Boolean = false;
         if(this.manager.isAnySaplingWaiting())
         {
            enable = true;
         }
         this.m_window.enableSpeedUp(enable);
      }
      
      protected function updateSpeedupViaAdsPossible() : void
      {
         var enable:Boolean = false;
         if(this.manager.isAnySaplingWaiting() && this.manager.isAdBtnShouldbeAvailable())
         {
            enable = true;
         }
         this.m_window.enableWatchToSpeedup(enable);
      }
      
      protected function enableSpeedUp(plotId:String = "") : void
      {
      }
   }
}

