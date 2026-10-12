package Widgets.Frames
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.TimedBuffRebuySlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class TimedBuffRebuySlotFrame extends FarmSlotContainerFrame
   {
      
      private static const REBUY_STRING:String = "RebuyWindow_TimedConsumables_";
      
      private static const DIALOGS:String = "Dialogs";
      
      private var m_parentWindow:DisplayObject;
      
      private const TIMED_CONSUMABLES_FEATURE:String = "timedConsumablesItems";
      
      public function TimedBuffRebuySlotFrame(element:DisplayObject, parent:DisplayObject)
      {
         this.m_parentWindow = parent;
         super(element);
         if(this.allowPaging())
         {
            if(m_element.hasOwnProperty("leftArrow_bt") && m_element.hasOwnProperty("rightArrow_bt"))
            {
               m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
               addWidget(m_pageBackWidget);
               m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
               addWidget(m_pageForwardWidget);
            }
         }
         if(m_element.hasOwnProperty("body_tf"))
         {
            addWidget(new FarmTextField(m_element.body_tf,ZLocUtils.t(DIALOGS,REBUY_STRING + "Sub")));
         }
         if(m_element.hasOwnProperty("title_tf"))
         {
            addWidget(new FarmTextField(m_element.title_tf,ZLocUtils.t(DIALOGS,REBUY_STRING + "Title")));
         }
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TimedBuffRebuySlot(slotElement,this.m_parentWindow as FarmWindow);
      }
      
      override protected function setupData() : void
      {
         var consumableFarmItems:Array = Global.farmGameSettingsManager.getItemsByClassArray("timedConsumable");
         m_slotData = consumableFarmItems;
      }
      
      private function constructFarmItemArray(itemNames:Array) : Array
      {
         var name:String = null;
         var currentItem:FarmItem = null;
         var result:Array = new Array();
         for each(name in itemNames)
         {
            currentItem = Global.farmGameSettingsManager.getFarmItemByName(name);
            result.push(currentItem);
         }
         return result;
      }
      
      protected function allowPaging() : Boolean
      {
         return true;
      }
   }
}

