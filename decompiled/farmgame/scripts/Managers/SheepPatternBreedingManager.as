package Managers
{
   import Classes.ConstructionBuilding;
   import Engine.Managers.TransactionManager;
   import GameMode.GMBuild;
   import Transactions.TTransformBuilding;
   import Widgets.Windows.SheepPen.SheepPenWindow;
   
   public class SheepPatternBreedingManager
   {
      
      private static const SHEEP_PEN_CONSTRUCTION_BUILDING:String = "xuk_sheep_pen";
      
      private static const SHEEP_PEN_FINSIHED_BUILDING:String = "xuk_sheep_pen_finished";
      
      public function SheepPatternBreedingManager()
      {
         super();
      }
      
      public static function openSheepPenBreedingUI(itemName:String) : void
      {
         var extraData:Object = null;
         var finished:Array = Global.world.getObjectsByName(itemName);
         var construction:Array = Global.world.getObjectsByName(SHEEP_PEN_CONSTRUCTION_BUILDING);
         var sheepPenItemCountInFarm:int = (finished ? finished.length : 0) + (construction ? construction.length : 0);
         if(sheepPenItemCountInFarm <= 0)
         {
            extraData = {};
            extraData.expansionLevel = 1;
            Global.world.addGameMode(new GMBuild(itemName,false,0,true,extraData,null));
            Global.farmGameSettingsManager.updateItemByName(itemName);
            openSheepBreedingFeatureUI(null);
         }
         else if(Boolean(finished) && finished.length > 0)
         {
            openSheepBreedingFeatureUI(null);
         }
         else if(Boolean(construction) && construction.length >= 1)
         {
            completeSheepPenFrame();
         }
      }
      
      private static function completeSheepPenFrame() : void
      {
         var items:Array = Global.world.getObjectsByName(SHEEP_PEN_CONSTRUCTION_BUILDING);
         if(Boolean(items) && items.length >= 1)
         {
            TransactionManager.addTransaction(new TTransformBuilding(ConstructionBuilding(items[0]),true));
         }
      }
      
      private static function openSheepBreedingFeatureUI(result:Object) : void
      {
         SheepPenWindow.openUI(SHEEP_PEN_FINSIHED_BUILDING);
      }
   }
}

