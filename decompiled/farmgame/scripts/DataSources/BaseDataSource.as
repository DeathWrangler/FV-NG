package DataSources
{
   public class BaseDataSource implements IDataSource
   {
      
      protected var m_internalData:*;
      
      public function BaseDataSource()
      {
         super();
      }
      
      public function getData(... rest) : *
      {
         throw new Error("Subclass must override function getData, cannot use BaseDataSource.getData");
      }
      
      public function getArray(... rest) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:* = this.getData.apply(null,rest);
         if(_loc3_ is Array)
         {
            _loc2_ = _loc3_;
         }
         return _loc2_;
      }
      
      public function hasData(... rest) : Boolean
      {
         throw new Error("Subclass must override function hasData, cannot use BaseDataSource.hasData");
      }
      
      public function getInt(... rest) : int
      {
         return int(this.getData.apply(null,rest));
      }
      
      public function getBoolean(... rest) : Boolean
      {
         return Boolean(this.getData.apply(null,rest));
      }
      
      public function getString(... rest) : String
      {
         var _loc3_:String = null;
         var _loc2_:String = this.getData.apply(null,rest);
         if(_loc2_ == null)
         {
            _loc3_ = "";
         }
         else
         {
            _loc3_ = String(_loc2_);
         }
         return _loc3_;
      }
      
      public function getNumber(... rest) : Number
      {
         return Number(this.getData.apply(null,rest));
      }
      
      public function toString() : String
      {
         var _loc1_:String = "";
         if(this.m_internalData)
         {
            _loc1_ = this.m_internalData.toString();
         }
         return _loc1_;
      }
      
      public function hasProperty(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(this.m_internalData)
         {
            if(this.m_internalData is Object)
            {
               _loc2_ = Boolean(this.m_internalData.hasOwnProperty(param1));
            }
         }
         return _loc2_;
      }
      
      public function getAttributesHash(param1:Boolean = false) : Object
      {
         throw new Error("Subclass must override function getAttributesHash, cannot use BaseDataSource.getAttributesHash");
      }
   }
}

