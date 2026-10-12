package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import flash.events.EventDispatcher;
   
   public class MasteryBase extends EventDispatcher
   {
      
      protected var m_item:FarmItem = null;
      
      protected var m_xml:XML = null;
      
      public function MasteryBase(xml:XML, item:FarmItem = null)
      {
         super();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_item = item;
         }
         else
         {
            this.m_xml = xml;
         }
      }
      
      public function get type() : String
      {
         var type:String = null;
         if(this.m_item)
         {
            type = this.m_item.type;
         }
         else
         {
            type = this.m_xml.@type;
         }
         return type;
      }
      
      public function get name() : String
      {
         var name:String = null;
         if(this.m_item)
         {
            name = this.m_item.name;
         }
         else
         {
            name = this.m_xml.@name;
         }
         return name;
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
         var images:XMLList = null;
         var result:String = null;
         if(this.m_item)
         {
            result = this.m_item.getImageByName(imageName,absoluteUrl);
         }
         else
         {
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
         }
         return result;
      }
   }
}

