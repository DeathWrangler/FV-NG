package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Managers.FarmRunQuestManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FarmRunQuestWorldSlot;
   import Widgets.Windows.FarmRunQuestWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FarmRunQuestWorldFrame extends GenericSlotContainerFrame
   {
      
      private var m_window:FarmRunQuestWindow;
      
      private var m_worldIndex:int = 0;
      
      public function FarmRunQuestWorldFrame(element:DisplayObject, parentWindow:FarmRunQuestWindow, worldIndex:int)
      {
         this.m_window = parentWindow;
         this.m_worldIndex = worldIndex;
         var items:Array = FarmRunQuestManager.getInstance().getRewardsItemsArray();
         super(element,FarmRunQuestWorldSlot,items,parentWindow);
         removeWidget(m_pageBackWidget);
         removeWidget(m_pageForwardWidget);
         if(element["leftArrow_bt"])
         {
            m_pageBackWidget = addWidget(new ZwButton(element["leftArrow_bt"],this.onPageBack)) as ZwWidget;
         }
         if(element["rightArrow_bt"])
         {
            m_pageForwardWidget = addWidget(new ZwButton(element["rightArrow_bt"],this.onPageForward)) as ZwWidget;
         }
         if(m_element.hasOwnProperty("worldName_tf"))
         {
            addWidget(new ZwTextField(m_element.worldName_tf,ZLocUtils.t("Dialogs","ofquest-01_world" + worldIndex.toString() + "_Title")));
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmRunQuestWorldSlot(slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "stage";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "_tac_mc";
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var itemsArray:Array = FarmRunQuestManager.getInstance().getRewardsItemsArray();
         for(var i:int = 0; i < itemsArray.length; i++)
         {
            m_slotData.push({
               "item_code":itemsArray[i],
               "index":i
            });
         }
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function onPageBack(event:Event) : void
      {
         this.pageBack();
      }
      
      public function onPageForward(event:Event) : void
      {
         this.pageForward();
      }
      
      protected function pageForward() : void
      {
         ++FarmRunQuestWindow.m_currentDisplayedWorldNum;
         this.m_window.setWorldFrame(FarmRunQuestWindow.m_currentDisplayedWorldNum);
      }
      
      protected function pageBack() : void
      {
         --FarmRunQuestWindow.m_currentDisplayedWorldNum;
         this.m_window.setWorldFrame(FarmRunQuestWindow.m_currentDisplayedWorldNum);
      }
   }
}

