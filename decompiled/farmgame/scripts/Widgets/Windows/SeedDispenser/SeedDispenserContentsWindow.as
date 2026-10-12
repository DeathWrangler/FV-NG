package Widgets.Windows.SeedDispenser
{
   import Classes.Combine;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.SeedDispenserFeatureConfig;
   import Classes.FeatureDataObjects.SeedDispenserSeedConfig;
   import Classes.RotatableCombine;
   import Classes.RotatableSeeder;
   import Classes.Seeder;
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.SeedDispenserManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.SeedDispenser.SeedDispenserContentsSlotFrame;
   import Widgets.Slots.SeedDispenser.SeedDispenserContentsSlot;
   import Widgets.Windows.StorageContentsWindow;
   
   public class SeedDispenserContentsWindow extends StorageContentsWindow
   {
      
      public function SeedDispenserContentsWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      public function get featureName() : String
      {
         return m_building ? m_building.getItemName() : "";
      }
      
      override protected function getFarmSlotContainerFrame() : FarmSlotContainerFrame
      {
         return new SeedDispenserContentsSlotFrame(m_window.default_mc,m_contents,this,SeedDispenserContentsSlot);
      }
      
      override protected function loadContents() : Array
      {
         var result:Array = new Array();
         var featureConfig:SeedDispenserFeatureConfig = SeedDispenserManager.getFeatureConfig(this.featureName);
         if(featureConfig)
         {
            result = featureConfig.getSeeds(true);
         }
         else
         {
            GlobalEngine.assert(false,"Feature config is missing for \"" + this.featureName + "\".");
         }
         return result;
      }
      
      override protected function initFeatureWidgets() : void
      {
         m_contentTab_bt = new FarmAnimatedTextButton(m_window.defaultTab_mc,ZLocUtils.t("Dialogs","HerbGarden_DefaultTab"),onShowContents);
         super.initFeatureWidgets();
         m_capacity_tf.visible = false;
         m_current_tf.visible = false;
      }
      
      public function buySeed(seedItem:SeedItem) : void
      {
         var seed:SeedDispenserSeedConfig = null;
         var seedNames:Array = [];
         var seeds:Array = SeedDispenserManager.getSeeds(this.featureName);
         for each(seed in seeds)
         {
            seedNames.push(seed.name);
         }
         UI.displayMiniMarketDialog(seedNames,this.featureName,"seed",building.displayStorageDialog,true);
         close();
      }
      
      public function useSeed(seedItem:SeedItem) : void
      {
         if(Boolean(Global.world.getEquipment(Combine,null,seedItem.name) as Combine) || Boolean(Global.world.getEquipment(RotatableCombine,null,seedItem.name) as RotatableCombine))
         {
            UI.marketLaunchReference = UI.MARKET_LAUNCH_REFERENCE_COMBINE;
         }
         else if(Boolean(Global.world.getEquipment(Seeder,null,seedItem.name) as Seeder) || Boolean(Global.world.getEquipment(RotatableSeeder,null,seedItem.name) as RotatableSeeder))
         {
            UI.marketLaunchReference = UI.MARKET_LAUNCH_REFERENCE_SEEDER;
         }
         else
         {
            UI.marketLaunchReference = null;
         }
         close();
         seedItem.onBuy(seedItem.name);
      }
   }
}

