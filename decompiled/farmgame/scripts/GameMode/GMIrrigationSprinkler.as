package GameMode
{
   import AvatarMode.AMIrrigationSprinkler;
   import Classes.Avatar.FarmAvatar;
   import Classes.IrrigationSprinkler;
   import Classes.Plot;
   import Display.UI;
   import Engine.Constants;
   import Managers.IrrigationManager;
   import Widgets.Windows.GetMoreWaterWindow;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMIrrigationSprinkler extends GMMultiPlotAction
   {
      
      private var m_sprinkler:IrrigationSprinkler;
      
      public function GMIrrigationSprinkler(sprinkler:IrrigationSprinkler)
      {
         super();
         this.m_sprinkler = sprinkler;
         m_actionSize = this.m_sprinkler.getActionSize();
         m_arrAcceptableTerrain = this.m_sprinkler.getSupportedTerrainCodes();
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var plotIdx:int = 0;
         var plot:Plot = null;
         var waterAmount:int = 0;
         var waterCost:int = 0;
         var pos:Point = null;
         var avatar:FarmAvatar = Global.selectedAvatar;
         var plots:Array = [];
         if(Boolean(avatar) && Boolean(Global.player) && Boolean(m_highlightedPoint))
         {
            for(plotIdx = 0; plotIdx < m_plots.length; plotIdx++)
            {
               if(m_plots[plotIdx].valid)
               {
                  plot = m_plots[plotIdx].object as Plot;
                  if(Boolean(plot) && plot.hasValidId())
                  {
                     plots.push(plot);
                  }
               }
            }
            if(plots.length)
            {
               waterAmount = IrrigationManager.instance.getWaterAmount(IrrigationManager.WATER_PLOTS);
               waterCost = IrrigationManager.instance.getWaterCost(plots);
               if(waterAmount >= waterCost)
               {
                  IrrigationManager.instance.useWater(IrrigationManager.WATER_PLOTS,waterCost);
                  pos = new Point(m_highlightedPoint.x + m_actionSize.x / 2 * Plot.SIZE_X,m_highlightedPoint.y + m_actionSize.y / 2 * Plot.SIZE_Y);
                  this.addAvatarState(avatar,plots,pos);
                  reselectPlots();
                  updateOverlay();
               }
               else
               {
                  UI.displayPopup(new GetMoreWaterWindow());
               }
            }
         }
      }
      
      override protected function isSelectable(plot:Plot) : Boolean
      {
         return plot != null && plot.isWaterable();
      }
      
      protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
         avatar.getStateMachine().addState(new AMIrrigationSprinkler(avatar,plots,this.m_sprinkler,centerPos),true);
      }
      
      override protected function getValidOutlineColor() : uint
      {
         return Constants.COLOR_HIGHLIGHT_BLUE;
      }
      
      override protected function shouldShowTurbo() : Boolean
      {
         return false;
      }
   }
}

