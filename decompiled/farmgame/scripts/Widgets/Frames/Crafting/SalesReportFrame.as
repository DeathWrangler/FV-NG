package Widgets.Frames.Crafting
{
   import Classes.CraftingCottageBuilding;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.SocialMissions.SMTabButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwToggle;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class SalesReportFrame extends ZwFrame
   {
      
      private var m_cottage:CraftingCottageBuilding;
      
      private var m_toggleManager:ZwToggleManager;
      
      private var m_allButton:SMTabButton;
      
      private var m_levelUpsButton:SMTabButton;
      
      private var m_recipesButton:SMTabButton;
      
      private var m_allToggle:ZwToggle;
      
      private var m_levelUpsToggle:ZwToggle;
      
      private var m_recipesToggle:ZwToggle;
      
      private var m_reportSlotFrame:ReportSlotFrame;
      
      private var m_items:Array = [];
      
      public function SalesReportFrame(element:DisplayObject, cottage:CraftingCottageBuilding, showAllHistory:Boolean = true)
      {
         super(element);
         this.m_toggleManager = new ZwToggleManager();
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Crafting","SalesReport_Title")));
         this.m_items = cottage.transactionHistory ? cottage.transactionHistory.getSlotFrameItems(showAllHistory) : [];
         this.m_reportSlotFrame = new ReportSlotFrame(m_element.reportFrame_mc,this.m_items);
         this.m_reportSlotFrame.setFilteredItems(this.m_items,"all");
         addWidget(this.m_reportSlotFrame);
         FarmStatsManager.count("crafting_cottage","view_sales_report","pop_up_no_prompt");
      }
      
      override public function release() : void
      {
         super.release();
         this.m_reportSlotFrame = null;
         this.m_items = null;
         this.m_allButton = null;
         this.m_levelUpsButton = null;
         this.m_recipesButton = null;
         this.m_allToggle = null;
         this.m_levelUpsToggle = null;
         this.m_recipesToggle = null;
         this.m_toggleManager = null;
      }
      
      private function onAllClick(event:Event) : void
      {
         this.m_reportSlotFrame.setFilteredItems(this.m_items,"all");
      }
      
      private function onLevelUpsClick(event:Event) : void
      {
         this.m_reportSlotFrame.setFilteredItems(this.m_items,"levelups");
      }
      
      private function onRecipesClick(event:Event) : void
      {
         this.m_reportSlotFrame.setFilteredItems(this.m_items,"recipes");
      }
   }
}

