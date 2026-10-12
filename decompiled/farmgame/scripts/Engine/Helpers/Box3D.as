package Engine.Helpers
{
   public class Box3D
   {
      
      protected var m_size:Vector3 = new Vector3();
      
      protected var m_position:Vector3 = new Vector3();
      
      public function Box3D(param1:Vector3 = null, param2:Vector3 = null)
      {
         super();
         if(param1 != null)
         {
            this.m_position = param1.clone();
         }
         if(param2 != null)
         {
            this.m_size = param2.clone();
         }
      }
      
      public function get min() : Vector3
      {
         return this.m_position.clone();
      }
      
      public function get max() : Vector3
      {
         return this.m_position.add(this.m_size);
      }
      
      public function get position() : Vector3
      {
         return this.m_position.clone();
      }
      
      public function get size() : Vector3
      {
         return this.m_size.clone();
      }
      
      public function get x() : Number
      {
         return this.m_position.x;
      }
      
      public function get y() : Number
      {
         return this.m_position.y;
      }
      
      public function get z() : Number
      {
         return this.m_position.z;
      }
      
      public function get width() : Number
      {
         return this.m_size.x;
      }
      
      public function get height() : Number
      {
         return this.m_size.y;
      }
      
      public function get length() : Number
      {
         return this.m_size.z;
      }
      
      public function set position(param1:Vector3) : void
      {
         this.m_position = param1.clone();
      }
      
      public function set size(param1:Vector3) : void
      {
         this.m_size = param1.clone();
      }
      
      public function set x(param1:Number) : void
      {
         this.m_position.x = param1;
      }
      
      public function set y(param1:Number) : void
      {
         this.m_position.y = param1;
      }
      
      public function set z(param1:Number) : void
      {
         this.m_position.z = param1;
      }
      
      public function set width(param1:Number) : void
      {
         this.m_size.x = param1;
      }
      
      public function set height(param1:Number) : void
      {
         this.m_size.y = param1;
      }
      
      public function set length(param1:Number) : void
      {
         this.m_size.z = param1;
      }
      
      public function isPointInside(param1:Vector3, param2:Boolean = true) : Boolean
      {
         var _loc3_:Vector3 = this.max;
         if(param2)
         {
            return this.m_position.x <= param1.x && _loc3_.x >= param1.x && this.m_position.y <= param1.y && _loc3_.y >= param1.y && this.m_position.z <= param1.z && _loc3_.z >= param1.z;
         }
         return this.m_position.x < param1.x && _loc3_.x > param1.x && this.m_position.y < param1.y && _loc3_.y > param1.y && this.m_position.z < param1.z && _loc3_.z > param1.z;
      }
      
      public function isBoxIntersecting(param1:Box3D, param2:Boolean = true) : Boolean
      {
         return false;
      }
   }
}

