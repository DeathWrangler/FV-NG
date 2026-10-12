package Display.HUD
{
   import Classes.EmbeddedArt;
   import Display.FarmGameSprite;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class StatsDropDown extends FarmGameSprite
   {
      
      public static const ASSET_URL:String = Global.getAssetURL("assets/hud/Status_Shelf/FV_statsTray.swf");
      
      public static const X_POSITION:int = 530;
      
      public static const Y_POSITION:int = 40;
      
      public static const INDEX_LEVEL:int = 0;
      
      public static const INDEX_RIBBONS:int = 1;
      
      public static const INDEX_MASTERIES:int = 2;
      
      public static const INDEX_MEDALS:int = 3;
      
      public static const INDEX_COLLECTIONS:int = 4;
      
      public static const INDEX_BUILDINGS:int = 5;
      
      public static const INDEX_RIBBONS_YELLOW:int = 0;
      
      public static const INDEX_RIBBONS_WHITE:int = 1;
      
      public static const INDEX_RIBBONS_RED:int = 2;
      
      public static const INDEX_RIBBONS_BLUE:int = 3;
      
      public static const INDEX_MASTERIES_LEVEL1:int = 0;
      
      public static const INDEX_MASTERIES_LEVEL2:int = 1;
      
      public static const INDEX_MASTERIES_LEVEL3:int = 2;
      
      public static const INDEX_MEDALS_BRONZE:int = 0;
      
      public static const INDEX_MEDALS_SILVER:int = 1;
      
      public static const INDEX_MEDALS_GOLD:int = 2;
      
      protected var m_Window:MovieClip;
      
      protected var m_statCells:Array;
      
      public function StatsDropDown()
      {
         super();
         this.load();
      }
      
      protected function load() : void
      {
         LoadingManager.load(ASSET_URL,this.AssetLoadCallback);
      }
      
      public function updateCellDisplay() : void
      {
         var i:Number = NaN;
         var k:Number = NaN;
         var subCell:StatsDropDownSubCell = null;
         if(Boolean(Global.player.statValues) && Boolean(this.m_statCells))
         {
            i = 0;
            while(i < this.m_statCells.length && i < Global.player.statValues.length)
            {
               this.m_statCells[i].SetCounterText(Global.player.statValues[i].toString());
               i++;
            }
            for(i = 0; i < this.m_statCells.length; i++)
            {
               if(Global.player.subStatValues[i].length > 0)
               {
                  k = 0;
                  while(k < StatsDropDownCell.NUM_SUB_CELLS && k < Global.player.subStatValues.length)
                  {
                     subCell = this.m_statCells[i].SubCell(k);
                     if(subCell != null && Global.player.subStatValues[i][k] != null)
                     {
                        subCell.Count = Global.player.subStatValues[i][k];
                     }
                     k++;
                  }
                  this.m_statCells[i].updateCountDisplayFromSubCells();
               }
            }
         }
      }
      
      protected function AssetLoadCallback(event:Event) : void
      {
         var toAdd:StatsDropDownCell = null;
         this.x = X_POSITION;
         this.y = Y_POSITION;
         this.m_Window = event.target.content as MovieClip;
         this.m_statCells = new Array();
         var statCellMCs:Array = [this.m_Window.statsMenu_mc.statCell1_mc,this.m_Window.statsMenu_mc.statCell2_mc,this.m_Window.statsMenu_mc.statCell3_mc,this.m_Window.statsMenu_mc.statCell4_mc,this.m_Window.statsMenu_mc.statCell5_mc,this.m_Window.statsMenu_mc.statCell6_mc];
         var slideTrayMCs:Array = [this.m_Window.statsMenu_mc.tray1_mc,this.m_Window.statsMenu_mc.tray2_mc,this.m_Window.statsMenu_mc.tray3_mc,this.m_Window.statsMenu_mc.tray4_mc,this.m_Window.statsMenu_mc.tray5_mc,this.m_Window.statsMenu_mc.tray6_mc];
         var statCellIcons:Array = [new EmbeddedArt.FV_StatusShelf_Icon_Level(),new EmbeddedArt.FV_StatusShelf_Icon_Ribbon(),new EmbeddedArt.FV_StatusShelf_Icon_Mastery(),new EmbeddedArt.FV_StatusShelf_Icon_Medal(),new EmbeddedArt.FV_StatusShelf_Icon_Collections(),new EmbeddedArt.FV_StatusShelf_Icon_Building()];
         var statCellToolTips:Array = ["Level","Ribbons","Masteries","Medals","Collections","Constructed Buildings"];
         for(var i:Number = 0; i < statCellMCs.length; i++)
         {
            statCellMCs[i].statNumber_tf.selectable = false;
            toAdd = new StatsDropDownCell(statCellMCs[i],slideTrayMCs[i],statCellIcons[i]);
            this.m_statCells.push(toAdd);
            toAdd.ToolTipText = statCellToolTips[i];
         }
         this.m_Window.statsMenu_mc.statButton_mc.btnTitle_tf.selectable = false;
         this.InitSubCells();
         this.m_Window.statsMenu_mc.gotoAndStop(0);
         this.m_Window.statsMenu_mc.statButton_mc.addEventListener(MouseEvent.CLICK,this.onStatButtonClick);
         this.statCellMCsVisible(false);
         this.updateCellDisplay();
         this.addChild(this.m_Window);
      }
      
      protected function InitSubCells() : void
      {
         var sc:StatsDropDownCell = null;
         var k:Number = NaN;
         var TrayIcons_Level:Array = [];
         var TrayIcons_Ribbon:Array = [new EmbeddedArt.FV_StatusShelf_TrayIcon_Ribbon_Gold(),new EmbeddedArt.FV_StatusShelf_TrayIcon_Ribbon_White(),new EmbeddedArt.FV_StatusShelf_TrayIcon_Ribbon_Red(),new EmbeddedArt.FV_StatusShelf_TrayIcon_Ribbon_Blue()];
         var TrayIcons_Mastery:Array = [new EmbeddedArt.FV_StatusShelf_TrayIcon_Mastery_One(),new EmbeddedArt.FV_StatusShelf_TrayIcon_Mastery_Two(),new EmbeddedArt.FV_StatusShelf_TrayIcon_Mastery_Three()];
         var TrayIcons_Medal:Array = [new EmbeddedArt.FV_StatusShelf_TrayIcon_Medal_Bronze(),new EmbeddedArt.FV_StatusShelf_TrayIcon_Medal_Silver(),new EmbeddedArt.FV_StatusShelf_TrayIcon_Medal_Gold()];
         var TrayIcons_Collections:Array = [];
         var TrayIcons_Building:Array = [];
         var AllTrayIcons:Array = [TrayIcons_Level,TrayIcons_Ribbon,TrayIcons_Mastery,TrayIcons_Medal,TrayIcons_Collections,TrayIcons_Building];
         for(var i:Number = 0; i < this.m_statCells.length; i++)
         {
            sc = this.m_statCells[i] as StatsDropDownCell;
            for(k = 0; k < AllTrayIcons[i].length; k++)
            {
               sc.addSubCell(AllTrayIcons[i][k],0,k);
            }
         }
      }
      
      protected function statCellMCsVisible(visibility:Boolean) : void
      {
         var cell:StatsDropDownCell = null;
         for each(cell in this.m_statCells)
         {
            cell.IsVisible(visibility);
         }
      }
      
      protected function onStatButtonClick(event:Event) : void
      {
         this.m_Window.statsMenu_mc.gotoAndPlay("start");
         this.statCellMCsVisible(true);
         this.m_Window.statsMenu_mc.statButton_mc.removeEventListener(MouseEvent.CLICK,this.onStatButtonClick);
         this.m_Window.statsMenu_mc.pullTab_mc.addEventListener(MouseEvent.CLICK,this.onPullTabClick);
         FarmStatsManager.count("status_stats","stats_shelf","Open_click");
      }
      
      protected function onPullTabClick(event:Event) : void
      {
         var cell:StatsDropDownCell = null;
         this.m_Window.statsMenu_mc.gotoAndPlay("pause");
         for each(cell in this.m_statCells)
         {
            cell.SlideTheTray(0,true);
         }
         this.statCellMCsVisible(false);
         this.m_Window.statsMenu_mc.pullTab_mc.removeEventListener(MouseEvent.CLICK,this.onPullTabClick);
         this.m_Window.statsMenu_mc.statButton_mc.addEventListener(MouseEvent.CLICK,this.onStatButtonClick);
         FarmStatsManager.count("status_stats","stats_shelf","Close_click");
      }
      
      public function SetVisibility(visible:Boolean) : void
      {
         if(this.m_Window)
         {
            this.m_Window.visible = visible;
         }
      }
   }
}

