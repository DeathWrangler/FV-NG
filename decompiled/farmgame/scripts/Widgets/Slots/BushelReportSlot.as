package Widgets.Slots
{
   import Classes.ItemFinderItemDescriptor;
   import Classes.ZItem.FarmItem;
   import Classes.buffs.BPermanentTypeGain;
   import GameMode.GMMarketPlant;
   import Managers.Crafting.CraftingManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.BushelReportWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class BushelReportSlot extends ZwSlotFrame
   {
      
      private static var s_kMultiplier:Number;
      
      public static var s_totalBushelYield:int = 0;
      
      private var m_cropName:ZwTextField;
      
      private var m_seedItemName:String;
      
      private var m_cropIcon:FarmIcon;
      
      private var m_bushelIcon:FarmIcon;
      
      private var m_bushelCount:ZwTextField;
      
      private var m_bushelYied:ZwTextField;
      
      private var m_parentWindow:BushelReportWindow;
      
      public function BushelReportSlot(element:DisplayObject, parentWindow:BushelReportWindow)
      {
         if(!s_kMultiplier)
         {
            setKMultiplier();
         }
         this.m_parentWindow = parentWindow;
         super(element);
         if(m_element.name_tf)
         {
            addWidget(this.m_cropName = new ZwTextField(m_element.name_tf));
         }
         if(m_element.bushelcount_tf)
         {
            addWidget(this.m_bushelCount = new ZwTextField(m_element.bushelcount_tf));
         }
         if(m_element.bushelYield_tf)
         {
            addWidget(this.m_bushelYied = new ZwTextField(m_element.bushelYield_tf));
         }
         if(m_element.icon_mc)
         {
            addWidget(this.m_cropIcon = new FarmIcon(m_element.icon_mc));
         }
         if(m_element.bushel_mc)
         {
            addWidget(this.m_bushelIcon = new FarmIcon(m_element.bushel_mc));
         }
         if(!this.m_parentWindow.harvestMode())
         {
            this.registerEventListener(MouseEvent.CLICK,this.onClick);
         }
      }
      
      public static function setKMultiplier() : void
      {
         s_kMultiplier = Global.flashHotParams.hasOwnProperty("KBUSHEL_MULTIPLIER_TMPRT") ? Number(Global.flashHotParams["KBUSHEL_MULTIPLIER_TMPRT"]) : 50;
      }
      
      override public function release() : void
      {
         if(!this.m_parentWindow.harvestMode())
         {
            this.unregisterEventListener(MouseEvent.CLICK,this.onClick);
         }
         this.m_cropName = null;
         this.m_seedItemName = null;
         this.m_cropIcon = null;
         this.m_bushelIcon = null;
         this.m_bushelCount = null;
         this.m_bushelYied = null;
         s_kMultiplier = 0;
         s_totalBushelYield = 0;
         if(this.m_bushelIcon)
         {
            this.m_bushelIcon = null;
         }
         super.release();
      }
      
      private function onClick(event:MouseEvent) : void
      {
         if(!this.m_parentWindow.harvestMode())
         {
            if(!this.m_parentWindow.multiPlotPlant())
            {
               Global.world.addGameMode(new GMMarketPlant(this.m_seedItemName));
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var itemDescriptor:ItemFinderItemDescriptor = data as ItemFinderItemDescriptor;
         if(itemDescriptor)
         {
            this.m_seedItemName = itemDescriptor.itemName;
            if(this.m_cropName)
            {
               this.m_cropName.text = itemDescriptor.friendlyName;
               this.m_cropName.visible = true;
            }
            if(this.m_bushelCount)
            {
               this.m_bushelCount.text = "Planted: " + itemDescriptor.worldCount.toString();
               this.m_bushelCount.visible = true;
            }
            if(this.m_bushelYied)
            {
               this.setupBushelYield(itemDescriptor);
            }
            if(this.m_cropIcon)
            {
               this.m_cropIcon.loadIcon(itemDescriptor.iconUrl);
               this.m_cropIcon.visible = true;
               this.m_cropIcon.setSmoothing(true);
            }
         }
      }
      
      private function setupBushelYield(itemDescritptor:ItemFinderItemDescriptor) : void
      {
         var yBonus:int = 0;
         var doubleBushelMultiplier:int = 0;
         var organicFertlizerAndDoubleBushelBonus:int = 0;
         var worldCountDoubleBushelBonus:int = 0;
         var potential:int = 0;
         var numberToCompare:int = 0;
         var bushelQuantityToAward:int = 0;
         var totalBushelsAfterHarvest:int = 0;
         var currentWorldId:String = null;
         var worldBushelChanceScale:Number = NaN;
         var bushelItem:FarmItem = CraftingManager.getBushelFromItemName(itemDescritptor.itemName);
         var cropItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemDescritptor.itemName);
         if(Boolean(bushelItem) && Boolean(cropItem))
         {
            yBonus = CraftingManager.getInstance().getNewBushelBonusAdders(bushelItem.code,cropItem.code);
            doubleBushelMultiplier = BPermanentTypeGain.getNewDoubleBushelBonus();
            organicFertlizerAndDoubleBushelBonus = doubleBushelMultiplier * itemDescritptor.tempHarvestCountForSeedInItemFinder;
            worldCountDoubleBushelBonus = doubleBushelMultiplier * itemDescritptor.worldCountAOE;
            potential = worldCountDoubleBushelBonus + Global.player.getHarvestCountForSeedSinceLastBushelDrop(cropItem.code) + organicFertlizerAndDoubleBushelBonus;
            numberToCompare = s_kMultiplier / (1 + yBonus);
            bushelQuantityToAward = 0;
            if(potential >= numberToCompare)
            {
               currentWorldId = Global.worldManager.currentWorldType;
               worldBushelChanceScale = Global.farmGameSettingsManager.getWorldBushelChanceScale(currentWorldId);
               bushelQuantityToAward = potential / numberToCompare * worldBushelChanceScale;
            }
            this.m_bushelYied.text = "Yield: " + bushelQuantityToAward.toString();
            this.m_bushelYied.visible = true;
            s_totalBushelYield += bushelQuantityToAward;
            totalBushelsAfterHarvest = s_totalBushelYield + Global.player.craftingState.inventoryState.currentCapacity;
            if(totalBushelsAfterHarvest >= Global.player.craftingState.inventoryState.maxCapacity)
            {
               this.m_parentWindow.setBushelWarningVisibility(true);
            }
            if(this.m_bushelIcon)
            {
               this.m_bushelIcon.loadIcon(bushelItem.iconUrl);
               this.m_bushelIcon.visible = true;
               this.m_bushelIcon.setSmoothing(true);
            }
         }
      }
   }
}

