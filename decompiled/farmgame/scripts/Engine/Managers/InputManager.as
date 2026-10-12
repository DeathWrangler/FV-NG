package Engine.Managers
{
   import Engine.Classes.ZEngineCoreModules;
   import Engine.Interfaces.IInputHandler;
   import cipro.Profiler.RuntimeProfiler;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public class InputManager
   {
      
      protected static var m_inputHandlers:Array = new Array();
      
      protected static var m_disableMutex:int = 0;
      
      public function InputManager()
      {
         super();
      }
      
      public static function initializeHandlers(param1:IEventDispatcher) : void
      {
         param1.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
         param1.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         param1.addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
         param1.addEventListener(MouseEvent.DOUBLE_CLICK,onMouseDoubleClick);
         param1.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
         param1.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
         param1.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("onMouseWheel",onExternalMouseWheel);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      protected static function onExternalMouseWheel(param1:int) : void
      {
         onMouseWheel(new MouseEvent(MouseEvent.MOUSE_WHEEL,true,false,0,0,null,false,false,false,false,param1));
      }
      
      public static function enableInput() : void
      {
         --m_disableMutex;
         m_disableMutex = Math.max(m_disableMutex,0);
      }
      
      public static function disableInput() : void
      {
         ++m_disableMutex;
      }
      
      public static function isInputEnabled() : Boolean
      {
         return m_disableMutex == 0;
      }
      
      public static function addHandler(param1:IInputHandler, param2:int = 0) : void
      {
         m_inputHandlers.splice(param2,0,param1);
      }
      
      public static function removeHandler(param1:IInputHandler) : void
      {
         var _loc2_:int = m_inputHandlers.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < m_inputHandlers.length)
         {
            m_inputHandlers.splice(_loc2_,1);
         }
      }
      
      public static function onMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:IInputHandler = null;
         if(isInputEnabled())
         {
            _loc2_ = RuntimeProfiler.enter(ZEngineCoreModules.InputManagerMouseMisc);
            _loc3_ = 0;
            while(_loc3_ < m_inputHandlers.length)
            {
               _loc4_ = m_inputHandlers[_loc3_] as IInputHandler;
               if(_loc4_ != null && _loc4_.onMouseDown(param1))
               {
                  break;
               }
               _loc3_++;
            }
            RuntimeProfiler.leave(_loc2_);
         }
      }
      
      public static function onMouseUp(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:IInputHandler = null;
         if(isInputEnabled())
         {
            _loc2_ = RuntimeProfiler.enter(ZEngineCoreModules.InputManagerMouseMisc);
            _loc3_ = 0;
            while(_loc3_ < m_inputHandlers.length)
            {
               _loc4_ = m_inputHandlers[_loc3_] as IInputHandler;
               if(_loc4_ != null && _loc4_.onMouseUp(param1))
               {
                  break;
               }
               _loc3_++;
            }
            RuntimeProfiler.leave(_loc2_);
         }
      }
      
      public static function onMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:IInputHandler = null;
         if(isInputEnabled())
         {
            _loc2_ = RuntimeProfiler.enter(ZEngineCoreModules.InputManagerMouseMisc);
            _loc3_ = 0;
            while(_loc3_ < m_inputHandlers.length)
            {
               _loc4_ = m_inputHandlers[_loc3_] as IInputHandler;
               if(_loc4_ != null && _loc4_.onMouseOut(param1))
               {
                  break;
               }
               _loc3_++;
            }
            RuntimeProfiler.leave(_loc2_);
         }
      }
      
      public static function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:IInputHandler = null;
         if(isInputEnabled())
         {
            _loc2_ = RuntimeProfiler.enter(ZEngineCoreModules.InputManagerMouseMove);
            _loc3_ = 0;
            while(_loc3_ < m_inputHandlers.length)
            {
               _loc4_ = m_inputHandlers[_loc3_] as IInputHandler;
               if(_loc4_ != null && _loc4_.onMouseMove(param1))
               {
                  break;
               }
               _loc3_++;
            }
            RuntimeProfiler.leave(_loc2_);
         }
      }
      
      public static function onMouseDoubleClick(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IInputHandler = null;
         if(isInputEnabled())
         {
            _loc2_ = 0;
            while(_loc2_ < m_inputHandlers.length)
            {
               _loc3_ = m_inputHandlers[_loc2_] as IInputHandler;
               if(_loc3_ != null && _loc3_.onMouseDoubleClick(param1))
               {
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public static function onMouseWheel(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IInputHandler = null;
         if(isInputEnabled())
         {
            _loc2_ = 0;
            while(_loc2_ < m_inputHandlers.length)
            {
               _loc3_ = m_inputHandlers[_loc2_] as IInputHandler;
               if(_loc3_ != null && _loc3_.onMouseWheel(param1))
               {
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public static function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IInputHandler = null;
         if(isInputEnabled())
         {
            _loc2_ = 0;
            while(_loc2_ < m_inputHandlers.length)
            {
               _loc3_ = m_inputHandlers[_loc2_] as IInputHandler;
               if(_loc3_ != null && _loc3_.onKeyDown(param1))
               {
                  param1.stopPropagation();
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public static function onKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IInputHandler = null;
         if(isInputEnabled())
         {
            _loc2_ = 0;
            while(_loc2_ < m_inputHandlers.length)
            {
               _loc3_ = m_inputHandlers[_loc2_] as IInputHandler;
               if(_loc3_ != null && _loc3_.onKeyUp(param1))
               {
                  param1.stopPropagation();
                  break;
               }
               _loc2_++;
            }
         }
      }
   }
}

