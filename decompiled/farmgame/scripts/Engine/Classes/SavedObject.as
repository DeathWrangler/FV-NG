package Engine.Classes
{
   import Engine.Constants;
   import Engine.Managers.ErrorManager;
   import Engine.Utilities;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class SavedObject
   {
      
      protected var m_id:Number = 0;
      
      protected var m_tempId:Number = Constants.INDEX_NONE;
      
      protected var m_transactionCount:int = 0;
      
      protected var m_deleted:Boolean = false;
      
      public function SavedObject()
      {
         super();
      }
      
      protected static function getInstance(param1:String) : SavedObject
      {
         var SavedObjectClassType:Class = null;
         var instance:SavedObject = null;
         var className:String = param1;
         try
         {
            SavedObjectClassType = getDefinitionByName("Classes." + className) as Class;
            instance = new SavedObjectClassType();
         }
         catch(e:ReferenceError)
         {
            ErrorManager.addError("Type is not found " + className,ErrorManager.ERROR_REMOTEOBJECT_FAULT);
         }
         return instance;
      }
      
      public function loadObject(param1:Object) : void
      {
         this.m_deleted = param1.deleted;
         this.m_id = param1.id;
         this.m_tempId = param1.tempId;
      }
      
      public function equals(param1:SavedObject) : Boolean
      {
         return param1 != null && this === param1 || this.m_id > 0 && this.m_id == param1.m_id || this.m_tempId != Constants.INDEX_NONE && this.m_tempId == param1.m_tempId;
      }
      
      public function getId() : Number
      {
         return this.m_id;
      }
      
      public function setId(param1:Number) : void
      {
         this.m_id = param1;
      }
      
      public function getTempId() : Number
      {
         return this.m_tempId;
      }
      
      public function generateTempId() : void
      {
         this.m_tempId = Utilities.generateUniqueId();
      }
      
      public function setTempId(param1:Number) : void
      {
         this.m_tempId = param1;
      }
      
      public function hasId() : Boolean
      {
         return this.m_id != Constants.INDEX_NONE;
      }
      
      public function getClassName() : String
      {
         var _loc1_:Array = getQualifiedClassName(this).split("::");
         return _loc1_[_loc1_.length - 1];
      }
      
      public function markForDeletion(param1:Boolean) : void
      {
         if(param1)
         {
            this.m_deleted = true;
         }
         else
         {
            this.m_deleted = false;
         }
      }
      
      public function incrementTransactions() : void
      {
         ++this.m_transactionCount;
      }
      
      public function decrementTransactions() : void
      {
         --this.m_transactionCount;
      }
      
      public function clearTransactions() : void
      {
         this.m_transactionCount = 0;
      }
      
      public function needsToBeSaved() : Boolean
      {
         return this.m_transactionCount != 0 || this.m_deleted;
      }
      
      public function getSaveObject() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.deleted = this.m_deleted;
         _loc1_.id = this.m_id;
         _loc1_.tempId = this.m_tempId;
         _loc1_.className = this.getClassName();
         return _loc1_;
      }
   }
}

