package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.Plot;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Display.UnwitherDialog;
   import Managers.ClickTrackingManager;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMMultiPlotPlow extends GMMultiPlotAction
   {
      
      public function GMMultiPlotPlow()
      {
         super();
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var noValidPlots:Boolean = false;
         var avatar:FarmAvatar = null;
         var plots:Array = null;
         var terrainCode:int = 0;
         var maxedObjects:Boolean = false;
         var plotIdx:int = 0;
         var worldPlotCostData:Object = null;
         var showImpulseBuyDialog:Boolean = false;
         var plot:Plot = null;
         var pos:Point = null;
         var unwitherDialogShown:Boolean = UnwitherDialog.showUnwitherDialogIfAppropriate();
         if(!unwitherDialogShown && performResourceCheck())
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_VEHICLE,ClickTrackingConstants.CLICK_TYPE_TRACTOR);
            noValidPlots = true;
            avatar = Global.selectedAvatar;
            plots = [];
            if(Boolean(avatar) && Boolean(Global.player) && Boolean(m_highlightedPoint))
            {
               maxedObjects = false;
               for(plotIdx = 0; plotIdx < m_plots.length; plotIdx++)
               {
                  if(m_plots[plotIdx].valid)
                  {
                     noValidPlots = false;
                     worldPlotCostData = Plot.getWorldPlowPlotCostData();
                     showImpulseBuyDialog = plotIdx == 0;
                     if(Global.player.canBuyWithCurrency(worldPlotCostData.currencyUnit,worldPlotCostData.cost,showImpulseBuyDialog))
                     {
                        plot = m_plots[plotIdx].object as Plot;
                        if(plot == null)
                        {
                           if(Global.world.checkNumObjectLimit())
                           {
                              plot = new Plot();
                              plot.setOuter(Global.world);
                              plot.setPosition(m_plots[plotIdx].point.x,m_plots[plotIdx].point.y);
                              plot.attach();
                              if(Global.player.hasEnergy(this.getCurrentEquipmentEnergyCost()))
                              {
                                 this.incrementPlotCountArray(plotIdx);
                              }
                              this.checkPopPPHLimitReachedDialog();
                           }
                           else
                           {
                              maxedObjects = true;
                           }
                        }
                        if(plot != null)
                        {
                           plots.push(plot);
                        }
                     }
                  }
               }
               if(noValidPlots)
               {
                  this.checkPopPPHLimitReachedDialog();
               }
               if(maxedObjects)
               {
                  UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Full"));
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
      
      protected function checkPopPPHLimitReachedDialog() : void
      {
         var terrainCode:int = 0;
         for each(terrainCode in m_arrAcceptableTerrain)
         {
            if(Global.worldManager.getRemainingPlotsAllowed(terrainCode) == 0)
            {
               if(Global.worldManager.checkPPHLimitReached(terrainCode))
               {
                  break;
               }
            }
         }
      }
      
      protected function incrementPlotCountArray(plotIdx:int) : void
      {
         Global.world.incrementPlotCountArray(m_arrAcceptableTerrain);
      }
      
      protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
      }
      
      protected function getCurrentEquipmentEnergyCost() : Number
      {
         return 0;
      }
      
      override protected function isSelectable(plot:Plot) : Boolean
      {
         return plot == null || plot.isPlowable() && plot.isClearable() && isPlotOnAcceptableTerrain(plot);
      }
   }
}

