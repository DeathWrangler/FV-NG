package Widgets.Core.Base
{
   import Engine.Utilities;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.geom.Transform;
   
   public class ZwBaseWidget extends ZwObject
   {
      
      protected var m_element:Object = null;
      
      protected var m_parent:Object;
      
      protected var m_isEnabled:Boolean = true;
      
      public function ZwBaseWidget(element:DisplayObject)
      {
         super();
         this.m_element = element;
      }
      
      override public function release() : void
      {
         this.m_element = null;
         this.m_parent = null;
         super.release();
      }
      
      final public function get element() : Object
      {
         return this.m_element;
      }
      
      final public function get parent() : Object
      {
         return this.m_parent;
      }
      
      final public function set parent(value:Object) : void
      {
         this.m_parent = value;
      }
      
      final public function getAncestorByClassType(classType:Class) : Object
      {
         var result:Object = null;
         if(this.m_parent is classType)
         {
            result = this.m_parent;
         }
         else if(this.m_parent is ZwBaseWidget)
         {
            result = (this.m_parent as ZwBaseWidget).getAncestorByClassType(classType);
         }
         return result;
      }
      
      final public function getParentWindow() : ZwAbstractWindow
      {
         return this.getAncestorByClassType(ZwAbstractWindow) as ZwAbstractWindow;
      }
      
      final public function closeParentWindow() : void
      {
         var parentWindow:ZwAbstractWindow = this.getParentWindow();
         if(parentWindow)
         {
            parentWindow.close();
         }
      }
      
      final public function get name() : String
      {
         return this.m_element.name;
      }
      
      final public function get x() : Number
      {
         return this.m_element.x;
      }
      
      final public function set x(value:Number) : void
      {
         this.m_element.x = value;
      }
      
      final public function get y() : Number
      {
         return this.m_element.y;
      }
      
      final public function set y(value:Number) : void
      {
         this.m_element.y = value;
      }
      
      final public function get width() : Number
      {
         return this.m_element.width;
      }
      
      final public function set width(value:Number) : void
      {
         this.m_element.width = value;
      }
      
      final public function get height() : Number
      {
         return this.m_element.height;
      }
      
      final public function set height(value:Number) : void
      {
         this.m_element.height = value;
      }
      
      final public function get visible() : Boolean
      {
         return Boolean(this.m_element) && Boolean(this.m_element.visible);
      }
      
      final public function set visible(value:Boolean) : void
      {
         var isEnabled:Boolean = false;
         this.m_element.visible = value;
         if(value)
         {
            this.enabled = this.m_isEnabled;
         }
         else
         {
            isEnabled = this.m_isEnabled;
            this.enabled = value;
            this.m_isEnabled = isEnabled;
         }
      }
      
      final public function get alpha() : Number
      {
         return this.m_element.alpha;
      }
      
      final public function set alpha(value:Number) : void
      {
         this.m_element.alpha = value;
      }
      
      final public function get transform() : Transform
      {
         return this.m_element.transform;
      }
      
      final public function set transform(value:Transform) : void
      {
         this.m_element.transform = value;
      }
      
      public function get enabled() : Boolean
      {
         return this.m_isEnabled;
      }
      
      public function set enabled(value:Boolean) : void
      {
         if(this.m_element is DisplayObjectContainer && this.m_element != null)
         {
            Utilities.toggleInputAndChildren(this.m_element as DisplayObjectContainer,value);
         }
         else if(this.m_element is InteractiveObject && this.m_element != null)
         {
            Utilities.toggleInputOnlySelf(this.m_element as InteractiveObject,value);
         }
         this.m_isEnabled = value;
      }
   }
}

