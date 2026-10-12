package Classes.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Engine.Managers.StatsManager;
   import flash.utils.Dictionary;
   
   public class CropBonanzaV2MOTDHandler extends CustomWindowMOTDHandler
   {
      
      private static const NUM_TILE_UNITS_IN_PLOT_UNIT:int = 4;
      
      public function CropBonanzaV2MOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         var itemCode:String = null;
         var mastery1:int = 0;
         var mastery2:int = 0;
         var mastery3:int = 0;
         var masteries:Object = null;
         var mastery:int = 0;
         var item:FarmItem = null;
         var bonanzaVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CROP_BONANZA_V2_MOTD);
         var numFuelRefillGift:int = 0;
         switch(bonanzaVariant)
         {
            case 1:
               numFuelRefillGift = 20;
               break;
            case 2:
               numFuelRefillGift = 10;
               break;
            case 3:
               numFuelRefillGift = 5;
         }
         var numFuelRefills:Number = 0;
         var gifts:Dictionary = Global.player.gifts;
         for(itemCode in gifts)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(item != null && item.type == FarmItemType.FUEL)
            {
               numFuelRefills += item.count * Global.player.gifts[itemCode].quantity;
            }
         }
         StatsManager.count("player_status","fuel_refills",(numFuelRefills + numFuelRefillGift).toString());
         super.acceptMOTD();
         mastery1 = 0;
         mastery2 = 0;
         mastery3 = 0;
         masteries = Global.player.mastery;
         for each(mastery in masteries)
         {
            switch(mastery)
            {
               case 0:
                  mastery1++;
                  break;
               case 1:
                  mastery1++;
                  mastery2++;
                  break;
               case 2:
                  mastery1++;
                  mastery2++;
                  mastery3++;
            }
         }
         StatsManager.count("player_status","fuel",Global.player.energy.toString());
         StatsManager.count("player_status","mastery_stars",mastery3.toString(),mastery2.toString(),mastery1.toString());
         StatsManager.count("player_status","worlds",(Global.worldManager.getAvailableTravelWorlds().length + 1).toString());
         StatsManager.count("player_status","plots",Global.world.numPlots.toString());
         StatsManager.count("player_status","farm_size",(Global.world.getGridWidth() / NUM_TILE_UNITS_IN_PLOT_UNIT).toString(),(Global.world.getGridHeight() / NUM_TILE_UNITS_IN_PLOT_UNIT).toString());
      }
   }
}

