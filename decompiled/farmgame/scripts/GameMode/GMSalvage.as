package GameMode
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.EmbeddedArt;
   import Classes.FarmGameObject;
   import Classes.MapResource;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import Managers.ClickTrackingManager;
   import Managers.FarmStatsManager;
   import Managers.FreezeManager;
   import Managers.UGCDecoManager;
   import Transactions.TClear;
   import Widgets.Windows.UGCSalvageTooltip;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class GMSalvage extends GMClear
   {
      
      private static const TOOLTIP_XOFFSET:int = -40;
      
      private var m_onDeleteCallback:Function;
      
      private var m_recyclableObjectTables:Dictionary;
      
      private var m_salvageTooltip:UGCSalvageTooltip;
      
      public function GMSalvage(onDeleteCallback:Function)
      {
         super();
         this.m_onDeleteCallback = onDeleteCallback;
         m_cursorImage = EmbeddedArt.cursor_salvage;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         Global.ui.visible = false;
         FreezeManager.thaw(true);
         InputManager.enableInput();
         this.setupWorldObjects();
      }
      
      private function setupWorldObjects() : void
      {
         var resource:MapResource = null;
         var materials:Array = null;
         var obj:Object = null;
         var m_recyclableObjects:Array = UGCDecoManager.instance.findRecyclableObjectsInWorld();
         this.m_recyclableObjectTables = new Dictionary();
         for each(obj in m_recyclableObjects)
         {
            resource = obj.obj;
            materials = UGCDecoManager.instance.getDropTable(obj.table);
            resource.showHighlight(true,Constants.COLOR_HIGHLIGHT_BLUE);
            this.m_recyclableObjectTables[resource] = materials;
         }
      }
      
      override public function disableMode() : void
      {
         var resource:MapResource = null;
         var materials:Array = null;
         var obj:Object = null;
         if(this.m_recyclableObjectTables)
         {
            for(obj in this.m_recyclableObjectTables)
            {
               resource = obj as MapResource;
               resource.showHighlight(false);
            }
            this.m_recyclableObjectTables = null;
         }
         if(this.m_salvageTooltip)
         {
            this.m_salvageTooltip.close();
            this.m_salvageTooltip = null;
         }
         super.disableMode();
         Global.ui.visible = true;
         FreezeManager.freezeRender();
         InputManager.disableInput();
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         var farmObj:FarmGameObject = null;
         var displayObj:Sprite = null;
         if(object != m_highlightedObject)
         {
            farmObj = object as FarmGameObject;
            this.deselectObject();
            if(Boolean(farmObj) && Boolean(this.m_recyclableObjectTables[farmObj]))
            {
               m_highlightedObject = object;
               displayObj = object.getDisplayObject() as Sprite;
               if(displayObj)
               {
                  if(!this.m_salvageTooltip)
                  {
                     this.m_salvageTooltip = new UGCSalvageTooltip();
                  }
                  this.m_salvageTooltip.setMaterials(this.m_recyclableObjectTables[farmObj]);
                  displayObj.addChild(this.m_salvageTooltip);
                  this.setTooltipPosition(displayObj);
               }
            }
            else
            {
               m_highlightedObject = null;
            }
            updateCursor();
         }
      }
      
      override protected function deselectObject() : void
      {
         var displayObj:Sprite = null;
         var farmObj:FarmGameObject = m_highlightedObject as FarmGameObject;
         if(Boolean(farmObj) && Boolean(this.m_salvageTooltip))
         {
            displayObj = farmObj.getDisplayObject() as Sprite;
            if(Boolean(displayObj) && displayObj.contains(this.m_salvageTooltip))
            {
               displayObj.removeChild(this.m_salvageTooltip);
            }
         }
         m_highlightedObject = null;
         updateCursor();
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_DELETE_ITEM);
         var object:MapResource = m_highlightedObject as MapResource;
         if(Boolean(object) && Global.world.getNumObjects() > 2)
         {
            if(object.isClearable() && Boolean(this.m_recyclableObjectTables[object]))
            {
               if(this.m_onDeleteCallback != null)
               {
                  this.m_onDeleteCallback(object,this.m_recyclableObjectTables[object],this.generateOnSubmitDelete(object));
               }
            }
         }
         this.deselectObject();
      }
      
      private function generateOnSubmitDelete(object:MapResource) : Function
      {
         return function(shouldDelete:Boolean):void
         {
            if(shouldDelete)
            {
               if(object.getItem().sellable)
               {
                  FarmStatsManager.count("deletetool","item_sold","",object.getItem().type);
                  object.sellWithOutAsking();
               }
               else
               {
                  FarmStatsManager.count("deletetool","item_deleted","",object.getItem().type);
                  object.detach();
                  object.onDelete();
                  TransactionManager.addTransaction(new TClear(object));
               }
               delete m_recyclableObjectTables[object];
            }
         };
      }
      
      private function setTooltipPosition(displayObject:DisplayObject) : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         var child:DisplayObject = null;
         var xOff:int = TOOLTIP_XOFFSET;
         if(Boolean(this.m_salvageTooltip) && Boolean(displayObject))
         {
            point = new Point();
            spr = displayObject as Sprite;
            this.m_salvageTooltip.scaleX = 0.5 / displayObject.scaleX;
            this.m_salvageTooltip.scaleY = 0.5 / displayObject.scaleY;
            child = spr.getChildAt(0);
            if(child)
            {
               point.x = (child.width - Math.min(this.m_salvageTooltip.width,200) * spr.scaleX) / 2;
               if(point.x != this.m_salvageTooltip.x)
               {
                  this.m_salvageTooltip.x = point.x + xOff;
               }
            }
         }
      }
   }
}

