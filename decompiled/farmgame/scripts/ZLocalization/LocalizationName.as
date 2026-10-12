package ZLocalization
{
   public class LocalizationName extends LocalizationToken
   {
      
      protected const DEFAULT_GENDER:String = "masc";
      
      protected var m_name:String;
      
      public function LocalizationName(param1:String, param2:String = "masc")
      {
         super();
         this.m_name = param1;
         m_attributes.push(param2);
      }
      
      override public function getString() : String
      {
         return this.m_name;
      }
   }
}

