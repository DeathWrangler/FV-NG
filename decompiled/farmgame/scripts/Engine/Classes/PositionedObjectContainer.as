package Engine.Classes
{
   import Engine.Helpers.IntVector2;
   import Engine.Interfaces.IEngineObject;
   
   public class PositionedObjectContainer extends SavedObject
   {
      
      protected var m_redrawLock:int;
      
      protected var m_children:Array = new Array();
      
      private var m_allDescendents:Array = new Array();
      
      private var m_allDescendentsDirty:Boolean = true;
      
      protected var m_deletionList:Array = new Array();
      
      protected var m_size:IntVector2 = new IntVector2();
      
      public function PositionedObjectContainer(param1:int, param2:int)
      {
         super();
         this.m_size.x = param1;
         this.m_size.y = param2;
      }
      
      override public function getSaveObject() : Object
      {
         var _loc5_:Object = null;
         var _loc1_:Object = super.getSaveObject();
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         var _loc4_:uint = this.m_children.length;
         while(_loc3_ < _loc4_)
         {
            _loc5_ = this.m_children[_loc3_].getSaveObject();
            if(_loc5_)
            {
               _loc2_.push(_loc5_);
            }
            _loc3_++;
         }
         _loc1_.objects = _loc2_;
         return _loc1_;
      }
      
      public function getGridWidth() : int
      {
         return this.m_size.x;
      }
      
      public function getGridHeight() : int
      {
         return this.m_size.y;
      }
      
      public function lockRedraw() : void
      {
         ++this.m_redrawLock;
      }
      
      public function unlockRedraw() : void
      {
         --this.m_redrawLock;
         if(this.isRedrawLocked() == false)
         {
            this.conditionallyRedrawAllObjects();
         }
      }
      
      final public function getObjects() : Array
      {
         var _loc1_:int = 0;
         if(this.m_allDescendentsDirty)
         {
            this.m_allDescendents = [];
            _loc1_ = 0;
            while(_loc1_ < this.m_children.length)
            {
               if(this.m_children[_loc1_] is IEngineObject)
               {
                  this.m_allDescendents = this.m_allDescendents.concat(this.m_children[_loc1_].children);
               }
               _loc1_++;
            }
            this.m_allDescendentsDirty = false;
         }
         return this.m_allDescendents;
      }
      
      final public function setObjectsDirty() : void
      {
         this.m_allDescendentsDirty = true;
      }
      
      public function isRedrawLocked() : Boolean
      {
         return this.m_redrawLock != 0;
      }
      
      public function conditionallyRedrawAllObjects() : void
      {
      }
      
      public function getNumObjects() : int
      {
         return this.getObjects().length;
      }
      
      public function addToDeletionList(param1:PositionedObject) : void
      {
         if(this.m_deletionList.indexOf(param1) == -1)
         {
            this.m_deletionList.push(param1);
         }
      }
      
      public function removeFromDeletionList(param1:PositionedObject) : void
      {
         var _loc2_:int = this.m_deletionList.indexOf(param1);
         if(_loc2_ != -1)
         {
            this.m_deletionList.splice(_loc2_,1);
         }
      }
   }
}

