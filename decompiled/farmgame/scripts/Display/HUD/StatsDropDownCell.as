package Display.HUD
{
   import Managers.FarmStatsManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import gs.TweenLite;
   
   public class StatsDropDownCell extends Sprite
   {
      
      public static const NUM_SUB_CELLS:Number = 5;
      
      private var m_subCategories:Array;
      
      private var m_cell:MovieClip;
      
      private var m_slideTray:MovieClip;
      
      private var m_subCells:Array;
      
      private var m_icon:DisplayObject;
      
      private var m_count:Number;
      
      private var m_toolTipText:String;
      
      private const SLIDETRAY_Y_CORRECTIVE_OFFSET:Number = 3;
      
      private const SLIDETRAY_HEIGHT_PER_CELL:Number = 20;
      
      private var SLIDETRAY_Y_ORIGIN:Number;
      
      private const SLIDETRAY_Y_TWEEN_TIME:Number = 0.5;
      
      public function StatsDropDownCell(parentCell:MovieClip, subCellSlideTray:MovieClip, icon:DisplayObject)
      {
         var mc:MovieClip = null;
         super();
         this.m_cell = parentCell;
         this.m_slideTray = subCellSlideTray;
         this.m_subCategories = new Array(null,null,null,null,null);
         this.m_subCells = [this.m_slideTray.trayCounter5_mc,this.m_slideTray.trayCounter4_mc,this.m_slideTray.trayCounter3_mc,this.m_slideTray.trayCounter2_mc,this.m_slideTray.trayCounter1_mc];
         this.SLIDETRAY_Y_ORIGIN = this.m_slideTray.y;
         for each(mc in this.m_subCells)
         {
            mc.counter_tf.selectable = false;
         }
         if(icon)
         {
            this.m_cell.statIcon_mc.addChild(icon);
         }
         this.m_cell.addEventListener(MouseEvent.CLICK,this.onClick);
         this.m_cell.addEventListener(MouseEvent.ROLL_OVER,this.updateToolTipOnRollover);
         this.m_cell.addEventListener(MouseEvent.ROLL_OUT,this.updateToolTipOnRollout);
         this.SetCounterText("?");
      }
      
      public function set ToolTipText(newText:String) : void
      {
         this.m_toolTipText = newText;
      }
      
      public function SetCounterText(newCount:String) : void
      {
         this.m_cell.statNumber_tf.text = newCount;
      }
      
      protected function updateToolTipOnRollover(event:MouseEvent) : void
      {
         var count:String = null;
         if(this.m_subCategories[0] != null)
         {
            count = this.m_cell.statNumber_tf.text;
            this.m_cell.gotoAndStop(2);
            this.SetCounterText(count);
            this.m_cell.statNumber_tf.selectable = false;
         }
         event.currentTarget.parent.parent.parent.toolTip = this.m_toolTipText;
      }
      
      protected function updateToolTipOnRollout(event:MouseEvent) : void
      {
         var count:String = null;
         if(this.m_subCategories[0] != null)
         {
            count = this.m_cell.statNumber_tf.text;
            this.m_cell.gotoAndStop(1);
            this.SetCounterText(count);
            this.m_cell.statNumber_tf.selectable = false;
         }
         event.currentTarget.parent.parent.parent.toolTip = "";
      }
      
      public function IsVisible(visibility:Boolean) : void
      {
         this.m_cell.visible = visibility;
      }
      
      public function set Icon(newIcon:DisplayObject) : void
      {
         if(this.m_icon)
         {
            this.m_cell.statIcon_mc.removeChild(this.m_icon);
         }
         this.m_icon = newIcon;
         this.m_cell.statIcon_mc.addChild(this.m_icon);
      }
      
      public function updateCountDisplayFromSubCells() : void
      {
         var ssc:StatsDropDownSubCell = null;
         if(this.m_subCategories.length > 0)
         {
            this.m_count = 0;
            for each(ssc in this.m_subCategories)
            {
               if(ssc)
               {
                  this.m_count += ssc.Count;
               }
            }
            this.m_cell.statNumber_tf.text = this.m_count.toString();
         }
      }
      
      public function addSubCell(newIcon:DisplayObject, counter:Number, insertionIndex:Number) : void
      {
         var newSubCat:StatsDropDownSubCell = null;
         if(insertionIndex >= 0 || insertionIndex < this.m_subCells.length)
         {
            newSubCat = new StatsDropDownSubCell(this.m_subCells[insertionIndex]);
            newSubCat.Icon = newIcon;
            newSubCat.Count = counter;
            this.m_subCategories.splice(insertionIndex,1,newSubCat);
            this.updateCountDisplayFromSubCells();
         }
      }
      
      public function eraseSubCell(eraseIndex:Number) : void
      {
         if(eraseIndex >= 0 || eraseIndex < this.m_subCells.length)
         {
            this.m_subCategories.splice(eraseIndex,1,null);
         }
      }
      
      public function SubCell(index:Number) : StatsDropDownSubCell
      {
         var result:StatsDropDownSubCell = null;
         if(index >= 0 && index < this.m_subCells.length)
         {
            result = this.m_subCategories[index];
         }
         return result;
      }
      
      public function SlideTheTray(numCellsToShow:Number, snapTheTray:Boolean = false) : void
      {
         var yDestination:Number = 0;
         if(numCellsToShow <= 0)
         {
            yDestination = this.SLIDETRAY_Y_ORIGIN;
         }
         else
         {
            yDestination = this.SLIDETRAY_Y_ORIGIN + this.SLIDETRAY_Y_CORRECTIVE_OFFSET + this.SLIDETRAY_HEIGHT_PER_CELL * numCellsToShow;
         }
         if(snapTheTray)
         {
            this.m_slideTray.y = yDestination;
         }
         else
         {
            TweenLite.to(this.m_slideTray,this.SLIDETRAY_Y_TWEEN_TIME,{"y":yDestination});
         }
      }
      
      public function onClick(event:MouseEvent) : void
      {
         var highestTakenIndex:Number = NaN;
         var i:Number = NaN;
         if(this.m_slideTray.y == this.SLIDETRAY_Y_ORIGIN)
         {
            highestTakenIndex = 0;
            for(i = 0; i < this.m_subCategories.length; i++)
            {
               if(this.m_subCategories[i] != null)
               {
                  highestTakenIndex = i + 1;
               }
            }
            if(highestTakenIndex > 0)
            {
               FarmStatsManager.count("status_stats","stats_shelf","Category_click",this.m_toolTipText);
            }
            this.SlideTheTray(highestTakenIndex);
         }
         else
         {
            this.SlideTheTray(0);
         }
      }
   }
}

