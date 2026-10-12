package zasp.Classes
{
   import zasp.Util.CircularBuffer;
   
   public class ZaspTrackerDetail
   {
      
      protected static const BUFFER_LENGTH:int = 45;
      
      protected var bufF2F:CircularBuffer = new CircularBuffer(BUFFER_LENGTH);
      
      public function ZaspTrackerDetail()
      {
         super();
      }
      
      public function sample(param1:String, param2:Number, param3:Number, param4:int) : void
      {
         var _loc5_:Object = null;
         while(this.bufF2F.length >= this.bufF2F.capacity - 1)
         {
            _loc5_ = this.bufF2F.pop();
         }
         if(null == _loc5_)
         {
            _loc5_ = new Object();
         }
         _loc5_.gameState = param1;
         _loc5_.gameNumber = param2;
         _loc5_.dt = param3;
         _loc5_.mem = param4;
         this.bufF2F.push(_loc5_);
      }
      
      public function report() : Object
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc1_:Object = new Object();
         _loc1_.buf_length = BUFFER_LENGTH;
         _loc1_.buf = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.bufF2F.length)
         {
            _loc3_ = this.bufF2F.elementAt(_loc2_);
            _loc4_ = new Object();
            _loc4_.gameState = _loc3_.gameState;
            _loc4_.gameNumber = _loc3_.gameNumber;
            _loc4_.dt = _loc3_.dt;
            _loc4_.mem = _loc3_.mem;
            _loc1_.buf[_loc2_] = _loc4_;
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function get f2fBuffer() : CircularBuffer
      {
         return this.bufF2F;
      }
      
      public function log_report() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.bufF2F.length)
         {
            _loc2_ = this.bufF2F.elementAt(_loc1_);
            _loc1_++;
         }
      }
   }
}

