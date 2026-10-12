package Widgets.Core.Base
{
   import Classes.util.ObjectUtil;
   import Engine.Managers.ErrorManager;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import flash.display.DisplayObject;
   
   public class ZwWire
   {
      
      private var m_widgetClass:Class;
      
      private var m_path:Array;
      
      private var m_args:Array;
      
      public function ZwWire(widgetClass:Class, path:Array, ... args)
      {
         super();
         this.m_widgetClass = widgetClass;
         this.m_path = path;
         this.m_args = args;
      }
      
      public function createWidget(window:ZwAbstractWindow) : ZwWidget
      {
         var widget:ZwWidget = null;
         var elem:DisplayObject = ObjectUtil.extractPath(window,this.m_path) as DisplayObject;
         if(elem)
         {
            try
            {
               switch(this.m_args.length)
               {
                  case 0:
                     widget = new this.m_widgetClass(elem);
                     break;
                  case 1:
                     widget = new this.m_widgetClass(elem,this.m_args[0]);
                     break;
                  case 2:
                     widget = new this.m_widgetClass(elem,this.m_args[0],this.m_args[1]);
                     break;
                  case 3:
                     widget = new this.m_widgetClass(elem,this.m_args[0],this.m_args[1],this.m_args[2]);
                     break;
                  case 4:
                     widget = new this.m_widgetClass(elem,this.m_args[0],this.m_args[1],this.m_args[2],this.m_args[3]);
                     break;
                  case 5:
                     widget = new this.m_widgetClass(elem,this.m_args[0],this.m_args[1],this.m_args[2],this.m_args[3],this.m_args[4]);
               }
            }
            catch(err:Error)
            {
               ErrorManager.addError("Error wiring widget: " + err.message);
            }
         }
         else
         {
            ErrorManager.addError("Invalid wire, path [" + this.m_path.join(",") + "] doesn\'t exist in window");
         }
         return widget;
      }
   }
}

