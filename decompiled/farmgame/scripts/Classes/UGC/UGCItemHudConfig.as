package Classes.UGC
{
   public class UGCItemHudConfig
   {
      
      private var m_hudItems:Array;
      
      public function UGCItemHudConfig(xml:XML)
      {
         var o:Object = null;
         super();
         this.m_hudItems = new Array();
         for each(o in xml.hudItem)
         {
            this.m_hudItems.push(String(o.@item));
         }
      }
      
      public function get hudItems() : Array
      {
         return this.m_hudItems;
      }
   }
}

