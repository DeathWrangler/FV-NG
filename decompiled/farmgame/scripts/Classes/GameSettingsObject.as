package Classes
{
   import Classes.util.ZLocUtils;
   import flash.events.EventDispatcher;
   
   public class GameSettingsObject extends EventDispatcher
   {
      
      protected var m_xml:XML = null;
      
      public function GameSettingsObject(xml:XML)
      {
         super();
         this.m_xml = xml;
      }
      
      public function get name() : String
      {
         return this.m_xml.@name;
      }
      
      public function get xml() : XML
      {
         return this.m_xml;
      }
      
      protected function getFriendlyNameLocFile() : String
      {
         throw new Error("This function needs to be overriden");
      }
      
      public function get friendlyName() : String
      {
         return this.getFriendlyNameLocFile() + ":" + this.name + "_friendlyName";
      }
      
      public function get tooltipNotes() : String
      {
         return ZLocUtils.t(this.getFriendlyNameLocFile(),this.name + "_notes");
      }
      
      public function getImageByName(imageName:String, absoluteUrl:Boolean = true) : String
      {
         var result:String = null;
         var images:XMLList = null;
         result = null;
         images = this.m_xml.image.(@name == imageName);
         if(images.length())
         {
            if(absoluteUrl)
            {
               result = Global.getAssetURL(images[0].@url);
            }
            else
            {
               result = images[0].@url;
            }
         }
         return result;
      }
   }
}

