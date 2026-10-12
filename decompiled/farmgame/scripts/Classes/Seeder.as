package Classes
{
   import Classes.Constants.Experiments;
   import Display.ContextMenuItem;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import flash.events.MouseEvent;
   
   public class Seeder extends Equipment
   {
      
      public static const SEED:String = "seed";
      
      protected static const SEEDER_HORN_SFX_ASSET:String = "assets/sounds/seeder_horn.mp3";
      
      public function Seeder(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
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
                  Global.world.m_chosenSeeder = this;
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
                  {
                     UI.displaySeedSelectionMiniMarketDialog(getSupportedTerrainCodes(),UI.MARKET_LAUNCH_REFERENCE_SEEDER);
                  }
                  else
                  {
                     UI.displayMarketDialog("seeder_context_menu","seed",UI.MARKET_LAUNCH_REFERENCE_SEEDER,"seeds",null,null,null,null,-1,getSupportedTerrainCodes());
                  }
                  break;
               case HORN:
                  SoundManager.addSound("seederHorn",Global.getAssetURL(Seeder.SEEDER_HORN_SFX_ASSET));
                  SoundManager.playSound("seederHorn");
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
   }
}

