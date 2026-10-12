package Widgets.Frames.SocialPlumbing
{
   import Classes.util.ZLocUtils;
   import Managers.SocialPlumbingManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.SocialPlumbing.SocialPlumbingTodoSlot;
   import Widgets.Windows.SocialPlumbing.SocialPlumbingTodoList;
   import flash.display.DisplayObject;
   
   public class SocialPlumbingTodoSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "task";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      public static const NUM_SLOTS:int = 5;
      
      private var m_mainWindow:SocialPlumbingTodoList;
      
      protected var m_taskItems:Array = null;
      
      public function SocialPlumbingTodoSlotFrame(element:DisplayObject, taskItems:Array, mainWindow:SocialPlumbingTodoList)
      {
         this.m_mainWindow = mainWindow;
         this.m_taskItems = taskItems;
         super(element);
         addWidget(new ZwWidget(m_element.coverUp_mc));
         this.refresh();
      }
      
      override public function refresh() : void
      {
         super.refresh();
         var congratsBg:ZwWidget = getWidget(m_element.coverUp_mc) as ZwWidget;
         if(SocialPlumbingManager.getInstance().hasCompletedAllActions())
         {
            congratsBg.visible = true;
            congratsBg.element.title_tf.text = ZLocUtils.t("Dialogs","SocialPlumbingTodoCongratsTitle");
            congratsBg.element.generic_tf.text = ZLocUtils.t("Dialogs","SocialPlumbingTodoCongratsBody");
         }
         else
         {
            congratsBg.visible = false;
         }
      }
      
      public function setTaskData(taskItems:Array) : void
      {
         this.m_taskItems = taskItems;
         this.setupData();
         populateSlots();
         m_pagingComponent.currentPageNumber = 0;
         this.refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var index:uint = 1;
         while(m_element[this.getSlotPrefix() + index + this.getSlotPostfix()])
         {
            slot = this.createSlot(m_element[this.getSlotPrefix() + index + this.getSlotPostfix()]);
            addWidget(slot,false);
            m_slots.push(slot);
            index++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new SocialPlumbingTodoSlot(slotElement,this);
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_taskItems;
      }
      
      public function toggleMainWindow(enable:Boolean) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.toggleEnabled(enable);
         }
      }
      
      public function refreshMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.refresh();
            this.m_mainWindow.populateDataFields();
         }
      }
      
      public function closeMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
      }
   }
}

