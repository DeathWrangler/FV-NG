package Classes.Yimf
{
   import flash.utils.Dictionary;
   
   public class YimfManager
   {
      
      private static var m_instance:YimfManager;
      
      public static var DEFAULT_TYPE:String = "grass_theme";
      
      private var m_yimf_types:Dictionary;
      
      public function YimfManager()
      {
         super();
         this.m_yimf_types = new Dictionary();
      }
      
      public static function getInstance() : YimfManager
      {
         if(null == m_instance)
         {
            m_instance = new YimfManager();
         }
         return m_instance;
      }
      
      public function setConfigXml(configXml:XML) : void
      {
         var yimfXml:XML = null;
         var yimf:Yimf = null;
         for each(yimfXml in configXml.yimf)
         {
            yimf = new Yimf(yimfXml);
            this.m_yimf_types[yimf.type] = yimf;
         }
      }
      
      public function addConfigXml(tileNode:XML) : void
      {
         var yimf:Yimf = new Yimf(tileNode);
         this.m_yimf_types[yimf.type] = yimf;
      }
      
      public function getYimfConfig(type:String) : Yimf
      {
         return this.m_yimf_types[type];
      }
   }
}

