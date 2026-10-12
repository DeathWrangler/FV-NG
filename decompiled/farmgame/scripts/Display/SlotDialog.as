package Display
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Managers.ClickTrackingManager;
   import flash.events.MouseEvent;
   
   public class SlotDialog extends Dialog
   {
      
      protected var m_data:Array = [];
      
      protected var m_tileSet:int = 0;
      
      protected var m_tiles:Array = new Array();
      
      protected var m_defaultAction:String = "";
      
      public function SlotDialog()
      {
         super(true);
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         this.takeDefaultAction();
      }
      
      public function set defaultAction(newAction:String) : void
      {
         this.m_defaultAction = newAction;
      }
      
      protected function takeDefaultAction() : void
      {
         if(Boolean(this.m_defaultAction) && Config.DEBUG_MODE)
         {
            this.m_defaultAction = "";
            throw new Error("SlotDialog could not find handler for default action : " + this.m_defaultAction);
         }
      }
      
      protected function getRankComparison(itemA:Object, itemB:Object) : int
      {
         var result:int = 0;
         if(itemA.hasOwnProperty("rank") && itemB.hasOwnProperty("rank") && itemA.rank != itemB.rank)
         {
            if(itemB.rank > itemA.rank)
            {
               result = 1;
            }
            else
            {
               result = -1;
            }
         }
         return result;
      }
      
      protected function fixArrows() : void
      {
         if(Boolean(m_window) && Boolean(m_window.arrowLt_bt) && Boolean(m_window.arrowRt_bt))
         {
            m_window.arrowLt_bt.visible = this.m_tileSet > 0 ? true : false;
            m_window.arrowRt_bt.visible = (this.m_tileSet + 1) * this.getNumSlots() < this.m_data.length ? true : false;
         }
      }
      
      protected function onLtArrowClick(event:MouseEvent) : void
      {
         var newIndex:int = 0;
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         SoundManager.chooseAndPlaySound(["click1","click2","click3"]);
         if(this.m_tileSet > 0)
         {
            this.removeTiles();
            --this.m_tileSet;
            newIndex = this.m_tileSet * this.getNumSlots();
            this.addAllComponents(newIndex);
         }
         this.fixArrows();
      }
      
      protected function onRtArrowClick(event:MouseEvent) : void
      {
         var newIndex:int = 0;
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         SoundManager.chooseAndPlaySound(["click1","click2","click3"]);
         if(this.m_data.length > (this.m_tileSet + 1) * this.getNumSlots())
         {
            this.removeTiles();
            ++this.m_tileSet;
            newIndex = this.m_tileSet * this.getNumSlots();
            this.addAllComponents(newIndex);
         }
         this.fixArrows();
      }
      
      protected function addAllComponents(indx:int) : void
      {
         for(var compIdx:int = 0; compIdx < this.getNumSlots(); compIdx++)
         {
            this.addComponent(compIdx,indx);
         }
      }
      
      public function refreshLayout(force:Boolean = false) : void
      {
         var newIndex:int = 0;
         var compIdx:int = 0;
         if(this.m_data.length > (this.m_tileSet + 1) * this.getNumSlots() || force == true)
         {
            this.removeTiles();
            newIndex = this.m_tileSet * this.getNumSlots();
            for(compIdx = 0; compIdx < this.getNumSlots(); compIdx++)
            {
               this.addComponent(compIdx,newIndex);
            }
         }
         this.fixArrows();
      }
      
      protected function removeTiles(hideTiles:Boolean = true) : void
      {
         var compIdx:int = 0;
         if(hideTiles)
         {
            for(compIdx = 0; compIdx < this.getNumSlots(); compIdx++)
            {
               if(this.m_tiles[compIdx])
               {
                  if(this.m_tiles[compIdx].icon)
                  {
                     Utilities.removeAllChildren(this.m_tiles[compIdx].icon);
                  }
                  this.m_tiles[compIdx].visible = false;
                  this.postRemoveTiles(compIdx);
               }
            }
         }
      }
      
      protected function addComponent(compIdx:int, index:int = 0) : void
      {
         throw new Error("This function needs to be overriden");
      }
      
      protected function postRemoveTiles(compIdx:int) : void
      {
      }
      
      protected function getNumSlots() : int
      {
         throw new Error("This function needs to be overriden");
      }
      
      protected function getItemXMLFromEvent(event:MouseEvent, compId:int = -1) : XML
      {
         if(compId == -1)
         {
            compId = this.getEventIndex(event);
         }
         var dataIndex:int = compId + this.m_tileSet * this.getNumSlots();
         var name:String = this.m_data[dataIndex].name;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         return farmItem.xml ? farmItem.xml : (farmItem.cashXML ? farmItem.cashXML : farmItem.saleXML);
      }
      
      protected function getRelevantItemNameFromEvent(event:MouseEvent, compId:int = -1) : String
      {
         if(compId == -1)
         {
            compId = this.getEventIndex(event);
         }
         var dataIndex:int = compId + this.m_tileSet * this.getNumSlots();
         var name:String = this.m_data[dataIndex].name;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         return farmItem.getPropertyFromItemCashSaleSource("name");
      }
      
      protected function getItemNameFromEvent(event:MouseEvent, compId:int = -1) : String
      {
         if(compId == -1)
         {
            compId = this.getEventIndex(event);
         }
         var dataIndex:int = compId + this.m_tileSet * this.getNumSlots();
         return this.m_data[dataIndex].name;
      }
      
      protected function getEventIndex(event:MouseEvent) : int
      {
         return this.m_tiles.indexOf(event.target.parent);
      }
   }
}

