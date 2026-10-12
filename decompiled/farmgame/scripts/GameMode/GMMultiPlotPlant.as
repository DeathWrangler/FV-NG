package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.Plot;
   import Classes.Seeder;
   import Classes.ZItem.FarmItem;
   import Display.TurboPPHDialog;
   import Display.UI;
   import Display.UnwitherDialog;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Managers.ClickTrackingManager;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMMultiPlotPlant extends GMMultiPlotAction
   {
      
      private static var m_soundAdded:Boolean = false;
      
      protected var m_seed:FarmItem;
      
      protected var m_equipment:Seeder = null;
      
      protected var m_cursorLoader:Loader;
      
      public function GMMultiPlotPlant(seed:FarmItem, seeder:Seeder = null)
      {
         super();
         this.m_seed = seed;
         this.m_equipment = seeder;
         if(this.m_equipment)
         {
            m_actionSize = this.m_equipment.getActionSize();
            if(!m_soundAdded)
            {
               SoundManager.addSound("tractorPlow",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_plow.mp3"),false);
               SoundManager.addSound("tractorStop",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_off.mp3"),false);
               m_soundAdded = true;
            }
            SoundManager.playSound("tractorStart");
            SoundManager.playSound("tractorIdle",0,9999);
         }
         if(seed)
         {
            this.m_cursorLoader = LoadingManager.load(seed.getImageByName("icon"),this.onCursorLoaded,LoadingManager.PRIORITY_HIGH);
         }
         UI.showBushelReportWindow(this.m_seed.name,true);
      }
      
      override protected function updateCursor() : void
      {
         if(Boolean(m_cursorImage) && m_cursorId <= 0)
         {
            m_cursorId = UI.setCursor(m_cursorImage,true,shouldScaleCursor());
         }
      }
      
      protected function onCursorLoaded(event:Event) : void
      {
         m_cursorImage = this.m_cursorLoader.content;
         m_cursorId = UI.setCursor(this.m_cursorLoader.content,true,shouldScaleCursor());
      }
      
      protected function getPlotsWithConstraints(allplots:Array) : Array
      {
         var seedPlot:Plot = null;
         var limitedPlots:Array = [];
         TurboPPHDialog.showOutOfSeedsDialog(TurboPPHDialog.ACTION_PLANT,this.m_seed,outOfSeedsDialogHandler);
         var tempSeedCount:int = int(Global.player.seeds[this.seed.seedpackagecode].quantity);
         var p:Point = new Point();
         while(tempSeedCount > 0)
         {
            for each(seedPlot in allplots)
            {
               p = new Point(seedPlot.getPosition().x,seedPlot.getPosition().y);
               if((!seedPlot.isPlanted() || seedPlot.isGrown()) && isPlotOnAcceptableTerrain(seedPlot))
               {
                  limitedPlots.push({
                     "point":p,
                     "object":seedPlot,
                     "valid":true
                  });
                  tempSeedCount--;
                  if(tempSeedCount == 0)
                  {
                     break;
                  }
               }
            }
         }
         return limitedPlots;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var avatar:FarmAvatar = null;
         var cost:int = 0;
         var plots:Array = null;
         var plotIdx:int = 0;
         var plot:Plot = null;
         var pos:Point = null;
         var unwitherDialogShown:Boolean = UnwitherDialog.showUnwitherDialogIfAppropriate();
         if(!unwitherDialogShown && performResourceCheck())
         {
            this.performClickTracking();
            avatar = Global.selectedAvatar;
            cost = Global.farmGameSettingsManager.getInt("plowCost");
            plots = [];
            if(Boolean(avatar) && Boolean(Global.player) && Boolean(m_highlightedPoint))
            {
               for(plotIdx = 0; plotIdx < m_plots.length; plotIdx++)
               {
                  if(m_plots[plotIdx].valid)
                  {
                     if(Global.player.canBuy(cost))
                     {
                        plot = m_plots[plotIdx].object as Plot;
                        if(Boolean(plot) && plot.hasValidId())
                        {
                           plots.push(plot);
                        }
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
      
      protected function performClickTracking() : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_VEHICLE,ClickTrackingConstants.CLICK_TYPE_SEEDER);
      }
      
      protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
      }
      
      override protected function isSelectable(plot:Plot) : Boolean
      {
         return plot != null && plot.isPlantable() && plot.isClearable() && isPlotOnAcceptableTerrain(plot);
      }
      
      override public function disableMode() : void
      {
         Global.world.m_chosenSeeder = null;
         if(this.m_equipment)
         {
            SoundManager.stopSound("tractorIdle");
         }
         super.disableMode();
         if(this.m_equipment)
         {
            SoundManager.playSound("tractorStop");
         }
      }
      
      public function get seed() : FarmItem
      {
         return this.m_seed;
      }
   }
}

