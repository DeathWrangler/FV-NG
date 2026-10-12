package Engine.Classes
{
   import Engine.Managers.ErrorManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   public class EngineObject extends SavedObject implements IEventDispatcher
   {
      
      protected var m_dispatcher:EventDispatcher;
      
      protected var m_components:Dictionary = new Dictionary();
      
      public function EngineObject()
      {
         super();
         this.m_dispatcher = new EventDispatcher(this);
      }
      
      override public function getSaveObject() : Object
      {
         var _loc3_:EngineObjectComponent = null;
         var _loc1_:Object = super.getSaveObject();
         var _loc2_:Object = new Object();
         for each(_loc3_ in this.m_components)
         {
            if(!_loc3_.skipSave())
            {
               _loc2_[_loc3_.name] = _loc3_.getSaveObject();
            }
         }
         _loc1_.components = _loc2_;
         return _loc1_;
      }
      
      override public function loadObject(param1:Object) : void
      {
         var _loc3_:EngineObjectComponent = null;
         super.loadObject(param1);
         var _loc2_:Object = param1.components;
         for each(_loc3_ in this.m_components)
         {
            if(_loc2_.hasOwnProperty(_loc3_.name))
            {
               _loc3_.loadObject(_loc2_[_loc3_.name]);
            }
         }
      }
      
      final protected function addComponent(param1:EngineObjectComponent) : Boolean
      {
         var _loc2_:Boolean = false;
         if(!param1.owner)
         {
            if(!this.m_components.hasOwnProperty(param1.name))
            {
               this.m_components[param1.name] = param1;
               param1.register(this);
               _loc2_ = true;
            }
            else
            {
               ErrorManager.addError("A engine object component with name " + param1.name + " already exists on this engine object.");
            }
         }
         else
         {
            ErrorManager.addError("The engine object component " + param1.name + " already has an owner.");
         }
         return _loc2_;
      }
      
      final protected function removeComponent(param1:EngineObjectComponent) : void
      {
         if(this == param1.owner)
         {
            if(this.m_components[param1.name])
            {
               delete this.m_components[param1.name];
               param1.unregister();
            }
            else
            {
               ErrorManager.addError("The engine object component " + param1.name + " was not found on this engine object.");
            }
         }
         else
         {
            ErrorManager.addError("The engine object component " + param1.name + " is not owned by this engine object.");
         }
      }
      
      public function lookupComponentByName(param1:String) : EngineObjectComponent
      {
         var _loc2_:EngineObjectComponent = null;
         if(this.m_components[param1])
         {
            _loc2_ = this.m_components[param1];
         }
         return _loc2_;
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this.m_dispatcher.addEventListener(param1,param2,param3,param4);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this.m_dispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this.m_dispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this.m_dispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this.m_dispatcher.willTrigger(param1);
      }
   }
}

