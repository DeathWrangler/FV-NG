package Classes
{
   public class PhotoGalleryImageData
   {
      
      private var m_itemCodes:Array = new Array();
      
      private var m_key:String = null;
      
      private var m_url:String = null;
      
      private var m_hashKey:String = null;
      
      private var m_decision:int = -1;
      
      public function PhotoGalleryImageData(data:Object)
      {
         super();
         if(data.hasOwnProperty("itemCodes") && data["itemCodes"] != null)
         {
            this.m_itemCodes = data["itemCodes"];
         }
         if(data.hasOwnProperty("key") && data["key"] != null)
         {
            this.m_key = data["key"];
         }
         if(data.hasOwnProperty("url") && data["url"] != null)
         {
            this.m_url = data["url"];
         }
      }
      
      public function set decision(value:int) : void
      {
         this.m_decision = value;
      }
      
      public function get decision() : int
      {
         return this.m_decision;
      }
      
      public function get key() : String
      {
         return this.m_key;
      }
      
      public function get imageUrl() : String
      {
         return this.m_url;
      }
      
      public function get hashKey() : String
      {
         return this.m_hashKey;
      }
      
      public function get itemCodes() : Array
      {
         return this.m_itemCodes;
      }
   }
}

