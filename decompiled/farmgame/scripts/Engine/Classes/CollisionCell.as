package Engine.Classes
{
   public class CollisionCell
   {
      
      public var x:int;
      
      public var y:int;
      
      public var m_walls:Array;
      
      public var m_items:Array;
      
      public var isPathable:Boolean;
      
      public function CollisionCell(param1:int, param2:int)
      {
         super();
         this.x = param1;
         this.y = param2;
         this.isPathable = false;
      }
      
      public function get items() : Array
      {
         var _loc1_:Array = null;
         if(this.m_items)
         {
            _loc1_ = this.m_items;
         }
         else
         {
            _loc1_ = new Array();
         }
         return _loc1_;
      }
      
      public function setWall(param1:int, param2:WorldObject) : void
      {
         if(!this.m_walls)
         {
            this.m_walls = [[],[],[],[]];
         }
         var _loc3_:Array = this.m_walls[param1] as Array;
         if(_loc3_.indexOf(param2) == -1)
         {
            _loc3_.push(param2);
         }
      }
      
      public function getWalls(param1:int) : Array
      {
         var _loc2_:Array = null;
         if(this.m_walls)
         {
            _loc2_ = this.m_walls[param1];
         }
         else
         {
            _loc2_ = new Array();
         }
         return _loc2_;
      }
      
      public function addObject(param1:WorldObject) : void
      {
         if(!this.m_items)
         {
            this.m_items = new Array();
         }
         this.items.push(param1);
      }
      
      public function removeObject(param1:WorldObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.m_items)
         {
            _loc2_ = this.items.indexOf(param1);
            if(_loc2_ != -1)
            {
               this.items.splice(_loc2_,1);
            }
         }
         if(this.m_walls)
         {
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               _loc2_ = int(this.m_walls[_loc3_].indexOf(param1));
               if(_loc2_ != -1)
               {
                  this.m_walls[_loc3_].splice(_loc2_,1);
               }
               _loc3_++;
            }
         }
      }
   }
}

