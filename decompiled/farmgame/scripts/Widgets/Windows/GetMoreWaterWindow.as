package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.WaterHarvestFManager;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.IrrigationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.GetMoreWaterItemSlot;
   import flash.events.Event;
   
   public class GetMoreWaterWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_irrigation_buyWater.swf";
      
      private static const WATER_ICON_URL:String = "assets/newsfeed/market_watericon.png";
      
      private static const STATE_WELL_PLACE:String = "state_wellPlace";
      
      private static const STATE_WELL_HARVEST:String = "state_wellHarvest";
      
      private static const STATE_USE_GB_WATER:String = "state_use_gb_water";
      
      private static const STATE_NO_CTA:String = "state_no_cta";
      
      private static const ZLOC_PREFIX:String = "irrigation_getMoreWater_";
      
      private var m_irrigationManager:IrrigationManager = IrrigationManager.instance;
      
      public function GetMoreWaterWindow()
      {
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var capacityLeft:int = 0;
         var name:String = null;
         var iconUrl:String = null;
         var callToActionText:String = null;
         var callToActionCallback:Function = null;
         var buildingName:String = null;
         var farmItem:FarmItem = null;
         var building:FeatureBuilding = null;
         super.postLoadComplete();
         var title:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "getMoreWater");
         addWidget(new ZwTextField(m_window.title_tf,title));
         var capacity:int = this.m_irrigationManager.getWaterAmount(IrrigationManager.WATER_PLOTS);
         var maxCapacity:int = this.m_irrigationManager.getMaxWaterForActionType(IrrigationManager.WATER_PLOTS);
         capacityLeft = maxCapacity - capacity;
         var state:String = this.determineState(capacityLeft);
         var waterPackages:Array = Global.farmGameSettingsManager.getFarmItemsArrayByNames(this.m_irrigationManager.getWaterSourcesConsumables(IrrigationManager.WATER_PLOTS));
         if(state == STATE_NO_CTA)
         {
            addWidget(new GenericSlotContainerFrame(m_window.slots_center_mc,GetMoreWaterItemSlot,waterPackages,this));
         }
         else
         {
            addWidget(new GenericSlotContainerFrame(m_window.slots_well_mc,GetMoreWaterItemSlot,waterPackages,this));
            addWidget(new ZwFrame(m_window.well_slot_mc));
            callToActionCallback = null;
            switch(state)
            {
               case STATE_USE_GB_WATER:
                  name = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "cta_useWater");
                  iconUrl = WATER_ICON_URL;
                  callToActionText = name;
                  callToActionCallback = this.onUseFromGiftbox;
                  break;
               case STATE_WELL_PLACE:
                  buildingName = this.findBuildingToPlace();
                  farmItem = Global.farmGameSettingsManager.getFarmItemByName(buildingName);
                  name = farmItem.friendlyTitle;
                  iconUrl = farmItem.icon;
                  callToActionText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "cta_placeWell");
                  callToActionCallback = this.generateOnPlaceBuilding(buildingName);
                  break;
               case STATE_WELL_HARVEST:
                  building = this.findBuildingToHarvest(capacityLeft);
                  name = building.getItem().friendlyTitle;
                  iconUrl = building.getBuildingIcon();
                  callToActionText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "cta_goHarvest");
                  callToActionCallback = this.generateOnHarvestBuilding(building);
            }
            if(name)
            {
               addWidget(new ZwTextField(m_window.well_slot_mc.name_tf,name));
            }
            if(iconUrl)
            {
               addWidget(new FarmIcon(m_window.well_slot_mc.icon_mc,iconUrl));
            }
            if(Boolean(callToActionText) && callToActionCallback != null)
            {
               addWidget(new FarmAnimatedTextButton(m_window.well_slot_mc.callToAction_bt,callToActionText,callToActionCallback));
            }
         }
      }
      
      private function determineState(capacityLeft:int) : String
      {
         var consumableSource:String = null;
         var result:String = STATE_NO_CTA;
         if(capacityLeft > 0)
         {
            consumableSource = this.m_irrigationManager.getSingleWaterSourceConsumable(IrrigationManager.WATER_PLOTS);
            if(this.findBuildingToHarvest(capacityLeft) != null)
            {
               result = STATE_WELL_HARVEST;
            }
            else if(this.findBuildingToPlace())
            {
               result = STATE_WELL_PLACE;
            }
            else if(Global.player.getGiftCountForItem(consumableSource))
            {
               result = STATE_USE_GB_WATER;
            }
         }
         return result;
      }
      
      private function findBuildingToHarvest(capacityLeft:int) : FeatureBuilding
      {
         var result:FeatureBuilding = null;
         var building:FeatureBuilding = null;
         var instance:MapResource = null;
         var harvestManager:WaterHarvestFManager = null;
         var buildingNames:Array = this.m_irrigationManager.getWaterSourcesForActionType(IrrigationManager.WATER_PLOTS);
         var buildings:Array = Global.world.getObjectsByNames(buildingNames);
         if(buildings.length > 0)
         {
            for each(instance in buildings)
            {
               building = instance as FeatureBuilding;
               if(building)
               {
                  harvestManager = building.harvester as WaterHarvestFManager;
                  if(harvestManager)
                  {
                     if(building.isHarvestable() && harvestManager.getWaterHarvestAmountForCurrentLevel() <= capacityLeft)
                     {
                        result = building;
                        break;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      private function findBuildingToPlace() : String
      {
         var result:String = null;
         var buildingName:String = null;
         var building:FarmItem = null;
         var buildingNames:Array = this.m_irrigationManager.getWaterSourcesForActionType(IrrigationManager.WATER_PLOTS);
         for each(buildingName in buildingNames)
         {
            building = Global.farmGameSettingsManager.getFarmItemByName(buildingName);
            if(building.canPurchase || Global.player.getGiftCountForItem(buildingName) > 0)
            {
               result = buildingName;
               break;
            }
         }
         return result;
      }
      
      private function generateOnHarvestBuilding(building:FeatureBuilding) : Function
      {
         return function(e:Event):void
         {
            close();
            building.centerOn();
         };
      }
      
      private function generateOnPlaceBuilding(buildingName:String) : Function
      {
         return function(e:Event):void
         {
            close();
            var inGiftbox:* = Global.player.getGiftCountForItem(buildingName) > 0;
            Global.world.enterForcePlaceMode(buildingName,!inGiftbox,0,true,inGiftbox);
         };
      }
      
      private function onUseFromGiftbox(e:Event) : void
      {
         var item:FarmItem = null;
         var consumableSource:String = this.m_irrigationManager.getSingleWaterSourceConsumable(IrrigationManager.WATER_PLOTS);
         if(Global.player.getGiftCountForItem(consumableSource))
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(consumableSource);
            UI.displayGiftBoxWindow(false,item.friendlyTitle);
            close();
         }
      }
      
      override protected function release() : void
      {
         this.m_irrigationManager = null;
         super.release();
      }
   }
}

