package Classes
{
   import Classes.ZItem.FarmItem;
   
   public class ItemFinderFoundItem
   {
      
      private var m_friendlyName:String = "";
      
      private var m_farmItem:FarmItem = null;
      
      private var m_icon:String = "";
      
      private var m_priority:int = 0;
      
      private var m_callback:Function = null;
      
      private var m_bodyText:String = "";
      
      private var m_buttonText:String = "";
      
      public function ItemFinderFoundItem(friendlyName:String, farmItem:FarmItem, icon:String, priority:int, callback:Function, bodyText:String, buttonText:String)
      {
         super();
         this.m_friendlyName = friendlyName;
         this.m_farmItem = farmItem;
         this.m_icon = icon;
         this.m_priority = priority;
         this.m_callback = callback;
         this.m_bodyText = bodyText;
         this.m_buttonText = buttonText;
      }
      
      public static function compare(foundItemA:Object, foundItemB:Object) : int
      {
         var result:int = 0;
         if(foundItemA.friendlyName < foundItemB.friendlyName)
         {
            result = -1;
         }
         else if(foundItemB.friendlyName < foundItemA.friendlyName)
         {
            result = 1;
         }
         else if(foundItemA.priority < foundItemB.priority)
         {
            result = -1;
         }
         else if(foundItemB.priority < foundItemA.priority)
         {
            result = 1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      public function get friendlyName() : String
      {
         return this.m_friendlyName;
      }
      
      public function get farmItem() : FarmItem
      {
         return this.m_farmItem;
      }
      
      public function get itemName() : String
      {
         return this.m_farmItem ? this.m_farmItem.name : "";
      }
      
      public function get icon() : String
      {
         return this.m_icon;
      }
      
      private function get priority() : int
      {
         return this.m_priority;
      }
      
      public function get callback() : Function
      {
         return this.m_callback;
      }
      
      public function get bodyText() : String
      {
         return this.m_bodyText;
      }
      
      public function get buttonText() : String
      {
         return this.m_buttonText;
      }
   }
}

