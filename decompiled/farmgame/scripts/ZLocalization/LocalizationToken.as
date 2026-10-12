package ZLocalization
{
   public class LocalizationToken
   {
      
      protected var m_attributes:Array;
      
      public function LocalizationToken()
      {
         super();
         this.m_attributes = new Array();
      }
      
      public function filterIndexes(param1:Array) : Array
      {
         var _loc4_:Array = null;
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = Utilities.arrayDiff(this.m_attributes,param1[_loc3_]);
            if(_loc4_.length == 0)
            {
               _loc2_.push(_loc3_);
            }
            else if(_loc4_.length == 1 && LocalizationObjectToken.GENDERS.hasOwnProperty(_loc4_[0]) && !(this is LocalizationName))
            {
               _loc2_.push(_loc3_);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function addAttributes(param1:Array) : void
      {
         this.m_attributes = this.m_attributes.concat(param1);
      }
      
      public function getString() : String
      {
         throw new Error("Must override getString function when extending LocalizationToken");
      }
   }
}

