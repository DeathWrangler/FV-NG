package Classes.Collections
{
   import Classes.GameSettingsObject;
   
   public class Reward extends GameSettingsObject
   {
      
      public static const GIFT_KEY:String = "gift";
      
      public function Reward(xml:XML)
      {
         super(xml);
      }
      
      public function get gift() : String
      {
         return m_xml.@gift;
      }
   }
}

