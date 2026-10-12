package Engine.Classes
{
   import Engine.Managers.ErrorManager;
   
   public class EngineObjectComponent extends SavedObject
   {
      
      protected var m_owner:EngineObject = null;
      
      protected var m_name:String = null;
      
      protected var m_skipSave:Boolean = false;
      
      public function EngineObjectComponent()
      {
         super();
      }
      
      public function skipSave() : Boolean
      {
         return this.m_skipSave;
      }
      
      public function get owner() : EngineObject
      {
         return this.m_owner;
      }
      
      public function set owner(param1:EngineObject) : void
      {
         this.m_owner = param1;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function register(param1:EngineObject) : void
      {
         if(this.m_owner)
         {
            ErrorManager.addError("Trying to register an already-registered component!");
         }
         this.m_owner = param1;
         this.onAdd();
      }
      
      public function unregister() : void
      {
         if(!this.m_owner)
         {
            ErrorManager.addError("Trying to unregister an unregistered component!");
         }
         this.onRemove();
         this.m_owner = null;
      }
      
      protected function onAdd() : void
      {
      }
      
      protected function onRemove() : void
      {
      }
   }
}

