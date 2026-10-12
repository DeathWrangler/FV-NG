package Display
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   
   public class ContextMenu extends Sprite
   {
      
      protected static var m_currentMenu:ContextMenu;
      
      protected var m_style:Object;
      
      protected var m_items:Array;
      
      protected var m_menuBackground:Shape;
      
      public function ContextMenu(items:Array, style:Object = null)
      {
         var item:Object = null;
         this.m_style = {
            "contextMenu":{
               "backgroundColor":3355443,
               "borderColor":3355443,
               "borderWidth":1
            },
            "contextMenuItem":{
               "width":100,
               "height":20,
               "font":"Merkin2",
               "fontSize":12,
               "textAlign":"left",
               "padding":2,
               "color":0,
               "backgroundColor":16777215,
               "hoverColor":3100495,
               "hoverBackgroundColor":11119017
            }
         };
         super();
         this.m_items = [];
         for(var i:int = 0; i < items.length; i++)
         {
            item = items[i];
            if(item is Object && item.hasOwnProperty("label") && item.hasOwnProperty("action") && item.hasOwnProperty("params"))
            {
               this.m_items.push(new ContextMenuItem(item.label,item.action,item.params,item.style || this.m_style));
            }
            else if(item is Object && item.hasOwnProperty("label") && item.hasOwnProperty("action"))
            {
               this.m_items.push(new ContextMenuItem(item.label,item.action,null,item.style || this.m_style));
            }
            else
            {
               if(!(item is ContextMenuItem))
               {
                  throw new ArgumentError("items array can only contain objects with label and action properties or ContextMenuItems");
               }
               this.m_items.push(item);
            }
         }
         this.setStyle(style);
         this.draw();
         this.addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler,false,0,true);
      }
      
      public function show(posX:Number, posY:Number) : void
      {
         if(ContextMenu.m_currentMenu != null)
         {
            ContextMenu.m_currentMenu.hide();
         }
         this.x = posX;
         this.y = posY;
         Global.stage.addChild(this);
         ContextMenu.m_currentMenu = this;
         UI.updateCurrentCursor(true);
      }
      
      public function hide() : void
      {
         this.removeListeners();
         if(Global.stage == this.parent)
         {
            Global.stage.removeChild(this);
         }
         ContextMenu.m_currentMenu = null;
      }
      
      protected function setStyle(style:Object) : void
      {
         var element:String = null;
         var prop:String = null;
         if(style)
         {
            for(element in style)
            {
               this.m_style[element] = this.m_style[element] || {};
               for(prop in style[element])
               {
                  this.m_style[element][prop] = style[element][prop];
               }
            }
         }
      }
      
      protected function draw() : void
      {
         var item:ContextMenuItem = null;
         var borderWidth:int = 0;
         while(this.numChildren > 0)
         {
            this.removeChildAt(0);
         }
         var counter:int = 0;
         var itemHeight:int = int(this.m_style.contextMenuItem.height);
         var itemPadding:int = int(this.m_style.contextMenuItem.padding);
         for each(item in this.m_items)
         {
            item.y = counter * itemHeight + counter * itemPadding;
            this.addChild(item);
            counter += 1;
         }
         this.m_menuBackground = new Shape();
         borderWidth = int(this.m_style.contextMenu.borderWidth);
         this.m_menuBackground.graphics.lineStyle(borderWidth,this.m_style.contextMenu.backgroundColor);
         this.m_menuBackground.graphics.beginFill(this.m_style.contextMenu.borderColor);
         this.m_menuBackground.graphics.drawRect(-borderWidth,-borderWidth,this.width + borderWidth,this.height + borderWidth);
         this.m_menuBackground.graphics.endFill();
         this.addChildAt(this.m_menuBackground,0);
         for each(item in this.m_items)
         {
            item.draw();
         }
      }
      
      protected function addedToStageHandler(event:Event) : void
      {
         this.removeEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         this.addListeners();
      }
      
      protected function mouseOverHandler(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target.parent == this && event.target.hasOwnProperty("state"))
         {
            for each(item in this.m_items)
            {
               if(item != event.target)
               {
                  item.state = ContextMenuItem.STATE_UP;
               }
               else
               {
                  item.state = ContextMenuItem.STATE_OVER;
               }
            }
         }
      }
      
      protected function mouseClickHandler(event:MouseEvent) : void
      {
         this.hide();
      }
      
      protected function stageMouseClickHandler(event:MouseEvent) : void
      {
         if(!this.hitTestPoint(Global.stage.mouseX,Global.stage.mouseY,true))
         {
            this.hide();
         }
      }
      
      protected function stageMouseMoveHandler(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         Mouse.show();
         if(!this.hitTestPoint(Global.stage.mouseX,Global.stage.mouseY,true))
         {
            for each(item in this.m_items)
            {
               item.state = ContextMenuItem.STATE_UP;
            }
         }
      }
      
      protected function addListeners() : void
      {
         this.addEventListener(MouseEvent.CLICK,this.mouseClickHandler,false,0,true);
         this.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler,false,0,true);
         if(Boolean(this.parent) && this.parent["constructor"] != this["constructor"])
         {
            Global.stage.addEventListener(MouseEvent.CLICK,this.stageMouseClickHandler,false,0,true);
            Global.stage.addEventListener(MouseEvent.MOUSE_OUT,this.stageMouseMoveHandler,false,0,true);
         }
      }
      
      protected function removeListeners() : void
      {
         this.removeEventListener(MouseEvent.CLICK,this.mouseClickHandler);
         this.removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         if(Boolean(this.parent) && this.parent["constructor"] != this["constructor"])
         {
            this.stage.removeEventListener(MouseEvent.CLICK,this.stageMouseClickHandler);
         }
      }
   }
}

