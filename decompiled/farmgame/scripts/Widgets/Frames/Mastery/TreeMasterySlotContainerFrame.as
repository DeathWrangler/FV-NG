package Widgets.Frames.Mastery
{
   import Classes.buffs.BMasteryTimed;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.Mastery.MasteryTreeSlot;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TreeMasterySlotContainerFrame extends MasterySlotContainerFrame
   {
      
      protected var m_treeLevelBar1:ZwWidget = null;
      
      protected var m_treeLevelBar2:ZwWidget = null;
      
      protected var m_level1Label:ZwTextField = null;
      
      protected var m_level1Number:ZwTextField = null;
      
      protected var m_level2Label:ZwTextField = null;
      
      protected var m_level2Number:ZwTextField = null;
      
      private var m_noResultsSetInvisible:Array = null;
      
      public function TreeMasterySlotContainerFrame(element:DisplayObject, masteryItems:Array, mainWindow:MasteryWindow)
      {
         masteryType = MasteryWindow.TYPE_TREE;
         super(element,masteryItems,mainWindow);
         this.m_level1Label = new ZwTextField(m_element.level1Label_tf,ZLocUtils.t("Dialogs","Mastery_Dialog_LevelAbbreviation"));
         addWidget(this.m_level1Label);
         this.m_level1Number = new ZwTextField(m_element.level1Number_tf,ZLocUtils.t("FarmVille","Number1"));
         addWidget(this.m_level1Number);
         this.m_level2Label = new ZwTextField(m_element.level2Label_tf,ZLocUtils.t("Dialogs","Mastery_Dialog_LevelAbbreviation"));
         addWidget(this.m_level2Label);
         this.m_level2Number = new ZwTextField(m_element.level2Number_tf,ZLocUtils.t("FarmVille","Number2"));
         addWidget(this.m_level2Number);
         this.m_treeLevelBar1 = new ZwWidget(m_element.level1_mc);
         addWidget(this.m_treeLevelBar1);
         this.m_treeLevelBar2 = new ZwWidget(m_element.level2_mc);
         addWidget(this.m_treeLevelBar2);
         this.m_noResultsSetInvisible = [this.m_treeLevelBar1,this.m_treeLevelBar2,this.m_level1Label,this.m_level1Number,this.m_level2Label,this.m_level2Number];
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MasteryTreeSlot(slotElement,m_mainWindow);
      }
      
      override public function changeData(newData:Array) : void
      {
         var widget:ZwWidget = null;
         var isDataEmpty:Boolean = newData.length == 0;
         var needToChangeVisibility:Boolean = isDataEmpty != (m_slotData.length == 0);
         super.changeData(newData);
         if(needToChangeVisibility && Boolean(this.m_noResultsSetInvisible))
         {
            for each(widget in this.m_noResultsSetInvisible)
            {
               widget.visible = !isDataEmpty;
            }
         }
      }
      
      override protected function onUpdateTimeLeft(event:Event) : void
      {
         updateTimeHelper(BMasteryTimed.TREE_ITEM_NAME);
      }
   }
}

