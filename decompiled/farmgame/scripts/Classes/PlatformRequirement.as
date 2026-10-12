package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   
   public class PlatformRequirement extends ItemRequirement
   {
      
      private var m_name:String;
      
      public function PlatformRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super(xml,item,dataSource);
         if(m_dataSource)
         {
            this.m_name = m_dataSource.getString("name");
         }
         else
         {
            this.m_name = xml.@name;
         }
      }
      
      override public function check() : Boolean
      {
         var name:String = this.m_name.toLowerCase();
         if(name == "flash" || name == "facebook")
         {
            return true;
         }
         return false;
      }
      
      override public function get identifier() : String
      {
         return FarmItemLock.PLATFORM;
      }
      
      override public function getReadableMessage() : String
      {
         return ZLocUtils.t("Dialogs","RequirementPlatform",{"item":this.m_name});
      }
   }
}

