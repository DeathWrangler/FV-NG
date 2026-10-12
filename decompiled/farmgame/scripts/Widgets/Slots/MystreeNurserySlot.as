package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.MystreeNursery;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.MystreeNurseryManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.MystreeNurseryWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MystreeNurserySlot extends ZwSlotFrame
   {
      
      private static const STAGE:String = "stage_";
      
      private static const TEND:String = "_tend";
      
      private static const X:String = "x";
      
      private var m_timer:Timer;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_tendButton:FarmAnimatedTextButton;
      
      private var m_plantButton:FarmAnimatedTextButton;
      
      private var m_getButton:FarmAnimatedTextButton;
      
      private var m_levelMc:MovieClip;
      
      private var m_tendMc:MovieClip;
      
      private var m_levelTf:ZwTextField;
      
      private var m_bucketsRequired:ZwTextField;
      
      private var m_timerText:String = "";
      
      private var m_lock:MovieClip;
      
      private var m_plantWait:Vector.<ZwWidget>;
      
      private var m_plantTend:Vector.<ZwWidget>;
      
      private var m_plantMystree:MovieClip;
      
      private var m_timeRemaining:int = 0;
      
      private var m_plotId:String;
      
      private var m_window:MystreeNurseryWindow;
      
      public function MystreeNurserySlot(element:DisplayObject, window:MystreeNurseryWindow)
      {
         var stageWidget:ZwWidget = null;
         var unlockCost:int = 0;
         var text:String = null;
         var bucketSpendText:String = null;
         this.m_timer = new Timer(30 * 1000);
         super(element);
         this.m_window = window;
         if(m_element.hasOwnProperty("buyCash_bt"))
         {
            unlockCost = MystreeNurseryManager.PLOT_UNLOCK_COST;
            addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element.buyCash_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeBuyButtonText"),unlockCost.toString(),this.onBuyClick),false);
         }
         if(m_element.hasOwnProperty("tend_mc"))
         {
            this.m_tendMc = m_element.tend_mc as MovieClip;
            if(m_element.tend_mc.hasOwnProperty("tend_bt"))
            {
               this.m_tendButton = addWidget(new FarmAnimatedTextButton(m_element.tend_mc.tend_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeTendButtonText"),this.onTendClick),true) as FarmAnimatedTextButton;
               this.m_tendButton.visible = true;
            }
            if(m_element.tend_mc.hasOwnProperty("bucketspend_tf"))
            {
               text = MystreeNursery.TEND_SB_QUANTITY_PREFIX;
               bucketSpendText = "x" + Global.farmGameSettingsManager.getString(MystreeNursery.TEND_SB_QUANTITY_PREFIX + this.saplingLevel);
               this.m_bucketsRequired = new ZwTextField(m_element.tend_mc.bucketspend_tf,bucketSpendText);
               addWidget(this.m_bucketsRequired,true);
               this.m_bucketsRequired.visible = true;
            }
            this.m_tendMc.visible = true;
         }
         if(m_element.hasOwnProperty("plant_bt"))
         {
            addWidget(this.m_plantButton = new FarmAnimatedTextButton(m_element.plant_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreePlantButtonText"),this.onPlantClick),false);
         }
         if(m_element.hasOwnProperty("get_bt"))
         {
            addWidget(this.m_getButton = new FarmAnimatedTextButton(m_element.get_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeGetButtonText"),this.onGetMystreeClick),false);
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
            this.m_plantMystree = m_element.stage_place as MovieClip;
         }
         var propName:String = "";
         this.m_plantTend = new Vector.<ZwWidget>();
         this.m_plantWait = new Vector.<ZwWidget>();
         for(var i:int = 0; i < 5; i++)
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
      
      private function getTimeRemaining() : String
      {
         var timeLastTended:int = 0;
         var currentTime:int = 0;
         var hours:int = 0;
         var minutes:int = 0;
         if(this.m_plotId)
         {
            timeLastTended = MystreeNurseryManager.getInstance().getNurseryInstance().getSaplingTendStartFor(this.m_plotId);
            currentTime = GlobalEngine.serverTime / 1000;
            this.m_timeRemaining = MystreeNurseryManager.getInstance().getNurseryInstance().getTotalTendTimeFor(this.saplingLevel) - (currentTime - timeLastTended);
            hours = this.m_timeRemaining / 3600;
            minutes = (this.m_timeRemaining - hours * 3600) / 60;
            this.m_timerText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"mystreeTimer",{
               "hours":hours,
               "minutes":minutes
            });
         }
         return this.m_timerText;
      }
      
      private function onGetMystreeClick(event:Event) : void
      {
         MystreeNurseryManager.getInstance().getMystree(this.m_plotId);
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
         this.m_plantWait[stageNo].visible = true;
      }
      
      private function onPlantClick(event:Event) : void
      {
         MystreeNurseryManager.getInstance().plantSapling(this.m_plotId);
         this.refreshSlotData();
         this.stateTend();
         this.updateLevelText();
         this.m_bucketsRequired.text = X + Global.farmGameSettingsManager.getString(MystreeNursery.TEND_SB_QUANTITY_PREFIX + this.saplingLevel);
      }
      
      private function onTendClick(event:Event) : void
      {
         var hasBuckets:Boolean = MystreeNurseryManager.getInstance().hasSunshineBuckets(this.m_plotId);
         MystreeNurseryManager.getInstance().tendSapling(this.m_plotId);
         if(hasBuckets)
         {
            this.m_window.updateSunshineBuckets();
            this.refreshSlotData();
            if(this.saplingLevel <= 5)
            {
               this.stateWait();
            }
            else
            {
               this.stateGetMystree();
            }
            this.updateLevelText();
         }
         else if(this.m_window)
         {
            this.m_window.close();
         }
      }
      
      private function onBuyClick(event:Event) : void
      {
         var unlockcost:int = MystreeNurseryManager.PLOT_UNLOCK_COST;
         UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeNurseryBuyPlot_friction",{"cashQuantity":unlockcost.toString()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onBuy,"",true);
      }
      
      private function onBuy(e:Event = null) : void
      {
         MystreeNurseryManager.getInstance().onBuyPlot(this.m_plotId);
         this.refreshSlotData();
         this.statePlant();
      }
      
      private function stateLocked() : void
      {
         this.m_buyButton.visible = true;
         this.m_lock.visible = true;
      }
      
      private function statePlant() : void
      {
         this.m_plantButton.visible = true;
         this.updateSpeedUpPossible();
      }
      
      private function stateTend() : void
      {
         this.showTendSaplingStage(this.saplingLevel - 1);
         this.m_levelMc.visible = true;
         this.m_levelTf.visible = true;
         this.m_tendMc.visible = true;
         this.m_tendButton.visible = true;
         this.m_bucketsRequired.visible = true;
         this.m_levelMc.visible = true;
         this.updateSpeedUpPossible();
      }
      
      private function stateWait() : void
      {
         this.showWaitSaplingStage(this.saplingLevel - 1);
         this.m_levelMc.visible = true;
         this.m_levelTf.visible = true;
         this.m_levelMc.visible = true;
         if(this.saplingLevel > 0)
         {
            this.putTooltipText(null);
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.putTooltipText);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.putTooltipText);
            this.m_timer.start();
         }
         this.updateSpeedUpPossible();
      }
      
      private function putTooltipText(e:TimerEvent) : void
      {
         if(Boolean(this.m_plantWait) && Boolean(this.m_plantWait[this.saplingLevel - 1]))
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
         this.m_plantMystree.visible = true;
         this.m_plantMystree.play();
         this.m_getButton.visible = true;
         this.m_levelTf.visible = true;
         this.updateSpeedUpPossible();
      }
      
      private function refreshSlotData() : void
      {
         this.m_buyButton.visible = false;
         this.m_tendMc.visible = false;
         this.m_tendButton.visible = false;
         this.m_bucketsRequired.visible = false;
         this.m_plantButton.visible = false;
         this.m_getButton.visible = false;
         this.m_levelMc.visible = false;
         this.m_levelTf.visible = false;
         this.m_lock.visible = false;
         for(var i:int = 0; i < this.m_plantWait.length; i++)
         {
            this.m_plantWait[i].detachTooltip();
            this.m_plantWait[i].visible = false;
            this.m_plantTend[i].visible = false;
         }
         this.m_plantMystree.visible = false;
         this.hideAllTendSaplings();
         this.hideAllWaitSaplings();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.refreshSlotData();
         this.m_plotId = data.plotNumber;
         this.updateLevelText();
         this.m_bucketsRequired.text = X + Global.farmGameSettingsManager.getString(MystreeNursery.TEND_SB_QUANTITY_PREFIX + this.saplingLevel);
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
            case 6:
               this.stateGetMystree();
               break;
            default:
               if(!MystreeNurseryManager.getInstance().canTend(this.m_plotId))
               {
                  this.stateWait();
                  break;
               }
               this.stateTend();
         }
      }
      
      override public function release() : void
      {
         this.m_buyButton = null;
         this.m_tendButton = null;
         this.m_plantButton = null;
         this.m_getButton = null;
         this.m_levelTf = null;
         this.m_bucketsRequired = null;
         this.m_tendMc = null;
         this.m_lock = null;
         for(var i:int = 0; i < this.m_plantWait.length; i++)
         {
            this.m_plantWait[i].detachTooltip();
         }
         this.m_plantWait = null;
         this.m_plantTend = null;
         this.m_plantMystree = null;
         this.m_plotId = null;
         this.m_window = null;
         this.m_timer.stop();
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.putTooltipText);
         super.release();
      }
      
      private function get saplingLevel() : int
      {
         return MystreeNurseryManager.getInstance().getNurseryInstance().getSaplingLevelFor(this.m_plotId);
      }
      
      private function updateLevelText() : void
      {
         this.m_levelTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"mystreeSlotLevel",{"levelNumber":this.saplingLevel.toString()});
      }
      
      private function updateSpeedUpPossible() : void
      {
         var enable:Boolean = false;
         if(MystreeNurseryManager.getInstance().isAnySaplingWaiting())
         {
            enable = true;
         }
         this.m_window.enableSpeedUp(enable);
      }
   }
}

