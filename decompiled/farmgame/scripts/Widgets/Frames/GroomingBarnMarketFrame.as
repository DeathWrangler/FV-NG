package Widgets.Frames
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.GroomingBarnManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.GroomingBarnSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GroomingBarnWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GroomingBarnMarketFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:GroomingBarnWindow;
      
      private var m_askButton:FarmAnimatedTextButton = null;
      
      private var m_makeButton:FarmAnimatedTextButton = null;
      
      public function GroomingBarnMarketFrame(element:DisplayObject, parentWindow:GroomingBarnWindow)
      {
         this.m_window = parentWindow;
         super(element);
         if(m_element.hasOwnProperty("ask_bt"))
         {
            addWidget(this.m_askButton = new FarmAnimatedTextButton(m_element.ask_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,GroomingBarnManager.getInstance().WINDOW_NAME + "_askText"),this.onAskGroomingBrushClick),true);
         }
         if(m_element.hasOwnProperty("makebrush_bt"))
         {
            addWidget(this.m_makeButton = new FarmAnimatedTextButton(m_element.makebrush_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,GroomingBarnManager.getInstance().WINDOW_NAME + "_craftText"),this.onMakeGroomingBrushClick),true);
         }
         if(m_element.hasOwnProperty("subtitle1_tf"))
         {
            addWidget(new ZwTextField(m_element.subtitle1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,GroomingBarnManager.getInstance().WINDOW_NAME + "_subtitle2Text")),true);
         }
         if(!GroomingBarnManager.getInstance().canPostFeed())
         {
            this.disableAskButton();
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GroomingBarnSlot(slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var animalXML:XML = null;
         var data:Object = null;
         var item:FarmItem = null;
         var yearlingsData:XML = Global.farmGameSettingsManager.getFeatureXML("Yearlings");
         for each(animalXML in yearlingsData.animals.animal)
         {
            data = new Object();
            item = Global.farmGameSettingsManager.getFarmItemByName(animalXML.@name);
            data.name = animalXML.@name;
            data.friendlyName = ZLocUtils.tk_pk_asTitle(item.friendlyName);
            data.currency = item.market;
            if(data.currency == Currency.CASH)
            {
               data.price = item.cash;
            }
            else
            {
               data.price = item.cost;
            }
            if(data.price == 0)
            {
               data.free = true;
            }
            m_slotData.push(data);
         }
      }
      
      private function onAskGroomingBrushClick(event:Event) : void
      {
         if(GroomingBarnManager.getInstance().canPostFeed())
         {
            GroomingBarnManager.getInstance().postGeneralFeed(this.handleAskButtonCallback);
            if(this.m_askButton)
            {
               this.toggleButton(this.m_askButton,false);
            }
         }
      }
      
      private function handleAskButtonCallback(shouldDisable:Boolean) : void
      {
         if(this.m_askButton)
         {
            if(shouldDisable)
            {
               this.disableAskButton();
            }
            else
            {
               this.toggleButton(this.m_askButton,true);
            }
         }
      }
      
      private function disableAskButton() : void
      {
         var hoursRemaining:int = 0;
         if(this.m_askButton)
         {
            this.m_askButton.enabled = true;
            this.m_askButton.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_askButton.setToggleState(ZwToggleState.SELECTED);
            this.m_askButton.applyGrayOut = true;
            this.m_askButton.element.buttonMode = false;
            hoursRemaining = Math.ceil(GroomingBarnManager.getInstance().getTimeUntilPostFeedEnabled() / FarmGameUtil.NUM_SECS_IN_HOUR);
            this.m_askButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Growable_ConsumableAskWithTimer",{"timeLeft":hoursRemaining})));
         }
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      private function onMakeGroomingBrushClick(event:Event) : void
      {
         this.m_window.close();
         GroomingBarnManager.getInstance().showCraftingWindowWithItem();
      }
      
      override public function release() : void
      {
         if(this.m_askButton)
         {
            this.m_askButton.detachTooltip();
         }
         this.m_askButton = null;
         this.m_makeButton = null;
         this.m_window = null;
         super.release();
      }
   }
}

