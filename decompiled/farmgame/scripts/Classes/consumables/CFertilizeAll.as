package Classes.consumables
{
   import Classes.Consumable;
   import Classes.Plot;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   
   public class CFertilizeAll extends Consumable
   {
      
      private var m_displayedError:Boolean = false;
      
      public function CFertilizeAll(itemName:String)
      {
         super(itemName);
         this.m_displayedError = false;
      }
      
      override public function onUse() : void
      {
         var plot:Plot = null;
         var plots:Array = Global.world.getObjectsByClass(Plot);
         for(var plotIdx:int = 0; plotIdx < plots.length; plotIdx++)
         {
            plot = plots[plotIdx] as Plot;
            if(plot.isFertilizable())
            {
               plot.fertilize(true);
            }
         }
      }
      
      override public function canUse() : Boolean
      {
         var plot:Plot = null;
         var plots:Array = Global.world.getObjectsByClass(Plot);
         var result:Boolean = false;
         for(var plotIdx:int = 0; plotIdx < plots.length; plotIdx++)
         {
            plot = plots[plotIdx] as Plot;
            if(plot.isFertilizable())
            {
               result = true;
               break;
            }
         }
         if(Plot.playerCanFertilize() == false)
         {
            this.m_displayedError = true;
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","LevelFertilizeAllFailure")));
         }
         if(!result && !this.m_displayedError)
         {
            this.m_displayedError = true;
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","BeehiveFertilizeAllFailure")));
         }
         return result;
      }
   }
}

