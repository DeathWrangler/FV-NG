package Classes.Yimf
{
   public class YimfPaletteEntry
   {
      
      private var m_name:String;
      
      private var m_imageCode:String;
      
      public function YimfPaletteEntry(a_name:String, a_imageCode:String)
      {
         super();
         this.m_name = a_name;
         this.m_imageCode = a_imageCode;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get imageCode() : String
      {
         return this.m_imageCode;
      }
   }
}

