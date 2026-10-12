package Widgets.Windows
{
   import Classes.ItemFinderItemDescriptor;
   import Classes.MarketStallBuilding;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.TutorialUI;
   import Display.UI;
   import GameMode.GMDefault;
   import Managers.ExchangeManager;
   import Managers.ItemFinderManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.BushelReportSlot;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class BushelReportWindow extends ToasterWindow
   {
      
      private static var s_windowVisible:Boolean = false;
      
      private var m_cropSet:Array = [];
      
      private var m_frame:GenericSlotContainerFrame;
      
      private var m_seedItemName:String;
      
      private var m_bushelWarning:ZwTextField;
      
      private var m_bushelCount_tf:ZwTextField;
      
      private var m_multiPlotPlant:Boolean;
      
      private var m_harvestMode:Boolean;
      
      public function BushelReportWindow(seedItemName:String = null, multiPlotPlant:Boolean = false, harvestMode:Boolean = false)
      {
         s_windowVisible = true;
         this.m_seedItemName = seedItemName;
         this.m_multiPlotPlant = multiPlotPlant;
         this.m_harvestMode = harvestMode;
         super("assets/dialogs/FV_BushelReport.swf");
         this.name = "BushelReportWindow";
         this.m_showTweenTime = 0;
         this.m_hideTweenTime = 0;
      }
      
      private static function howDoesThisWorkClick(event:Event) : void
      {
         TutorialUI.displayBundleTutorialWindow("Dialogs","BushelReport","assets/dialogs/4d_elements/BushelReport/BushelReport",false,null,"tut_0");
      }
      
      public static function isWindowOpen() : Boolean
      {
         return s_windowVisible;
      }
      
      public static function conditionallyRefreshWindow() : void
      {
         if(Boolean(Global.ui.bushelReportWindow) && BushelReportWindow.isWindowOpen())
         {
            Global.ui.bushelReportWindow.refreshWindow();
         }
      }
      
      private static function onBushelSwap(event:Event) : void
      {
         ExchangeManager.getInstance().openWindow(ExchangeManager.TRADER_BUSHEL);
      }
      
      public function setActiveSeedItemName(seedItemName:String, multiPlotPlant:Boolean = false, harvestMode:Boolean = false) : void
      {
         this.m_seedItemName = seedItemName;
         this.m_multiPlotPlant = multiPlotPlant;
         this.m_harvestMode = harvestMode;
         this.refreshWindow();
      }
      
      public function multiPlotPlant() : Boolean
      {
         return this.m_multiPlotPlant;
      }
      
      public function harvestMode() : Boolean
      {
         return this.m_harvestMode;
      }
      
      override protected function postLoadComplete() : void
      {
         this.m_cropSet = this.setupBushelData();
         this.m_frame = new GenericSlotContainerFrame(m_window.slotFrame_mc,BushelReportSlot,this.m_cropSet,this);
         addWidget(this.m_frame);
         if(m_window.slotFrame_mc.marketStall_bt)
         {
            addWidget(new FarmAnimatedButton(m_window.slotFrame_mc.marketStall_bt,this.openMarketStall));
         }
         if(m_window.slotFrame_mc.bushelSwap_bt)
         {
            addWidget(new FarmAnimatedButton(m_window.slotFrame_mc.bushelSwap_bt,onBushelSwap));
         }
         if(m_window.slotFrame_mc.bushelCount_tf)
         {
            this.m_bushelCount_tf = new ZwTextField(m_window.slotFrame_mc.bushelCount_tf,Global.player.craftingState.inventoryState.currentCapacity.toString() + "/" + Global.player.craftingState.inventoryState.maxCapacity.toString());
            addWidget(this.m_bushelCount_tf);
         }
         if(m_window.slotFrame_mc.whatisthis_mc)
         {
            addWidget(new FarmAnimatedTextButton(m_window.slotFrame_mc.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),howDoesThisWorkClick));
         }
         var firstTimeSeenFlag:String = "BushelReportWindow";
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            howDoesThisWorkClick(null);
            Global.player.setSeenFlag(firstTimeSeenFlag);
         }
         s_windowVisible = true;
      }
      
      override public function close() : void
      {
         super.close();
         s_windowVisible = false;
         Global.ui.bushelReportWindow = null;
         Global.world.addGameMode(new GMDefault(),true);
      }
      
      private function setupBushelData() : Array
      {
         var itemFind:ItemFinderItemDescriptor = null;
         Global.world.setObjectsDirty();
         var data:Array = [];
         var itemDictionary:Dictionary = ItemFinderManager.getInstance().getSeedItemDictionary();
         var alreadyPlantedItem:ItemFinderItemDescriptor = new ItemFinderItemDescriptor(this.m_seedItemName);
         for each(itemFind in itemDictionary)
         {
            if(itemFind.itemName == this.m_seedItemName)
            {
               alreadyPlantedItem = itemFind;
            }
            else
            {
               data.push(itemFind);
            }
         }
         if(this.m_seedItemName)
         {
            data.unshift(alreadyPlantedItem);
         }
         return data;
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         BushelReportSlot.s_totalBushelYield = 0;
         if(this.m_frame)
         {
            this.m_cropSet = this.setupBushelData();
            this.m_frame.setData(this.m_cropSet);
         }
         if(this.m_bushelCount_tf)
         {
            this.m_bushelCount_tf.text = Global.player.craftingState.inventoryState.currentCapacity.toString() + "/" + Global.player.craftingState.inventoryState.maxCapacity.toString();
         }
      }
      
      private function openMarketStall(event:Event) : void
      {
         var marketStall:MarketStallBuilding = null;
         marketStall = Global.player.craftingState.getMarketStall();
         if(marketStall != null)
         {
            enableInput = false;
            CraftingUI.displayMarketStallWindow(marketStall,false,this.onViewInventoryWindowClose);
         }
         else
         {
            UI.displayBuyMarketStallWindow();
         }
      }
      
      private function onViewInventoryWindowClose() : void
      {
         enableInput = true;
      }
      
      public function setBushelWarningVisibility(visible:Boolean) : void
      {
         if(!this.m_bushelWarning && Boolean(m_window.slotFrame_mc.bushelWarning_tf))
         {
            addWidget(this.m_bushelWarning = new ZwTextField(m_window.slotFrame_mc.bushelWarning_tf));
         }
         this.m_bushelWarning.text = Global.player.craftingState.inventoryState.currentCapacity == Global.player.craftingState.inventoryState.maxCapacity ? "BUSHEL STORAGE FULL!" : "BUSHEL STORAGE ALMOST FULL!";
         this.m_bushelWarning.visible = visible;
      }
      
      override protected function setToasterDepth() : void
      {
         Global.ui.swapToasterDepth(this);
      }
      
      override protected function release() : void
      {
         this.m_cropSet = null;
         this.m_frame = null;
         s_windowVisible = false;
         Global.ui.bushelReportWindow = null;
         this.m_seedItemName = null;
         this.m_bushelWarning = null;
         this.m_bushelCount_tf = null;
         this.m_multiPlotPlant = false;
         this.m_harvestMode = false;
         super.release();
      }
   }
}

