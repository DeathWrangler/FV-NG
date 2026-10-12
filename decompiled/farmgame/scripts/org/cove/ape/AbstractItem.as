package org.cove.ape
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   
   public class AbstractItem extends EventDispatcher
   {
      
      private var _sprite:Sprite;
      
      private var _solid:Boolean;
      
      private var _visible:Boolean;
      
      private var _alwaysRepaint:Boolean;
      
      internal var lineThickness:Number;
      
      internal var lineColor:uint;
      
      internal var lineAlpha:Number;
      
      internal var fillColor:uint;
      
      internal var fillAlpha:Number;
      
      internal var displayObject:DisplayObject;
      
      internal var displayObjectOffset:CartesianVector;
      
      internal var displayObjectRotation:Number;
      
      public function AbstractItem()
      {
         super();
         this._solid = true;
         this._visible = true;
         this._alwaysRepaint = false;
      }
      
      public function init() : void
      {
      }
      
      public function paint() : void
      {
      }
      
      public function cleanup() : void
      {
         this.sprite.graphics.clear();
         for(var i:int = 0; i < this.sprite.numChildren; i++)
         {
            this.sprite.removeChildAt(i);
         }
      }
      
      final public function get alwaysRepaint() : Boolean
      {
         return this._alwaysRepaint;
      }
      
      final public function set alwaysRepaint(b:Boolean) : void
      {
         this._alwaysRepaint = b;
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function set visible(v:Boolean) : void
      {
         this._visible = v;
         this.sprite.visible = v;
      }
      
      public function get solid() : Boolean
      {
         return this._solid;
      }
      
      public function set solid(s:Boolean) : void
      {
         this._solid = s;
      }
      
      public function setStyle(lineThickness:Number = 0, lineColor:uint = 0, lineAlpha:Number = 1, fillColor:uint = 16777215, fillAlpha:Number = 1) : void
      {
         this.setLine(lineThickness,lineColor,lineAlpha);
         this.setFill(fillColor,fillAlpha);
      }
      
      public function setLine(thickness:Number = 0, color:uint = 0, alpha:Number = 1) : void
      {
         this.lineThickness = thickness;
         this.lineColor = color;
         this.lineAlpha = alpha;
      }
      
      public function setFill(color:uint = 16777215, alpha:Number = 1) : void
      {
         this.fillColor = color;
         this.fillAlpha = alpha;
      }
      
      public function get sprite() : Sprite
      {
         if(this._sprite != null)
         {
            return this._sprite;
         }
         if(APEngine.container == null)
         {
            throw new Error("The container property of the APEngine class has not been set");
         }
         this._sprite = new Sprite();
         APEngine.container.addChild(this._sprite);
         return this._sprite;
      }
   }
}

