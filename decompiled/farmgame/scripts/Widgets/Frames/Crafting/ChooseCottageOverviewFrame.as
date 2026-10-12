package Widgets.Frames.Crafting
{
   import Managers.Crafting.CraftingConstants;
   import Managers.FarmStatsManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Windows.Crafting.ChooseCottageWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ChooseCottageOverviewFrame extends ZwFrame
   {
      
      private const REWARD_ICON_SIZE:int = 55;
      
      private var m_mainWindow:ChooseCottageWindow;
      
      public function ChooseCottageOverviewFrame(element:MovieClip, mainWindow:ChooseCottageWindow)
      {
         super(element);
         this.m_mainWindow = mainWindow;
         FarmStatsManager.count("crafting_cottage","onboarding","standard_popup","impressions");
         addWidget(new ChooseCottageSlotFrame(element.slot_0_mc,mainWindow,CraftingConstants.BAKERY_SKILL));
         addWidget(new ChooseCottageSlotFrame(element.slot_1_mc,mainWindow,CraftingConstants.PERFUMERY_SKILL));
         addWidget(new ChooseCottageSlotFrame(element.slot_2_mc,mainWindow,CraftingConstants.WINERY_SKILL));
         addWidget(new ZwButton(element.close_bt,this.onClose));
      }
      
      protected function onClose(event:Event) : void
      {
         this.m_mainWindow.close();
      }
   }
}

