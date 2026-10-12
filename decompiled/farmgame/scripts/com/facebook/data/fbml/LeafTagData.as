package com.facebook.data.fbml
{
   [Bindable]
   public class LeafTagData extends AbstractTagData
   {
      
      public var fbml:String;
      
      public function LeafTagData(param1:String, param2:String, param3:String, param4:String, param5:String, param6:String = "", param7:String = "", param8:AttributeCollection = null)
      {
         super(param1,param3,param4,param5,param6,param7,param8);
         this.fbml = param2;
      }
   }
}

