package Classes
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Widgets.Windows.CombineOnboardingWindow;
   import flash.events.MouseEvent;
   
   public class Combine extends Seeder
   {
      
      public static const COMBINE:String = "combine";
      
      public static const COMBINE_MORE_INFO:String = "combine_more_info";
      
      protected static const COMBINE_HORN_SFX_ASSET:String = "assets/sounds/combine_horn.mp3";
      
      public static const COMBINE_PURCHASE_ITEMS:Array = new Array("swissarmytractor","allpurposetractorhotrod");
      
      public static const COMBINE_HORN_ID:String = "combineHorn";
      
      private static const NUM_PARTS:String = "numParts";
      
      public function Combine(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
      }
      
      override protected function getMenuItems() : Array
      {
         var menuArray:Array = super.getMenuItems();
         menuArray.push({
            "label":ZLocUtils.t("Dialogs","MoreInfo"),
            "action":COMBINE_MORE_INFO
         });
         return menuArray;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MOVE_OBJECT:
                  this.move();
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               case VEHICLE_ACTION:
                  this.doCombineVehicleAction();
                  break;
               case HORN:
                  SoundManager.addSound(Combine.COMBINE_HORN_ID,Global.getAssetURL(Combine.COMBINE_HORN_SFX_ASSET));
                  SoundManager.playSound(Combine.COMBINE_HORN_ID);
                  break;
               case COMBINE_MORE_INFO:
                  this.doCombineMoreInfoAction();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function doCombineVehicleAction(forceOnboardingDialog:Boolean = false) : void
      {
         Global.world.m_chosenSeeder = this;
         if(forceOnboardingDialog == true || Global.player.getSeenFlag(CombineOnboardingWindow.SEEN_FLAG) == false)
         {
            UI.displayPopup(new CombineOnboardingWindow(),true);
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
         {
            UI.displaySeedSelectionMiniMarketDialog(getSupportedTerrainCodes(),UI.MARKET_LAUNCH_REFERENCE_COMBINE);
         }
         else
         {
            UI.displayMarketDialog("combine_context_menu","seed",UI.MARKET_LAUNCH_REFERENCE_COMBINE,"seeds",null,null,null,null,-1,getSupportedTerrainCodes(),null,null,true);
         }
      }
      
      public function doCombineMoreInfoAction() : void
      {
         this.doCombineVehicleAction(true);
      }
      
      override public function packStoreItemMetaData() : Object
      {
         return this.getMetadata();
      }
      
      override public function getMetadata() : Object
      {
         return this.packMetadata();
      }
      
      private function packMetadata() : Object
      {
         var metadata:Object = new Object();
         metadata[NUM_PARTS] = (this as Equipment).equipmentPartsCount;
         return metadata;
      }
   }
}

