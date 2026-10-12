package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.EmbeddedArt;
   import Classes.Plot;
   import Managers.ClickTrackingManager;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMMultiPlotRemover extends GMMultiPlotAction
   {
      
      public function GMMultiPlotRemover()
      {
         super();
         m_cursorImage = EmbeddedArt.cursor_plotremover_ground;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var avatar:FarmAvatar = null;
         var plots:Array = null;
         var plotIdx:int = 0;
         var plot:Plot = null;
         var pos:Point = null;
         if(performResourceCheck())
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_VEHICLE,ClickTrackingConstants.CLICK_TYPE_PLOTREMOVER);
            avatar = Global.selectedAvatar;
            plots = [];
            if(Boolean(avatar) && Boolean(Global.player) && Boolean(m_highlightedPoint))
            {
               for(plotIdx = 0; plotIdx < m_plots.length; plotIdx++)
               {
                  if(m_plots[plotIdx].valid)
                  {
                     plot = m_plots[plotIdx].object as Plot;
                     if(plot)
                     {
                        plots.push(plot);
                     }
                  }
               }
               if(plots.length)
               {
                  pos = new Point(m_highlightedPoint.x + m_actionSize.x / 2 * Plot.SIZE_X,m_highlightedPoint.y + m_actionSize.y / 2 * Plot.SIZE_Y);
                  this.addAvatarState(avatar,plots,pos);
                  reselectPlots();
                  updateOverlay();
               }
            }
         }
      }
      
      protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
      }
      
      override protected function isSelectable(plot:Plot) : Boolean
      {
         return plot != null && plot.isClearable() && plot.isRemovable() && isPlotOnAcceptableTerrain(plot);
      }
   }
}

