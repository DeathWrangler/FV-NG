package com.facebook.data.fbml
{
   [Bindable]
   public class ContainerTagData extends AbstractTagData
   {
      
      public var open_tag_fbml:String;
      
      public var close_tag_fbml:String;
      
      public function ContainerTagData(param1:String, param2:String, param3:String, param4:String, param5:String, param6:String, param7:String = "", param8:String = "", param9:AttributeCollection = null)
      {
         this.open_tag_fbml = param5;
         this.close_tag_fbml = param6;
         super(param1,param2,param3,param4,param7,param8,param9);
      }
   }
}

